import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Payment status (Lunas vs Bon) and optional DP/partial payment.
class DistributionPaymentSection extends StatelessWidget {
  const DistributionPaymentSection({
    super.key,
    required this.isPaid,
    required this.onPaidChanged,
    required this.paidAmountController,
    required this.remainingDebt,
    required this.onAmountChanged,
  });

  final bool isPaid;
  final ValueChanged<bool> onPaidChanged;
  final TextEditingController paidAmountController;
  final int remainingDebt;
  final VoidCallback onAmountChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Status Pembayaran
        const Text(
          'Status Pembayaran',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildOptionButton(
                label: 'Lunas',
                isSelected: isPaid,
                onTap: () => onPaidChanged(true),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: _buildOptionButton(
                label: 'Bon / Belum Lunas',
                isSelected: !isPaid,
                onTap: () {
                  if (paidAmountController.text.isEmpty || paidAmountController.text == '0') {
                    paidAmountController.text = '0';
                  }
                  onPaidChanged(false);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space16),

        // 2. Input Uang Muka / Sebagian jika status Bon
        if (!isPaid) ...[
          const InputLabel(
            label: 'Uang Diterima Sekarang (DP / Sebagian)',
            isRequired: true,
          ),
          const SizedBox(height: 8),
          Focus(
            onFocusChange: (hasFocus) {
              AppInputFormatters.clampOnBlur(
                controller: paidAmountController,
                hasFocus: hasFocus,
                min: 0,
                onClamped: onAmountChanged,
              );
            },
            child: TextFormField(
              controller: paidAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [AppInputFormatters.thousands],
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 6),
                  child: Text(
                    'Rp ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: '0',
                helperText: 'Sisa utang pelanggan: ${AppFormatters.currency(remainingDebt)}',
                helperStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.dangerText,
                  fontWeight: FontWeight.w500,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (_) => onAmountChanged(),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
        ],
      ],
    );
  }

  Widget _buildOptionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lime : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          border: Border.all(
            color: isSelected ? AppColors.forestGreen.withValues(alpha: 0.5) : AppColors.border,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

