import '../domain/report_models.dart';

/// Repository providing calculated report datasets for various operating periods.
class ReportsData {
  const ReportsData._();

  // -------------------------------------------------------------
  // 1. TAHUN (Annual Data)
  // -------------------------------------------------------------
  static const ReportPeriodSummary year2026 = ReportPeriodSummary(
    id: 'year_2026',
    title: 'Tahun 2026',
    comparisonText: 'vs. Tahun 2025 (+14.8%)',
    dateRangeLabel: '1 Jan – 31 Des 2026',
    totalSoldQty: 27450,
    targetSoldQty: 30000,
    rawOmset: 521550000,
    cashIn: 497550000,
    receivable: 24000000,
    hpp: 432337500, // 27.450 * 15.750
    operationalCost: 32500000,
    transportCost: 12000000,
    laborCost: 14500000,
    utilityCost: 6000000,
    profitGrowthPct: 14.8,
    dataPoints: [
      ReportDataPoint(label: 'Jan', quantity: 2100, omset: 39900000),
      ReportDataPoint(label: 'Feb', quantity: 1950, omset: 37050000),
      ReportDataPoint(label: 'Mar', quantity: 2300, omset: 43700000),
      ReportDataPoint(label: 'Apr', quantity: 2500, omset: 47500000),
      ReportDataPoint(label: 'Mei', quantity: 2450, omset: 46550000),
      ReportDataPoint(label: 'Jun', quantity: 2200, omset: 41800000),
      ReportDataPoint(label: 'Jul', quantity: 2150, omset: 40850000),
      ReportDataPoint(label: 'Agt', quantity: 2400, omset: 45600000),
      ReportDataPoint(label: 'Sep', quantity: 2250, omset: 42750000),
      ReportDataPoint(label: 'Okt', quantity: 2350, omset: 44650000),
      ReportDataPoint(label: 'Nov', quantity: 2200, omset: 41800000),
      ReportDataPoint(label: 'Des', quantity: 2600, omset: 49400000),
    ],
  );

  static const ReportPeriodSummary year2025 = ReportPeriodSummary(
    id: 'year_2025',
    title: 'Tahun 2025',
    comparisonText: 'vs. Tahun 2024 (+10.2%)',
    dateRangeLabel: '1 Jan – 31 Des 2025',
    totalSoldQty: 25100,
    targetSoldQty: 28000,
    rawOmset: 476900000,
    cashIn: 448900000,
    receivable: 28000000,
    hpp: 395325000,
    operationalCost: 30000000,
    transportCost: 11000000,
    laborCost: 13500000,
    utilityCost: 5500000,
    profitGrowthPct: 10.2,
    dataPoints: [
      ReportDataPoint(label: 'Jan', quantity: 1900, omset: 36100000),
      ReportDataPoint(label: 'Feb', quantity: 1850, omset: 35150000),
      ReportDataPoint(label: 'Mar', quantity: 2100, omset: 39900000),
      ReportDataPoint(label: 'Apr', quantity: 2250, omset: 42750000),
      ReportDataPoint(label: 'Mei', quantity: 2200, omset: 41800000),
      ReportDataPoint(label: 'Jun', quantity: 2000, omset: 38000000),
      ReportDataPoint(label: 'Jul', quantity: 1950, omset: 37050000),
      ReportDataPoint(label: 'Agt', quantity: 2200, omset: 41800000),
      ReportDataPoint(label: 'Sep', quantity: 2100, omset: 39900000),
      ReportDataPoint(label: 'Okt', quantity: 2200, omset: 41800000),
      ReportDataPoint(label: 'Nov', quantity: 2050, omset: 38950000),
      ReportDataPoint(label: 'Des', quantity: 2300, omset: 43700000),
    ],
  );

  static const ReportPeriodSummary year2024 = ReportPeriodSummary(
    id: 'year_2024',
    title: 'Tahun 2024',
    comparisonText: 'vs. Tahun 2023 (+15.2%)',
    dateRangeLabel: '1 Jan – 31 Des 2024',
    totalSoldQty: 23200,
    targetSoldQty: 25000,
    rawOmset: 440800000,
    cashIn: 410800000,
    receivable: 30000000,
    hpp: 365400000,
    operationalCost: 28500000,
    transportCost: 10500000,
    laborCost: 13000000,
    utilityCost: 5000000,
    profitGrowthPct: 15.2,
    dataPoints: [
      ReportDataPoint(label: 'Jan', quantity: 1750, omset: 33250000),
      ReportDataPoint(label: 'Feb', quantity: 1700, omset: 32300000),
      ReportDataPoint(label: 'Mar', quantity: 1950, omset: 37050000),
      ReportDataPoint(label: 'Apr', quantity: 2050, omset: 38950000),
      ReportDataPoint(label: 'Mei', quantity: 2100, omset: 39900000),
      ReportDataPoint(label: 'Jun', quantity: 1850, omset: 35150000),
      ReportDataPoint(label: 'Jul', quantity: 1800, omset: 34200000),
      ReportDataPoint(label: 'Agt', quantity: 2050, omset: 38950000),
      ReportDataPoint(label: 'Sep', quantity: 1950, omset: 37050000),
      ReportDataPoint(label: 'Okt', quantity: 2000, omset: 38000000),
      ReportDataPoint(label: 'Nov', quantity: 1900, omset: 36100000),
      ReportDataPoint(label: 'Des', quantity: 2100, omset: 39900000),
    ],
  );

  // -------------------------------------------------------------
  // 2. BULAN (Monthly Data)
  // -------------------------------------------------------------
  static const ReportPeriodSummary monthOct2026 = ReportPeriodSummary(
    id: 'month_oct_2026',
    title: 'Oktober 2026',
    comparisonText: 'vs. September 2026 (+4.4%)',
    dateRangeLabel: '1 Okt – 31 Okt 2026',
    totalSoldQty: 2350,
    targetSoldQty: 2500,
    rawOmset: 44650000,
    cashIn: 40650000,
    receivable: 4000000,
    hpp: 37012500,
    operationalCost: 2850000,
    transportCost: 1050000,
    laborCost: 1250000,
    utilityCost: 550000,
    profitGrowthPct: 4.4,
    dataPoints: [
      ReportDataPoint(label: 'Mgg 1', quantity: 580, omset: 11020000),
      ReportDataPoint(label: 'Mgg 2', quantity: 620, omset: 11780000),
      ReportDataPoint(label: 'Mgg 3', quantity: 540, omset: 10260000),
      ReportDataPoint(label: 'Mgg 4', quantity: 610, omset: 11590000),
    ],
  );

  static const ReportPeriodSummary monthSep2026 = ReportPeriodSummary(
    id: 'month_sep_2026',
    title: 'September 2026',
    comparisonText: 'vs. Agustus 2026 (-6.2%)',
    dateRangeLabel: '1 Sep – 30 Sep 2026',
    totalSoldQty: 2250,
    targetSoldQty: 2500,
    rawOmset: 42750000,
    cashIn: 38250000,
    receivable: 4500000,
    hpp: 35437500,
    operationalCost: 2750000,
    transportCost: 1000000,
    laborCost: 1200000,
    utilityCost: 550000,
    profitGrowthPct: -6.2,
    dataPoints: [
      ReportDataPoint(label: 'Mgg 1', quantity: 540, omset: 10260000),
      ReportDataPoint(label: 'Mgg 2', quantity: 570, omset: 10830000),
      ReportDataPoint(label: 'Mgg 3', quantity: 560, omset: 10640000),
      ReportDataPoint(label: 'Mgg 4', quantity: 580, omset: 11020000),
    ],
  );

  static const ReportPeriodSummary monthAug2026 = ReportPeriodSummary(
    id: 'month_aug_2026',
    title: 'Agustus 2026',
    comparisonText: 'vs. Juli 2026 (+11.6%)',
    dateRangeLabel: '1 Agt – 31 Agt 2026',
    totalSoldQty: 2400,
    targetSoldQty: 2500,
    rawOmset: 45600000,
    cashIn: 41600000,
    receivable: 4000000,
    hpp: 37800000,
    operationalCost: 2900000,
    transportCost: 1100000,
    laborCost: 1250000,
    utilityCost: 550000,
    profitGrowthPct: 11.6,
    dataPoints: [
      ReportDataPoint(label: 'Mgg 1', quantity: 590, omset: 11210000),
      ReportDataPoint(label: 'Mgg 2', quantity: 610, omset: 11590000),
      ReportDataPoint(label: 'Mgg 3', quantity: 580, omset: 11020000),
      ReportDataPoint(label: 'Mgg 4', quantity: 620, omset: 11780000),
    ],
  );

  // -------------------------------------------------------------
  // 3. MINGGU (Weekly Data)
  // -------------------------------------------------------------
  static const ReportPeriodSummary week4Oct = ReportPeriodSummary(
    id: 'week_4_oct',
    title: 'Minggu 4 Okt 2026',
    comparisonText: 'vs. Minggu 3 (+13.0%)',
    dateRangeLabel: '22 Okt – 28 Okt 2026',
    totalSoldQty: 610,
    targetSoldQty: 650,
    rawOmset: 11590000,
    cashIn: 10390000,
    receivable: 1200000,
    hpp: 9607500,
    operationalCost: 720000,
    transportCost: 280000,
    laborCost: 320000,
    utilityCost: 120000,
    profitGrowthPct: 13.0,
    dataPoints: [
      ReportDataPoint(label: 'Sen', quantity: 85, omset: 1615000),
      ReportDataPoint(label: 'Sel', quantity: 95, omset: 1805000),
      ReportDataPoint(label: 'Rab', quantity: 90, omset: 1710000),
      ReportDataPoint(label: 'Kam', quantity: 105, omset: 1995000),
      ReportDataPoint(label: 'Jum', quantity: 115, omset: 2185000),
      ReportDataPoint(label: 'Sab', quantity: 80, omset: 1520000),
      ReportDataPoint(label: 'Min', quantity: 40, omset: 760000),
    ],
  );

  static const ReportPeriodSummary week3Oct = ReportPeriodSummary(
    id: 'week_3_oct',
    title: 'Minggu 3 Okt 2026',
    comparisonText: 'vs. Minggu 2 (-12.9%)',
    dateRangeLabel: '15 Okt – 21 Okt 2026',
    totalSoldQty: 540,
    targetSoldQty: 600,
    rawOmset: 10260000,
    cashIn: 9260000,
    receivable: 1000000,
    hpp: 8505000,
    operationalCost: 680000,
    transportCost: 260000,
    laborCost: 300000,
    utilityCost: 120000,
    profitGrowthPct: -12.9,
    dataPoints: [
      ReportDataPoint(label: 'Sen', quantity: 75, omset: 1425000),
      ReportDataPoint(label: 'Sel', quantity: 80, omset: 1520000),
      ReportDataPoint(label: 'Rab', quantity: 75, omset: 1425000),
      ReportDataPoint(label: 'Kam', quantity: 95, omset: 1805000),
      ReportDataPoint(label: 'Jum', quantity: 105, omset: 1995000),
      ReportDataPoint(label: 'Sab', quantity: 75, omset: 1425000),
      ReportDataPoint(label: 'Min', quantity: 35, omset: 665000),
    ],
  );

  // -------------------------------------------------------------
  // 4. SEMUA WAKTU (All Time Data)
  // -------------------------------------------------------------
  static const ReportPeriodSummary allTime = ReportPeriodSummary(
    id: 'all_time',
    title: 'Semua Waktu',
    comparisonText: 'Akumulasi Sejak Toko Buka',
    dateRangeLabel: '2023 – 2026',
    totalSoldQty: 94250,
    targetSoldQty: 100000,
    rawOmset: 1790750000,
    cashIn: 1708750000,
    receivable: 82000000,
    hpp: 1484437500,
    operationalCost: 120000000,
    transportCost: 45000000,
    laborCost: 55000000,
    utilityCost: 20000000,
    profitGrowthPct: 19.5,
    dataPoints: [
      ReportDataPoint(label: '2023', quantity: 18500, omset: 351500000),
      ReportDataPoint(label: '2024', quantity: 23200, omset: 440800000),
      ReportDataPoint(label: '2025', quantity: 25100, omset: 476900000),
      ReportDataPoint(label: '2026', quantity: 27450, omset: 521550000),
    ],
  );

  /// Get period summaries available for a given tab index
  /// 0: Minggu, 1: Bulan, 2: Tahun, 3: Semua
  static List<ReportPeriodSummary> getOptionsForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return [week4Oct, week3Oct];
      case 1:
        return [monthOct2026, monthSep2026, monthAug2026];
      case 2:
        return [year2026, year2025, year2024];
      case 3:
      default:
        return [allTime];
    }
  }
}
