import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Large stepper and quick-preset buttons for elderly-friendly quantity input.
class DistributionQuantityStepper extends StatelessWidget {
  const DistributionQuantityStepper({
    super.key,
    required this.controller,
    required this.unitPrice,
    required this.availableStock,
    required this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final int unitPrice;
  final int availableStock;
  final VoidCallback onChanged;
  final String? errorText;

  int get _qty => AppInputFormatters.parseQuantity(controller.text, min: 1, defaultValue: 1);

  void _setQty(int value) {
    final clamped = value.clamp(1, 9999);
    controller.text = AppFormatters.number(clamped);
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final isStockLow = availableStock > 0 && _qty > availableStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InputLabel(
          label: 'Jumlah Tabung Gas',
          isRequired: true,
        ),
        const SizedBox(height: 8),

        // Stepper Control: [-] [ Display / Input ] [+]
        Row(
          children: [
            _buildStepButton(
              icon: Icons.remove,
              onTap: () => _setQty(_qty - 1),
              enabled: _qty > 1,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  AppInputFormatters.clampOnBlur(
                    controller: controller,
                    hasFocus: hasFocus,
                    min: 1,
                    onClamped: onChanged,
                  );
                },
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [AppInputFormatters.thousands],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    isDense: true,
                    errorText: errorText,
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildStepButton(
              icon: Icons.add,
              onTap: () => _setQty(_qty + 1),
              enabled: true,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Preset Chips: 5, 10, 15, 20, 30 tabung
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [5, 10, 15, 20, 30].map((preset) {
              final isSelected = _qty == preset;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => _setQty(preset),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.lime : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                      border: Border.all(
                        color: isSelected ? AppColors.forestGreen.withValues(alpha: 0.5) : AppColors.border,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      '$preset tabung',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Stock Guardrail Warning
        if (isStockLow) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFD97706)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Perhatian: Sisa stok gas isi di gudang hanya $availableStock tabung',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 4),
          Text(
            'Harga: ${AppFormatters.currency(unitPrice)} / tabung',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Material(
      color: enabled ? AppColors.canvas : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            border: Border.all(
              color: enabled ? AppColors.border : AppColors.border.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          ),
          child: Icon(
            icon,
            size: 22,
            color: enabled ? AppColors.textPrimary : AppColors.textMuted.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

