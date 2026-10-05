import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Stock hero card summarizing total depot-owned LPG 3kg cylinders.
class InventoryStockCard extends StatelessWidget {
  const InventoryStockCard({
    super.key,
    required this.stockFilled,
    required this.stockEmpty,
    required this.stockLoaned,
    required this.sellingPrice,
    required this.onEditPrice,
  });

  final int stockFilled;
  final int stockEmpty;
  final int stockLoaned;
  final int sellingPrice;
  final VoidCallback onEditPrice;

  @override
  Widget build(BuildContext context) {
    final totalTabung = stockFilled + stockEmpty + stockLoaned;

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
                        Text(
                          'Harga Jual: ${AppFormatters.currency(sellingPrice)} / tabung',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Skeleton.ignore(
                          child: InkWell(
                            onTap: onEditPrice,
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
                  count: '$stockFilled',
                  sub: 'Siap dikirim',
                  color: AppColors.brandPrimary,
                ),
              ),
              Container(width: 1, height: 44, color: AppColors.border),
              Expanded(
                child: _buildMetricTile(
                  label: 'Kosong di Rumah',
                  count: '$stockEmpty',
                  sub: 'Nunggu truk',
                  color: AppColors.warningText,
                ),
              ),
              Container(width: 1, height: 44, color: AppColors.border),
              Expanded(
                child: _buildMetricTile(
                  label: 'Ada di Pelanggan',
                  count: '$stockLoaned',
                  sub: 'Sedang dipinjam',
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          // Keterangan Gamblang Untuk Pengguna Awam
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
                    'Total kepemilikan tabung besi pangkalan: $stockFilled isi + $stockEmpty kosong + $stockLoaned di pelanggan = $totalTabung tabung.',
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
