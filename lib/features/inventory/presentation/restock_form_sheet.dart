import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// Modal bottom sheet for recording incoming LPG 3kg supply from Pertamina / Agen.
/// Wrapped inside reusable [AppBottomSheet].
class RestockFormSheet extends StatefulWidget {
  const RestockFormSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const RestockFormSheet(),
    );
  }

  @override
  State<RestockFormSheet> createState() => _RestockFormSheetState();
}

class _RestockFormSheetState extends State<RestockFormSheet> {
  int _qty = 200;
  final int _costPerUnit = 16000;
  bool _isLoading = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_qty <= 0) {
      AppToast.warning(title: 'Jumlah tabung minimal 1');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
    AppToast.success(title: 'Pasokan berhasil disimpan');
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = _qty * _costPerUnit;

    return AppBottomSheet(
      title: 'Catat Pasokan Gas Masuk',
      bottomAction: AppButton(
        text: 'Simpan Pasokan',
        isLoading: _isLoading,
        onPressed: _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Highlight Info Agen
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
        color: AppColors.canvas,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: AppColors.brandPrimary, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Penerimaan pasokan tabung LPG 3kg dari Agen Pertamina.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 2. Stepper Jumlah Tabung
          const Text(
            'Jumlah Tabung Diterima',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            children: [
              _buildStepButton(
                icon: Icons.remove,
                onPressed: _qty > 10 ? () => setState(() => _qty -= 10) : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_qty Tabung',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              _buildStepButton(
                icon: Icons.add,
                onPressed: () => setState(() => _qty += 10),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // 3. Ringkasan Biaya Kulakan
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Harga Tebus Agen',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    Text(
                      '${AppFormatters.currency(_costPerUnit)} / tabung',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pengeluaran Beli',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      AppFormatters.currency(totalCost),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 4. Catatan / No Surat Jalan
          const Text(
            'Catatan / No. Surat Jalan (Opsional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Misal: DO-202610-098 / Truk Plat B',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: AppColors.textPrimary,
        onPressed: onPressed,
      ),
    );
  }
}
