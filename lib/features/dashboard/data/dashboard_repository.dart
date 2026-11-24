import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/cashflow_entry_model.dart';
import '../domain/cashflow_summary.dart';

/// Repository managing dashboard cashflow metrics and operational expenses via Supabase PostgreSQL.
class DashboardRepository {
  DashboardRepository._();
  static final DashboardRepository instance = DashboardRepository._();

  final ValueNotifier<CashflowSummary> cashflowSummaryNotifier =
      ValueNotifier<CashflowSummary>(const CashflowSummary.zero());

  final ValueNotifier<List<CashflowEntryModel>> cashflowEntriesNotifier =
      ValueNotifier<List<CashflowEntryModel>>([]);

  Future<void> fetchDashboardMetrics() async {
    try {
      final client = Supabase.instance.client;
      final res = await client.from('cashflow_entries').select('amount, direction, business_date');

      int totalIn = 0;
      int totalOut = 0;

      for (final row in res as List<dynamic>) {
        final m = row as Map<String, dynamic>;
        final amt = (m['amount'] as num?)?.toInt() ?? 0;
        if (m['direction'] == 'in') {
          totalIn += amt;
        } else if (m['direction'] == 'out') {
          totalOut += amt;
        }
      }

      cashflowSummaryNotifier.value = CashflowSummary(
        netCashflow: totalIn - totalOut,
        cashIn: totalIn,
        cashOut: totalOut,
      );
    } catch (e) {
      debugPrint('Error fetching dashboard cashflow from Supabase: $e');
    }
  }

  Future<void> fetchCashflowEntries() async {
    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('cashflow_entries')
          .select('id, direction, category, source_type, source_id, business_date, created_at, amount, method, notes')
          .order('business_date', ascending: false)
          .order('created_at', ascending: false);

      final List<CashflowEntryModel> entries = [];
      for (final row in res as List<dynamic>) {
        entries.add(CashflowEntryModel.fromJson(row as Map<String, dynamic>));
      }
      cashflowEntriesNotifier.value = entries;
    } catch (e) {
      debugPrint('Error fetching cashflow entries from Supabase: $e');
    }
  }

  Future<void> recordExpense({
    required int amount,
    required String notes,
    String category = 'operations',
    String method = 'cash',
  }) async {
    try {
      final client = Supabase.instance.client;
      final today = DateTime.now().toIso8601String().split('T')[0];

      await client.from('cashflow_entries').insert({
        'direction': 'out',
        'category': category,
        'source_type': 'expense',
        'source_id': null,
        'business_date': today,
        'amount': amount,
        'method': method,
        'notes': notes,
      });

      await Future.wait([
        fetchDashboardMetrics(),
        fetchCashflowEntries(),
      ]);
    } catch (e) {
      debugPrint('Error recording expense in Supabase: $e');
      rethrow;
    }
  }
}
