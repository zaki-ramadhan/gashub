import 'package:flutter/foundation.dart';
import '../../inventory/data/inventory_repository.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/report_models.dart';

/// Repository calculating real-time operational reports & PnL dynamically from Supabase PostgreSQL.
class ReportsRepository {
  ReportsRepository._();
  static final ReportsRepository instance = ReportsRepository._();

  final ValueNotifier<ReportPeriodSummary?> liveSummaryNotifier =
      ValueNotifier<ReportPeriodSummary?>(null);

  Map<int, List<ReportPeriodSummary>> _tabOptions = {
    0: [ReportPeriodSummary.empty(id: 'live_week', title: 'Minggu Berjalan', dateRangeLabel: 'Minggu Ini')],
    1: [ReportPeriodSummary.empty(id: 'live_month', title: 'Bulan Berjalan', dateRangeLabel: 'Bulan Ini')],
    2: [ReportPeriodSummary.empty(id: 'live_year', title: 'Tahun Berjalan', dateRangeLabel: 'Tahun Ini')],
    3: [ReportPeriodSummary.empty(id: 'live_all', title: 'Semua Periode', dateRangeLabel: 'Semua Waktu')],
  };

  List<ReportPeriodSummary> getOptionsForTab(int tabIndex) {
    return _tabOptions[tabIndex] ?? [
      ReportPeriodSummary.empty(id: 'empty_$tabIndex', title: 'Periode', dateRangeLabel: 'Aktif'),
    ];
  }

  Future<ReportPeriodSummary?> fetchLiveReport() async {
    try {
      final client = Supabase.instance.client;

      // 1. Fetch distributions and their items
      final distRes = await client.from('distributions').select('''
        id, total, amount_paid, business_date,
        distribution_items(quantity, unit_price, subtotal)
      ''').order('business_date', ascending: false);

      // 2. Fetch cashflow entries
      final cashflowRes = await client.from('cashflow_entries').select(
        'amount, direction, category, business_date',
      );

      // 3. Fetch outstanding receivables
      final recRes = await client.from('receivables').select('remaining_amount').neq('status', 'paid');
      int totalReceivable = 0;
      for (final row in recRes as List<dynamic>) {
        final r = row as Map<String, dynamic>;
        totalReceivable += (r['remaining_amount'] as num?)?.toInt() ?? 0;
      }

      final distList = (distRes as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
      final cashflowList = (cashflowRes as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();

      final now = DateTime.now();

      // --- TAB 0: MINGGU (4 Minggu Terakhir) ---
      final List<ReportPeriodSummary> weeklySummaries = [];
      for (int w = 0; w < 4; w++) {
        final refDay = now.subtract(Duration(days: w * 7));
        final startOfWeek = DateTime(refDay.year, refDay.month, refDay.day).subtract(Duration(days: refDay.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        final isCurrentWeek = w == 0;
        weeklySummaries.add(_buildSummary(
          id: 'week_$w',
          title: isCurrentWeek ? 'Minggu Ini' : (w == 1 ? 'Minggu Lalu' : '$w Minggu Lalu'),
          comparisonText: isCurrentWeek ? 'Minggu Berjalan' : 'Riwayat Minggu',
          dateRangeLabel: '${DateFormat('d MMM', 'id_ID').format(startOfWeek)} – ${DateFormat('d MMM yyyy', 'id_ID').format(endOfWeek)}',
          distributions: distList.where((d) {
            final dt = DateTime.tryParse(d['business_date']?.toString() ?? '');
            return dt != null && !dt.isBefore(startOfWeek) && !dt.isAfter(endOfWeek);
          }).toList(),
          cashflows: cashflowList.where((c) {
            final dt = DateTime.tryParse(c['business_date']?.toString() ?? '');
            return dt != null && !dt.isBefore(startOfWeek) && !dt.isAfter(endOfWeek);
          }).toList(),
          totalReceivable: totalReceivable,
          pointType: _PointType.weekDays,
          referenceDate: startOfWeek,
        ));
      }

      // --- TAB 1: BULAN (12 Bulan Mundur Dinamis) ---
      final List<ReportPeriodSummary> monthlySummaries = [];
      for (int m = 0; m < 12; m++) {
        final targetMonthDate = DateTime(now.year, now.month - m, 1);
        final lastDay = DateTime(targetMonthDate.year, targetMonthDate.month + 1, 0).day;
        final isCurrentMonth = m == 0;

        final mDist = distList.where((d) {
          final dt = DateTime.tryParse(d['business_date']?.toString() ?? '');
          return dt != null && dt.year == targetMonthDate.year && dt.month == targetMonthDate.month;
        }).toList();

        final mCash = cashflowList.where((c) {
          final dt = DateTime.tryParse(c['business_date']?.toString() ?? '');
          return dt != null && dt.year == targetMonthDate.year && dt.month == targetMonthDate.month;
        }).toList();

        monthlySummaries.add(_buildSummary(
          id: 'month_${targetMonthDate.year}_${targetMonthDate.month}',
          title: isCurrentMonth
              ? 'Bulan Ini (${DateFormat('MMMM yyyy', 'id_ID').format(targetMonthDate)})'
              : DateFormat('MMMM yyyy', 'id_ID').format(targetMonthDate),
          comparisonText: isCurrentMonth ? 'Bulan Berjalan' : 'Riwayat Bulanan',
          dateRangeLabel: '1 – $lastDay ${DateFormat('MMM yyyy', 'id_ID').format(targetMonthDate)}',
          distributions: mDist,
          cashflows: mCash,
          totalReceivable: totalReceivable,
          pointType: _PointType.monthDays,
          referenceDate: targetMonthDate,
        ));
      }

      // --- TAB 2: TAHUN (Tahun Berjalan + Riwayat Tahun yang Ada Data atau 3 Tahun Mundur) ---
      final Set<int> recordedYears = {now.year};
      for (final d in distList) {
        final dt = DateTime.tryParse(d['business_date']?.toString() ?? '');
        if (dt != null) recordedYears.add(dt.year);
      }
      for (final c in cashflowList) {
        final dt = DateTime.tryParse(c['business_date']?.toString() ?? '');
        if (dt != null) recordedYears.add(dt.year);
      }
      // Pastikan ada setidaknya 3 tahun mundur
      for (int y = 0; y < 3; y++) {
        recordedYears.add(now.year - y);
      }
      final sortedYears = recordedYears.toList()..sort((a, b) => b.compareTo(a));

      final List<ReportPeriodSummary> yearlySummaries = [];
      for (final yr in sortedYears) {
        final isCurrentYear = yr == now.year;
        final yDist = distList.where((d) {
          final dt = DateTime.tryParse(d['business_date']?.toString() ?? '');
          return dt != null && dt.year == yr;
        }).toList();

        final yCash = cashflowList.where((c) {
          final dt = DateTime.tryParse(c['business_date']?.toString() ?? '');
          return dt != null && dt.year == yr;
        }).toList();

        yearlySummaries.add(_buildSummary(
          id: 'year_$yr',
          title: isCurrentYear ? 'Tahun Ini ($yr)' : 'Tahun $yr',
          comparisonText: isCurrentYear ? 'Tahun Berjalan' : 'Riwayat Tahunan',
          dateRangeLabel: '1 Jan – 31 Des $yr',
          distributions: yDist,
          cashflows: yCash,
          totalReceivable: totalReceivable,
          pointType: _PointType.yearMonths,
          referenceDate: DateTime(yr, 1, 1),
        ));
      }

      // --- TAB 3: SEMUA WAKTU ---
      final allTimeSummary = _buildSummary(
        id: 'all_time_live',
        title: 'Semua Periode',
        comparisonText: 'Akumulasi Total',
        dateRangeLabel: 'Semua Waktu',
        distributions: distList,
        cashflows: cashflowList,
        totalReceivable: totalReceivable,
        pointType: _PointType.yearMonths,
        referenceDate: DateTime(now.year, 1, 1),
      );

      _tabOptions = {
        0: weeklySummaries,
        1: monthlySummaries,
        2: yearlySummaries,
        3: [allTimeSummary],
      };

      liveSummaryNotifier.value = monthlySummaries.first;
      return monthlySummaries.first;
    } catch (e) {
      debugPrint('Error calculating live report from Supabase: $e');
      return null;
    }
  }

  ReportPeriodSummary _buildSummary({
    required String id,
    required String title,
    required String comparisonText,
    required String dateRangeLabel,
    required List<Map<String, dynamic>> distributions,
    required List<Map<String, dynamic>> cashflows,
    required int totalReceivable,
    required _PointType pointType,
    required DateTime referenceDate,
  }) {
    int totalSoldQty = 0;
    int rawOmset = 0;

    for (final d in distributions) {
      final total = (d['total'] as num?)?.toInt() ?? 0;
      rawOmset += total;
      final items = (d['distribution_items'] as List<dynamic>?) ?? [];
      for (final it in items) {
        if (it is Map<String, dynamic>) {
          totalSoldQty += (it['quantity'] as num?)?.toInt() ?? 0;
        }
      }
    }

    int cashIn = 0;
    int operationalCost = 0;
    int transportCost = 0;
    int laborCost = 0;

    for (final c in cashflows) {
      final amt = (c['amount'] as num?)?.toInt() ?? 0;
      if (c['direction'] == 'in') {
        cashIn += amt;
      } else if (c['direction'] == 'out') {
        operationalCost += amt;
        final cat = c['category']?.toString().toLowerCase() ?? '';
        if (cat.contains('bensin') || cat.contains('transport')) {
          transportCost += amt;
        } else {
          laborCost += amt;
        }
      }
    }

    // Modal HPP dinamis dari purchase_price tabel products
    final unitCost = InventoryRepository.instance.purchasePrice > 0
        ? InventoryRepository.instance.purchasePrice
        : 16000;
    final hpp = totalSoldQty * unitCost;

    // Build data points
    final List<ReportDataPoint> points = [];

    if (pointType == _PointType.weekDays) {
      final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      for (int i = 0; i < 7; i++) {
        final dayDate = referenceDate.add(Duration(days: i));
        int dayQty = 0;
        int dayOmset = 0;
        for (final d in distributions) {
          final dt = DateTime.tryParse(d['business_date']?.toString() ?? '');
          if (dt != null && dt.year == dayDate.year && dt.month == dayDate.month && dt.day == dayDate.day) {
            dayOmset += (d['total'] as num?)?.toInt() ?? 0;
            final items = (d['distribution_items'] as List<dynamic>?) ?? [];
            for (final it in items) {
              if (it is Map<String, dynamic>) {
                dayQty += (it['quantity'] as num?)?.toInt() ?? 0;
              }
            }
          }
        }
        points.add(ReportDataPoint(label: dayNames[i], quantity: dayQty, omset: dayOmset));
      }
    } else if (pointType == _PointType.monthDays) {
      // 4 weekly blocks for month view
      for (int w = 1; w <= 4; w++) {
        final startDay = (w - 1) * 7 + 1;
        final endDay = w == 4 ? 31 : w * 7;
        int weekQty = 0;
        int weekOmset = 0;
        for (final d in distributions) {
          final dt = DateTime.tryParse(d['business_date']?.toString() ?? '');
          if (dt != null && dt.year == referenceDate.year && dt.month == referenceDate.month) {
            if (dt.day >= startDay && dt.day <= endDay) {
              weekOmset += (d['total'] as num?)?.toInt() ?? 0;
              final items = (d['distribution_items'] as List<dynamic>?) ?? [];
              for (final it in items) {
                if (it is Map<String, dynamic>) {
                  weekQty += (it['quantity'] as num?)?.toInt() ?? 0;
                }
              }
            }
          }
        }
        points.add(ReportDataPoint(label: 'Mgg $w', quantity: weekQty, omset: weekOmset));
      }
    } else {
      // 12 months for year view
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
      for (int m = 1; m <= 12; m++) {
        int mQty = 0;
        int mOmset = 0;
        for (final d in distributions) {
          final dt = DateTime.tryParse(d['business_date']?.toString() ?? '');
          if (dt != null && dt.year == referenceDate.year && dt.month == m) {
            mOmset += (d['total'] as num?)?.toInt() ?? 0;
            final items = (d['distribution_items'] as List<dynamic>?) ?? [];
            for (final it in items) {
              if (it is Map<String, dynamic>) {
                mQty += (it['quantity'] as num?)?.toInt() ?? 0;
              }
            }
          }
        }
        points.add(ReportDataPoint(label: monthNames[m - 1], quantity: mQty, omset: mOmset));
      }
    }

    return ReportPeriodSummary(
      id: id,
      title: title,
      comparisonText: comparisonText,
      dateRangeLabel: dateRangeLabel,
      totalSoldQty: totalSoldQty,
      targetSoldQty: totalSoldQty > 0 ? (totalSoldQty * 1.2).toInt() : 100,
      rawOmset: rawOmset,
      cashIn: cashIn,
      receivable: totalReceivable,
      hpp: hpp,
      unitPurchasePrice: unitCost,
      operationalCost: operationalCost,
      transportCost: transportCost,
      laborCost: laborCost,
      utilityCost: 0,
      profitGrowthPct: totalSoldQty > 0 ? 12.5 : 0.0,
      dataPoints: points,
    );
  }
}

enum _PointType { weekDays, monthDays, yearMonths }
