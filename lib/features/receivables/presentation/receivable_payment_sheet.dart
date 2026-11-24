import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../distribution/data/distribution_repository.dart';
import '../../reports/data/reports_repository.dart';
import '../data/receivables_repository.dart';
import '../domain/receivable_model.dart';

/// Modal bottom sheet for recording receivable payment or installment.
class ReceivablePaymentSheet extends StatefulWidget {
  const ReceivablePaymentSheet({
    super.key,
    required this.item,
  });

  final ReceivableModel item;

  static Future<void> show({
    required BuildContext context,
    required ReceivableModel item,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReceivablePaymentSheet(item: item),
    );
  }

  @override
  State<ReceivablePaymentSheet> createState() => _ReceivablePaymentSheetState();
}

class _ReceivablePaymentSheetState extends State<ReceivablePaymentSheet> {
  final TextEditingController _payController = TextEditingController();
  String? _amountError;
  bool _isSaving = false;

  @override
  void dispose() {
    _payController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final int totalDebt = item.remainingAmount;
    final enteredAmount = AppInputFormatters.parseNumber(_payController.text);
    final remainingAfter = totalDebt - enteredAmount;
    final bool isOverpaid = enteredAmount > totalDebt;

    return AppBottomSheet(
      title: 'Catat Bayar Utang',
      bottomAction: AppButton(
        text: 'Simpan Pembayaran',
        isLoading: _isSaving,
        onPressed: () async {
          if (enteredAmount <= 0) {
            setState(() => _amountError = 'Masukkan nominal pembayaran');
            return;
          }
          if (isOverpaid) {
            setState(() => _amountError = 'Nominal melebihi sisa utang');
            return;
          }

          setState(() => _isSaving = true);
          final navigator = Navigator.of(context, rootNavigator: true);
          try {
            await ReceivablesRepository.instance.recordPayment(
              receivableId: item.id,
              amount: enteredAmount,
              method: 'cash',
            );
            await Future.wait([
              DistributionRepository.instance.fetchDistributions(),
              ReportsRepository.instance.fetchLiveReport(),
            ]);
            if (!mounted) return;

            navigator.pop();
            AppToast.success(
              title: enteredAmount == totalDebt
                  ? 'Utang berhasil dilunasi'
                  : 'Cicilan berhasil disimpan',
            );
          } catch (e) {
            if (mounted) {
              setState(() => _isSaving = false);
              AppToast.error(title: 'Gagal menyimpan pembayaran: $e');
            }
          }
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Info Pelanggan & Utang
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.invoiceNumber} | ${AppFormatters.date(item.date)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Sisa utang saat ini',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.currency(totalDebt),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dangerText,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.space16),

          // 2. Nominal Pembayaran Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const InputLabel(
                label: 'Nominal yang dibayar (Rp)',
                isRequired: true,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _payController.text = AppFormatters.number(totalDebt);
                    _amountError = null;
                  });
                },
                child: const Text(
                  'Lunasi Penuh',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Focus(
            onFocusChange: (hasFocus) {
              AppInputFormatters.clampOnBlur(
                controller: _payController,
                hasFocus: hasFocus,
                min: 1,
                onClamped: () => setState(() {}),
              );
            },
            child: TextField(
              controller: _payController,
              keyboardType: TextInputType.number,
              inputFormatters: [AppInputFormatters.thousands],
              onChanged: (_) {
                if (_amountError != null) setState(() => _amountError = null);
                setState(() {});
              },
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 6),
                  child: Text(
                    'Rp ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: '0',
                errorText: _amountError,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 3. Status Kalkulasi Pembayaran / Cicilan Live
          if (enteredAmount == 0)
            const Text(
              'Ketik nominal yang dibayar pelanggan (bisa cicilan atau lunas).',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            )
          else if (isOverpaid)
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.dangerText,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Nominal melebihi sisa utang (${AppFormatters.currency(totalDebt)})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.dangerText,
                  ),
                ),
              ],
            )
          else if (enteredAmount == totalDebt)
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Pelunasan penuh | Sisa utang: Rp 0 (Lunas)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD97706),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Bayar sebagian | Sisa tagihan nanti: ${AppFormatters.currency(remainingAfter)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.warningText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
