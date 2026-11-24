import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/customer_model.dart';

/// Clean, flat divided summary row showing Sisa Utang and Total Order.
class CustomerDetailSummaryRow extends StatelessWidget {
  const CustomerDetailSummaryRow({
    super.key,
    required this.customer,
    required this.onPayDebt,
  });

  final CustomerModel customer;
  final VoidCallback onPayDebt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Sisa Utang
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sisa Utang',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                customer.hasDebt
                    ? AppFormatters.currency(customer.activeDebt)
                    : 'Lunas',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  color: customer.hasDebt
                      ? AppColors.dangerText
                      : AppColors.brandPrimary,
                ),
              ),
              if (customer.hasDebt) ...[
                const SizedBox(height: 6),
                Skeleton.ignore(
                  child: InkWell(
                    onTap: onPayDebt,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandAccent,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                      ),
                      child: const Text(
                        'Bayar Lunas',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Vertical Divider
        Container(
          height: 48,
          width: 1,
          color: AppColors.border,
        ),
        const SizedBox(width: AppDimensions.space16),

        // 2. Total Tabung
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Tabung',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${customer.totalCylinders} tabung',
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${customer.totalOrders} nota',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

