import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../data/reports_repository.dart';

/// Modal bottom sheet for recording operational business expenses.
/// Wrapped inside reusable [AppBottomSheet].
class ExpenseFormSheet extends StatefulWidget {
  const ExpenseFormSheet({super.key, this.onBack});

  final VoidCallback? onBack;

  static Future<void> show(BuildContext context, {VoidCallback? onBack}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExpenseFormSheet(onBack: onBack),
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
    try {
      final note = _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : _selectedCategory;
      await DashboardRepository.instance.recordExpense(
        amount: amount,
        notes: note,
        category: _selectedCategory,
      );
      await ReportsRepository.instance.fetchLiveReport();
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      AppToast.success(title: 'Pengeluaran berhasil disimpan');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(title: 'Gagal mencatat pengeluaran: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Catat Pengeluaran',
      onBack: widget.onBack,
      bottomAction: AppButton(
        text: 'Simpan Pengeluaran',
        isLoading: _isLoading,
        onPressed: _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Kategori Biaya Chips
          const InputLabel(
            label: 'Kategori Pengeluaran',
            isRequired: true,
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
                    color: isSelected ? AppColors.lime : Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    border: Border.all(
                      color: isSelected ? AppColors.forestGreen.withValues(alpha: 0.5) : AppColors.border,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 2. Nominal Pengeluaran
          const InputLabel(
            label: 'Nominal Pengeluaran',
            isRequired: true,
          ),
          const SizedBox(height: 6),
          Focus(
            onFocusChange: (hasFocus) {
              AppInputFormatters.clampOnBlur(
                controller: _amountController,
                hasFocus: hasFocus,
                min: 1,
              );
            },
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [AppInputFormatters.thousands],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 14, right: 6),
                  child: Text(
                    'Rp ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 3. Catatan Pengeluaran
          const InputLabel(
            label: 'Keterangan / Catatan (Opsional)',
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _noteController,
            inputFormatters: [AppInputFormatters.cleanText],
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
