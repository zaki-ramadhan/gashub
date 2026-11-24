import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/distribution_model.dart';

/// Flat list of ordered gas cylinders without redundant section headers.
class SaleDetailItemsSection extends StatelessWidget {
  const SaleDetailItemsSection({super.key, required this.sale});

  final DistributionModel sale;

  String _cleanProductName(String rawName) {
    if (rawName.toLowerCase().contains('3kg') || rawName.toLowerCase().contains('3 kg')) {
      return 'LPG 3 kg';
    }
    return rawName;
  }

  @override
  Widget build(BuildContext context) {
    if (sale.items.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${sale.qty}x Tabung LPG 3 kg',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            AppFormatters.currency(sale.amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sale.items.map((it) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${it.quantity}x ${_cleanProductName(it.productName)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@ ${AppFormatters.currency(it.unitPrice)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppFormatters.currency(it.subtotalSales),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
