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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Gas 3kg'),
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

            // 2. Riwayat Keluar Masuk Tabung
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catatan Keluar Masuk Tabung',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Hari ini',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space10),

            FlatTransactionRow(
              title: 'Kirim ke Warung Madura Pak Joko',
              subtitle: '14:30 WIB',
              amount: '-15 tabung',
              amountColor: AppColors.dangerText,
              statusLabel: 'Keluar',
              statusType: BadgeType.danger,
              icon: Icons.arrow_upward,
              iconColor: AppColors.dangerText,
              iconBg: const Color(0xFFFEE2E2),
              onTap: () {},
            ),
            const SizedBox(height: AppDimensions.space8),

            FlatTransactionRow(
              title: 'Pasokan Masuk dari Agen',
              subtitle: '09:15 WIB',
              amount: '+200 tabung',
              amountColor: AppColors.brandPrimary,
              statusLabel: 'Masuk',
              statusType: BadgeType.success,
              icon: Icons.arrow_downward,
              iconColor: AppColors.brandPrimary,
              iconBg: AppColors.brandAccent,
              onTap: () {},
            ),
            const SizedBox(height: AppDimensions.space8),

            FlatTransactionRow(
              title: 'Kirim ke Toko Berkah Ibu',
              subtitle: '13:15 WIB',
              amount: '-20 tabung',
              amountColor: AppColors.dangerText,
              statusLabel: 'Keluar',
              statusType: BadgeType.danger,
              icon: Icons.arrow_upward,
              iconColor: AppColors.dangerText,
              iconBg: const Color(0xFFFEE2E2),
              onTap: () {},
            ),
            const SizedBox(height: AppDimensions.space8),

            FlatTransactionRow(
              title: 'Kirim ke Pangkalan Barokah',
              subtitle: '11:00 WIB',
              amount: '-30 tabung',
              amountColor: AppColors.dangerText,
              statusLabel: 'Keluar',
              statusType: BadgeType.danger,
              icon: Icons.arrow_upward,
              iconColor: AppColors.dangerText,
              iconBg: const Color(0xFFFEE2E2),
              onTap: () {},
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }

  Widget _buildStockHeroCard(BuildContext context) {
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
                      'Gas 3kg (Subsidi)',
                      style: TextStyle(
                        fontSize: 16,
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
                          'Harga Jual: Rp 19.000',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandAccent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
                child: const Text(
                  'Total: 600 Tabung',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.space16),

          // 3 Kolom Metrik Fisik Tabung
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Tabung Isi',
                  count: '$_stockFilled',
                  sub: 'Siap jual',
                  color: AppColors.brandPrimary,
                ),
              ),
              Container(width: 1, height: 44, color: AppColors.border),
              Expanded(
                child: _buildMetricTile(
                  label: 'Tabung Kosong',
                  count: '$_stockEmpty',
                  sub: 'Di toko',
                  color: AppColors.warningText,
                ),
              ),
              Container(width: 1, height: 44, color: AppColors.border),
              Expanded(
                child: _buildMetricTile(
                  label: 'Di Luar Toko',
                  count: '$_stockLoaned',
                  sub: 'Di warung',
                  color: AppColors.textPrimary,
                ),
              ),
            ],
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
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
