import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// Modal bottom sheet for changing LPG 3kg selling and purchase prices.
class PriceSettingSheet extends StatefulWidget {
  const PriceSettingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PriceSettingSheet(),
    );
  }

  @override
  State<PriceSettingSheet> createState() => _PriceSettingSheetState();
}

class _PriceSettingSheetState extends State<PriceSettingSheet> {
  final _sellingPriceController = TextEditingController(text: AppFormatters.number(19000));
  final _purchasePriceController = TextEditingController(text: AppFormatters.number(15750));

  bool _isLoading = false;

  int get _sellingPrice => AppInputFormatters.parseNumber(_sellingPriceController.text);
  int get _purchasePrice => AppInputFormatters.parseNumber(_purchasePriceController.text);
  int get _margin => _sellingPrice - _purchasePrice;

  @override
  void dispose() {
    _sellingPriceController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  Future<void> _savePrice() async {
    if (_sellingPrice <= 0 || _purchasePrice <= 0) {
      AppToast.warning(title: 'Harga harus lebih dari 0');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
    AppToast.success(title: 'Harga berhasil disimpan');
  }

  @override
  Widget build(BuildContext context) {
    final marginPercent = _sellingPrice > 0 ? ((_margin / _sellingPrice) * 100).toStringAsFixed(1) : '0';

    return AppBottomSheet(
      title: 'Atur Harga Gas',
      bottomAction: AppButton(
        text: 'Simpan Harga',
        isLoading: _isLoading,
        onPressed: _savePrice,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Info Sederhana
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
                SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Text(
                    'Harga acuan saat mencatat penjualan dan penerimaan pasokan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 2. Input Harga Jual Gas
          const Text(
            'Harga Jual Gas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Harga jual per tabung ke pelanggan.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.space8),
          TextFormField(
            controller: _sellingPriceController,
            keyboardType: TextInputType.number,
            inputFormatters: [AppInputFormatters.thousands],
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 3. Input Harga Modal Beli
          const Text(
            'Harga Modal Beli',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Harga tebus per tabung dari agen.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.space8),
          TextFormField(
            controller: _purchasePriceController,
            keyboardType: TextInputType.number,
            inputFormatters: [AppInputFormatters.thousands],
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 4. Kalkulator Keuntungan Langsung
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: _margin >= 0 ? AppColors.brandAccent : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              border: Border.all(
                color: _margin >= 0 ? AppColors.brandSuccess.withValues(alpha: 0.3) : AppColors.dangerText.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _margin >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: _margin >= 0 ? AppColors.brandSuccess : AppColors.dangerText,
                  size: 24,
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _margin >= 0 ? 'Keuntungan per Tabung' : 'Rugi per Tabung',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _margin >= 0 ? AppColors.brandPrimary : AppColors.dangerText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppFormatters.currency(_margin)} ($marginPercent%)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _margin >= 0 ? AppColors.brandPrimary : AppColors.dangerText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
