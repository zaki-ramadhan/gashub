import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/distribution_model.dart';

/// Streamlined customer & metadata row with auto-capitalized name and compact status.
class SaleDetailInfoSection extends StatelessWidget {
  const SaleDetailInfoSection({super.key, required this.sale});

  final DistributionModel sale;

  String _formatCustomerName(String name) {
    if (name.trim().isEmpty) return '-';
    return name
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomNotes = sale.notes.isNotEmpty &&
        !sale.notes.contains('Penjualan Bon') &&
        !sale.notes.contains('Penjualan Lunas');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Pelanggan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pelanggan',
              style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatCustomerName(sale.customerName),
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 2. Waktu & Status Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${AppFormatters.date(sale.date)}, ${sale.time}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              label: sale.statusLabel,
              type: sale.statusType,
            ),
          ],
        ),

        // 3. Catatan Khusus (jika ada)
        if (hasCustomNotes) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catatan',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sale.notes,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
