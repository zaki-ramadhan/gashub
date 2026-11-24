import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Stock hero card designed for quick depot operations:
/// - Prominent ready-to-sell gas count
/// - Selling price with quick "Ubah" action
/// - Clean bottom split: Tabung Kosong (siap tukar agen) vs Tabung di Pelanggan (dipinjam)
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
          // 1. Header: Label + Harga Jual (Ubah)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gas Siap Jual Hari Ini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Harga: ${AppFormatters.currency(sellingPrice)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Skeleton.ignore(
                    child: InkWell(
                      onTap: onEditPrice,
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          'Ubah',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
          const SizedBox(height: 6),

          // 2. Hero Metric: Jumlah Tabung Isi Siap Jual
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${AppFormatters.number(stockFilled)} tabung',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.brandPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.space12),

          // 3. Sub-metrics: Tabung Kosong vs Di Pelanggan
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tabung Kosong',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppFormatters.number(stockEmpty)} tabung',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.border),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Di Pelanggan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppFormatters.number(stockLoaned)} tabung',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
