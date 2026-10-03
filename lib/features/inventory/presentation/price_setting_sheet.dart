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
  final _sellingPriceController = TextEditingController(text: '19000');
  final _purchasePriceController = TextEditingController(text: '15750');

  bool _isLoading = false;

  int get _sellingPrice => int.tryParse(_sellingPriceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  int get _purchasePrice => int.tryParse(_purchasePriceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
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
      title: 'Atur Harga Gas 3kg',
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
                    'Harga ini otomatis dipakai saat mencatat penjualan ke warung dan pasokan baru.',
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

          // 2. Input Harga Jual ke Warung
          const Text(
            'Harga Jual ke Warung',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Berapa harga yang Anda tentukan saat mengantar gas ke warung.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.space8),
          TextFormField(
            controller: _sellingPriceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 3. Input Harga Modal Beli dari Agen
          const Text(
            'Harga Modal Beli dari Agen',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Berapa harga tebus per tabung saat pasokan gas masuk ke pangkalan.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.space8),
          TextFormField(
            controller: _purchasePriceController,
            keyboardType: TextInputType.number,
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
