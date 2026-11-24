import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../data/distribution_repository.dart';
import '../../domain/distribution_model.dart';

/// Confirmation dialog for reverting / cancelling a gas sale transaction.
class CancelDistributionDialog {
  static Future<void> show(BuildContext context, DistributionModel sale) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Batalkan Transaksi?',
          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Transaksi ${sale.transactionNumber} senilai ${AppFormatters.currency(sale.amount)} akan dihapus. Stok ${sale.qty} tabung gas dan catatan kas akan dikembalikan.',
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Kembali',
              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await DistributionRepository.instance.cancelDistribution(sale.id);
        if (context.mounted) {
          Navigator.of(context).pop();
          AppToast.success(
            title: 'Transaksi berhasil dibatalkan',
            description: 'Stok tabung dan kas telah dikembalikan',
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.error(title: 'Gagal membatalkan transaksi: $e');
        }
      }
    }
  }
}

