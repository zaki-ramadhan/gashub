import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// Bottom sheet form for recording LPG 3kg sales / distribution to warung.
class DistributionFormSheet extends StatefulWidget {
  const DistributionFormSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DistributionFormSheet(),
    );
  }

  @override
  State<DistributionFormSheet> createState() => _DistributionFormSheetState();
}

class _DistributionFormSheetState extends State<DistributionFormSheet> {
  final _customerController = TextEditingController(text: 'Warung Madura Pak Joko');
  int _qty = 15;
  final int _unitPrice = 19000;
  bool _isPaid = true;
  bool _isLoading = false;

  int get _subtotal => _qty * _unitPrice;

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final customer = _customerController.text.trim();
    if (customer.isEmpty) {
      AppToast.warning(title: 'Nama warung belum diisi');
      return;
    }
    if (_qty <= 0) {
      AppToast.warning(title: 'Jumlah tabung minimal 1');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
    AppToast.success(title: 'Penjualan berhasil disimpan');
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Catat Penjualan Gas 3kg',
      bottomAction: AppButton(
        text: 'Simpan Penjualan',
        isLoading: _isLoading,
        onPressed: _save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Nama Warung / Pembeli
          const Text(
            'Nama Warung / Pembeli',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          TextFormField(
            controller: _customerController,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              hintText: 'Ketik nama warung...',
              prefixIcon: Icon(Icons.storefront, size: 20, color: AppColors.textMuted),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),

          // Pilihan Cepat Warung Langganan
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickChip('Warung Pak Joko'),
                const SizedBox(width: 6),
                _buildQuickChip('Toko Berkah Ibu'),
                const SizedBox(width: 6),
                _buildQuickChip('Warung Bu Siti'),
                const SizedBox(width: 6),
                _buildQuickChip('RM Padang'),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 2. Jumlah Tabung (Gas 3kg)
          const Text(
            'Jumlah Tabung Gas 3kg',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: Row(
              children: [
                const CircularBadge(
                  icon: Icons.propane_tank,
                  backgroundColor: AppColors.brandAccent,
                  iconColor: AppColors.brandPrimary,
                  size: 36,
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gas 3kg (Subsidi)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${AppFormatters.currency(_unitPrice)} / tabung',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                // Stepper Counter: - [Qty] +
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        splashRadius: 18,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 36),
                        alignment: Alignment.center,
                        child: Text(
                          '$_qty',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        splashRadius: 18,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: () => setState(() => _qty++),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 3. Status Pembayaran
          const Text(
            'Status Pembayaran',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isPaid = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isPaid ? AppColors.brandPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                      border: Border.all(
                        color: _isPaid ? AppColors.brandPrimary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      'Lunas (Tunai)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _isPaid ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isPaid = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !_isPaid ? AppColors.dangerText : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                      border: Border.all(
                        color: !_isPaid ? AppColors.dangerText : AppColors.border,
                      ),
                    ),
                    child: Text(
                      'Tempo (Hutang)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: !_isPaid ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // 4. Ringkasan Total Tagihan
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Tagihan:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  AppFormatters.currency(_subtotal),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String name) {
    return GestureDetector(
      onTap: () => setState(() => _customerController.text = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          name,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
