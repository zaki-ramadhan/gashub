import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/distribution_model.dart';
import 'cancel_distribution_dialog.dart';
import 'sale_detail_financial_section.dart';
import 'sale_detail_info_section.dart';
import 'sale_detail_items_section.dart';

/// Streamlined modal bottom sheet displaying a gas sales receipt.
/// Uses the standardized AppBottomSheet container for consistent padding and drag handle.
class SaleDetailSheet extends StatelessWidget {
  const SaleDetailSheet({super.key, required this.sale});

  final DistributionModel sale;

  static Future<void> show(BuildContext context, DistributionModel sale) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SaleDetailSheet(sale: sale),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Rincian Penjualan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SaleDetailInfoSection(sale: sale),
          const Divider(height: 20, thickness: 1, color: AppColors.border),
          SaleDetailItemsSection(sale: sale),
          const Divider(height: 20, thickness: 1, color: AppColors.border),
          SaleDetailFinancialSection(sale: sale),
          const SizedBox(height: AppDimensions.space16),

          // Destructive action: Batalkan Transaksi
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => CancelDistributionDialog.show(context, sale),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 11),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                ),
              ),
              child: const Text(
                'Batalkan Transaksi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dangerText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
