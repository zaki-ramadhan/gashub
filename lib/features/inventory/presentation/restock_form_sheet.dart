import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/inventory_repository.dart';

/// Modal bottom sheet for recording incoming LPG 3kg supply from Pertamina / Agen.
/// Styled with unified stepper input and clean raw text summaries (anti-card slop).
class RestockFormSheet extends StatefulWidget {
  const RestockFormSheet({super.key, this.onBack});

  final VoidCallback? onBack;

  static Future<void> show(BuildContext context, {VoidCallback? onBack}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RestockFormSheet(onBack: onBack),
    );
  }

  @override
  State<RestockFormSheet> createState() => _RestockFormSheetState();
}

class _RestockFormSheetState extends State<RestockFormSheet> {
  final TextEditingController _qtyController = TextEditingController(text: '200');
  final TextEditingController _notesController = TextEditingController();
  int get _costPerUnit => InventoryRepository.instance.purchasePrice;
  bool _isLoading = false;
  String? _qtyError;

  int get _qty => AppInputFormatters.parseQuantity(_qtyController.text, min: 1, defaultValue: 1);

  void _setQty(int value) {
    final clamped = value.clamp(1, 9999);
    _qtyController.text = AppFormatters.number(clamped);
    _qtyController.selection = TextSelection.collapsed(offset: _qtyController.text.length);
    if (_qtyError != null) _qtyError = null;
    setState(() {});
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final parsedQty = AppInputFormatters.parseNumber(_qtyController.text);
    if (parsedQty <= 0) {
      setState(() => _qtyError = 'Jumlah tabung minimal 1');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final reason = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : 'Penerimaan pasokan SPPBE';
      await InventoryRepository.instance.recordRestock(
        quantity: _qty,
        reason: reason,
      );
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      AppToast.success(title: 'Pasokan berhasil disimpan');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(title: 'Gagal menyimpan pasokan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = _qty * _costPerUnit;

    return AppBottomSheet(
      title: 'Catat Pasokan Gas',
      onBack: widget.onBack,
      bottomAction: AppButton(
        text: 'Simpan Pasokan',
        isLoading: _isLoading,
        onPressed: _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Info Subtitle
          const Text(
            'Penerimaan pasokan tabung LPG 3kg dari Agen Pertamina.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 2. Stepper Jumlah Tabung (Identik dengan Catat Penjualan Gas)
          const InputLabel(
            label: 'Jumlah Tabung Diterima',
            isRequired: true,
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildStepButton(
                icon: Icons.remove,
                onTap: () => _setQty(_qty - 10),
                enabled: _qty > 10,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Focus(
                  onFocusChange: (hasFocus) {
                    AppInputFormatters.clampOnBlur(
                      controller: _qtyController,
                      hasFocus: hasFocus,
                      min: 1,
                      onClamped: () => setState(() {}),
                    );
                  },
                  child: TextFormField(
                    controller: _qtyController,
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
                      errorText: _qtyError,
                    ),
                    onChanged: (_) {
                      if (_qtyError != null) setState(() => _qtyError = null);
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildStepButton(
                icon: Icons.add,
                onTap: () => _setQty(_qty + 10),
                enabled: true,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Preset Chips Kulakan: 50, 100, 200, 300, 560 tabung (ukuran umum pangkalan/truk)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [50, 100, 200, 300, 560].map((preset) {
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
          const SizedBox(height: AppDimensions.space16),

          // 3. Raw Text Ringkasan Biaya Kulakan (Bukan Card, flat divided clean lines)
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Harga Tebus Agen',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              Text(
                '${AppFormatters.currency(_costPerUnit)} / tabung',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pengeluaran Beli',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                AppFormatters.currency(totalCost),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.space16),

          // 4. Catatan Pasokan
          const InputLabel(
            label: 'Catatan Pasokan (Opsional)',
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            inputFormatters: [AppInputFormatters.cleanText],
            maxLines: 2,
          ),
        ],
      ),
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
            size: 20,
            color: enabled ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
