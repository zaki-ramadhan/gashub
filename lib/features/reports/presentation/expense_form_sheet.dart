import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// Modal bottom sheet for recording operational business expenses.
/// Wrapped inside reusable [AppBottomSheet].
class ExpenseFormSheet extends StatefulWidget {
  const ExpenseFormSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ExpenseFormSheet(),
    );
  }

  @override
  State<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<ExpenseFormSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = 'Bensin Motor/Tossa';
  bool _isLoading = false;

  static const List<String> _categories = [
    'Bensin Motor/Tossa',
    'Upah Harian Pekerja',
    'Uang Makan Pekerja',
    'Tambal Ban / Servis',
    'Lain-lain',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = AppInputFormatters.parseNumber(_amountController.text);

    if (amount <= 0) {
      AppToast.warning(title: 'Nominal belum diisi');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
    AppToast.success(title: 'Pengeluaran berhasil disimpan');
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Catat Pengeluaran',
      bottomAction: AppButton(
        text: 'Simpan Pengeluaran',
        isLoading: _isLoading,
        onPressed: _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Kategori Biaya Chips
          const Text(
            'Kategori Pengeluaran',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    border: Border.all(
                      color: isSelected ? AppColors.brandPrimary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 2. Nominal Pengeluaran
          const Text(
            'Nominal Pengeluaran (Rp)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [AppInputFormatters.thousands],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 3. Catatan Pengeluaran
          const Text(
            'Keterangan / Catatan (Opsional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _noteController,
            inputFormatters: [AppInputFormatters.cleanText],
            decoration: const InputDecoration(
              hintText: 'Contoh: Isi solar truk pick up untuk kirim pagi',
            ),
          ),
        ],
      ),
    );
  }
}
