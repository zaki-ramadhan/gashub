import 'package:flutter/material.dart';
import '../../../core/core.dart';
import 'price_setting_sheet.dart';
import 'restock_form_sheet.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Data status fisik LPG 3kg tunggal
  static const int _stockFilled = 340;
  static const int _stockEmpty = 120;
  static const int _stockLoaned = 140;

  static final DateTime _now = DateTime.now();
  static final DateTime _today = DateTime(_now.year, _now.month, _now.day);
  static final DateTime _yesterday = _today.subtract(const Duration(days: 1));
  static final DateTime _twoDaysAgo = _today.subtract(const Duration(days: 2));

  static final List<Map<String, dynamic>> _stockLogs = [
    // Hari Ini
    {
      'title': 'Kirim ke Warung Madura Pak Joko',
      'qty': 15,
      'isMasuk': false,
      'date': _today,
      'time': '14:30 WIB',
    },
    {
      'title': 'Kirim ke Toko Berkah Ibu',
      'qty': 20,
      'isMasuk': false,
      'date': _today,
      'time': '13:15 WIB',
    },
    {
      'title': 'Kirim ke Pangkalan Barokah',
      'qty': 30,
      'isMasuk': false,
      'date': _today,
      'time': '11:00 WIB',
    },
    {
      'title': 'Pasokan Masuk dari Truk Agen',
      'qty': 200,
      'isMasuk': true,
      'date': _today,
      'time': '09:15 WIB',
    },
    // Kemarin
    {
      'title': 'Kirim ke Warung Kelontong Bu Siti',
      'qty': 10,
      'isMasuk': false,
      'date': _yesterday,
      'time': '15:20 WIB',
    },
    {
      'title': 'Kirim ke Toko Sembako Berkah Jaya',
      'qty': 35,
      'isMasuk': false,
      'date': _yesterday,
      'time': '14:00 WIB',
    },
    {
      'title': 'Kirim ke RM Padang Sederhana',
      'qty': 25,
      'isMasuk': false,
      'date': _yesterday,
      'time': '11:10 WIB',
    },
    // 2 Hari Lalu
    {
      'title': 'Kirim ke Warung Makan Sumber Rejeki',
      'qty': 20,
      'isMasuk': false,
      'date': _twoDaysAgo,
      'time': '14:00 WIB',
    },
    {
      'title': 'Kirim ke Kios Gas Bu Nurul',
      'qty': 15,
      'isMasuk': false,
      'date': _twoDaysAgo,
      'time': '10:30 WIB',
    },
  ];

  String _formatDateHeader(DateTime date) {
    if (date.year == _today.year &&
        date.month == _today.month &&
        date.day == _today.day) {
      return 'Hari Ini, ${AppFormatters.date(date)}';
    } else if (date.year == _yesterday.year &&
        date.month == _yesterday.month &&
        date.day == _yesterday.day) {
      return 'Kemarin, ${AppFormatters.date(date)}';
    } else {
      return '${AppFormatters.dayOfWeek(date)}, ${AppFormatters.date(date)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group stock logs by date
    final Map<DateTime, List<Map<String, dynamic>>> grouped = {};
    for (final tx in _stockLogs) {
      final date = tx['date'] as DateTime;
      final dateKey = DateTime(date.year, date.month, date.day);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Gas'),
        actions: [
          IconButton(
            tooltip: 'Catat Pasokan',
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: () => RestockFormSheet.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.space16,
          AppDimensions.space8,
          AppDimensions.space16,
          96,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ringkasan Fisik Stok 3kg
            _buildStockHeroCard(context),
            const SizedBox(height: AppDimensions.space20),

            // 2. Riwayat Keluar Masuk Tabung Terkelompok Tanggal
            const Text(
              'Catatan Keluar Masuk Tabung',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.space4),

            ...sortedDates.map((dateKey) {
              final itemsForDay = grouped[dateKey]!;
              final masuk = itemsForDay
                  .where((tx) => tx['isMasuk'] == true)
                  .fold<int>(0, (sum, tx) => sum + (tx['qty'] as int));
              final keluar = itemsForDay
                  .where((tx) => tx['isMasuk'] == false)
                  .fold<int>(0, (sum, tx) => sum + (tx['qty'] as int));

              String summaryText;
              if (masuk > 0 && keluar > 0) {
                summaryText = 'Masuk $masuk | Keluar $keluar';
              } else if (masuk > 0) {
                summaryText = 'Masuk $masuk tabung';
              } else {
                summaryText = 'Keluar $keluar tabung';
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppDimensions.space12,
                      bottom: AppDimensions.space8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDateHeader(dateKey),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          summaryText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...itemsForDay.map((item) {
                    final isMasuk = item['isMasuk'] as bool;
                    final qty = item['qty'] as int;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                      child: FlatTransactionRow(
                        title: item['title'] as String,
                        subtitle: item['time'] as String,
                        amount: isMasuk ? '+$qty tabung' : '-$qty tabung',
                        amountColor: isMasuk
                            ? AppColors.brandSuccess
                            : AppColors.dangerText,
                        statusLabel: isMasuk ? 'Masuk' : 'Keluar',
                        statusType: isMasuk
                            ? BadgeType.success
                            : BadgeType.danger,
                        icon: isMasuk ? Icons.south_west : Icons.north_east,
                        iconColor: AppColors.brandPrimary,
                        iconBg: AppColors.canvas,
                      ),
                    );
                  }),
                ],
              );
            }),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }

  Widget _buildStockHeroCard(BuildContext context) {
    const totalTabung = _stockFilled + _stockEmpty + _stockLoaned;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Semua Tabung Milik Pangkalan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Harga Jual: Rp 19.000 / tabung',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        InkWell(
                          onTap: () => PriceSettingSheet.show(context),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              'Ubah',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.brandPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.space16),

          // 3 Kolom Posisi Fisik Tabung
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Isi di Rumah',
                  count: '$_stockFilled',
                  sub: 'Siap dikirim',
                  color: AppColors.brandPrimary,
                ),
              ),
              Container(width: 1, height: 44, color: AppColors.border),
              Expanded(
                child: _buildMetricTile(
                  label: 'Kosong di Rumah',
                  count: '$_stockEmpty',
                  sub: 'Nunggu truk',
                  color: AppColors.warningText,
                ),
              ),
              Container(width: 1, height: 44, color: AppColors.border),
              Expanded(
                child: _buildMetricTile(
                  label: 'Ada di Pelanggan',
                  count: '$_stockLoaned',
                  sub: 'Sedang dipinjam',
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          // Keterangan Gamblang Untuk Ibu / Ortu Awam
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total kepemilikan tabung besi pangkalan: $_stockFilled isi + $_stockEmpty kosong + $_stockLoaned di pelanggan = $totalTabung tabung.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String count,
    required String sub,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          sub,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
