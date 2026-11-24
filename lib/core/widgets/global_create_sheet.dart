import 'package:flutter/material.dart';
import '../../features/customers/presentation/customer_form_sheet.dart';
import '../../features/distribution/presentation/distribution_form_sheet.dart';
import '../../features/inventory/presentation/restock_form_sheet.dart';
import '../../features/reports/presentation/expense_form_sheet.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'app_bottom_sheet.dart';

/// Centralized creation hub sheet triggered by the bottom bar '+' FAB.
/// Allows elderly users to choose what to record from a single, prominent entry point.
class GlobalCreateSheet extends StatelessWidget {
  const GlobalCreateSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const GlobalCreateSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Mau Catat Apa?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionItem(
            context: context,
            title: 'Catat Penjualan Gas',
            subtitle: 'Penjualan tabung LPG 3kg ke pelanggan',
            isPrimary: true,
            onTap: () {
              final rootNav = Navigator.of(context, rootNavigator: true);
              final rootContext = rootNav.context;
              rootNav.pop();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!rootContext.mounted) return;
                DistributionFormSheet.show(
                  rootContext,
                  onBack: () {
                    final nav = Navigator.of(rootContext, rootNavigator: true);
                    nav.pop();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (rootContext.mounted) GlobalCreateSheet.show(rootContext);
                    });
                  },
                );
              });
            },
          ),
          const SizedBox(height: AppDimensions.space8),
          _buildActionItem(
            context: context,
            title: 'Catat Pasokan Gas',
            subtitle: 'Penerimaan pasokan tabung dari agen',
            onTap: () {
              final rootNav = Navigator.of(context, rootNavigator: true);
              final rootContext = rootNav.context;
              rootNav.pop();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!rootContext.mounted) return;
                RestockFormSheet.show(
                  rootContext,
                  onBack: () {
                    final nav = Navigator.of(rootContext, rootNavigator: true);
                    nav.pop();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (rootContext.mounted) GlobalCreateSheet.show(rootContext);
                    });
                  },
                );
              });
            },
          ),
          const SizedBox(height: AppDimensions.space8),
          _buildActionItem(
            context: context,
            title: 'Catat Pengeluaran',
            subtitle: 'Beban operasional, bensin, dan lainnya',
            onTap: () {
              final rootNav = Navigator.of(context, rootNavigator: true);
              final rootContext = rootNav.context;
              rootNav.pop();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!rootContext.mounted) return;
                ExpenseFormSheet.show(
                  rootContext,
                  onBack: () {
                    final nav = Navigator.of(rootContext, rootNavigator: true);
                    nav.pop();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (rootContext.mounted) GlobalCreateSheet.show(rootContext);
                    });
                  },
                );
              });
            },
          ),
          const SizedBox(height: AppDimensions.space8),
          _buildActionItem(
            context: context,
            title: 'Tambah Pelanggan Baru',
            subtitle: 'Daftarkan pelanggan atau pembeli baru',
            onTap: () {
              final rootNav = Navigator.of(context, rootNavigator: true);
              final rootContext = rootNav.context;
              rootNav.pop();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!rootContext.mounted) return;
                CustomerFormSheet.show(
                  rootContext,
                  onBack: () {
                    final nav = Navigator.of(rootContext, rootNavigator: true);
                    nav.pop();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (rootContext.mounted) GlobalCreateSheet.show(rootContext);
                    });
                  },
                );
              });
            },
          ),
          const SizedBox(height: AppDimensions.space12),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary ? AppColors.lime.withValues(alpha: 0.35) : Colors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            border: Border.all(
              color: isPrimary ? AppColors.forestGreen.withValues(alpha: 0.5) : AppColors.border,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isPrimary ? AppColors.brandPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

