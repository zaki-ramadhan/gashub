import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/inventory_repository.dart';
import 'widgets/price_margin_card.dart';

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
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _purchasePriceController;

  bool _isLoading = false;

  int get _sellingPrice => AppInputFormatters.parseNumber(_sellingPriceController.text, defaultValue: 19000);
  int get _purchasePrice => AppInputFormatters.parseNumber(_purchasePriceController.text, defaultValue: 16000);
  int get _margin => _sellingPrice - _purchasePrice;

  @override
  void initState() {
    super.initState();
    int liveSelling = 19000;
    int livePurchase = 16000;
    try {
      liveSelling = InventoryRepository.instance.sellingPrice;
    } catch (_) {}
    try {
      livePurchase = InventoryRepository.instance.purchasePrice;
    } catch (_) {}
    _sellingPriceController = TextEditingController(
      text: AppFormatters.number(liveSelling > 0 ? liveSelling : 19000),
    );
    _purchasePriceController = TextEditingController(
      text: AppFormatters.number(livePurchase > 0 ? livePurchase : 16000),
    );
  }

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
    await InventoryRepository.instance.updatePrices(
      sellingPrice: _sellingPrice,
      purchasePrice: _purchasePrice,
    );
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
    AppToast.success(title: 'Harga berhasil disimpan');
  }

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Harga acuan saat mencatat penjualan dan penerimaan pasokan.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 2. Input Harga Jual Gas
          const InputLabel(
            label: 'Harga Jual Gas',
            isRequired: true,
          ),
          const SizedBox(height: 2),
          const Text(
            'Harga jual per tabung ke pelanggan.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.space8),
          Focus(
            onFocusChange: (hasFocus) {
              AppInputFormatters.clampOnBlur(
                controller: _sellingPriceController,
                hasFocus: hasFocus,
                min: 1,
                onClamped: () => setState(() {}),
              );
            },
            child: TextFormField(
              controller: _sellingPriceController,
              keyboardType: TextInputType.number,
              inputFormatters: [AppInputFormatters.thousands],
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                prefixIcon: Padding(
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
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 3. Input Harga Modal Beli
          const InputLabel(
            label: 'Harga Modal Beli',
            isRequired: true,
          ),
          const SizedBox(height: 2),
          const Text(
            'Harga tebus per tabung dari agen.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.space8),
          Focus(
            onFocusChange: (hasFocus) {
              AppInputFormatters.clampOnBlur(
                controller: _purchasePriceController,
                hasFocus: hasFocus,
                min: 1,
                onClamped: () => setState(() {}),
              );
            },
            child: TextFormField(
              controller: _purchasePriceController,
              keyboardType: TextInputType.number,
              inputFormatters: [AppInputFormatters.thousands],
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                prefixIcon: Padding(
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
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 4. Kalkulator Keuntungan Langsung
          PriceMarginCard(
            margin: _margin,
            sellingPrice: _sellingPrice,
          ),
        ],
      ),
    );
  }
}
