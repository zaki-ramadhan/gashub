import 'package:flutter/material.dart';
import 'package:flutter_solar_icons/linear.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../constants/app_colors.dart';

/// Middle row of 3 check-data actions in MetricHeroCard: Cek Stok, Piutang, Pelanggan.
class MetricHeroActionsRow extends StatelessWidget {
  const MetricHeroActionsRow({
    super.key,
    this.onCheckStock,
    this.onReceivables,
    this.onCustomers,
  });

  final VoidCallback? onCheckStock;
  final VoidCallback? onReceivables;
  final VoidCallback? onCustomers;

  @override
  Widget build(BuildContext context) {
    return Skeleton.keep(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildItem(
            icon: const BoxLinearIcon(
              size: 24,
              color: AppColors.brandPrimary,
              strokeWidth: 2.0,
            ),
            label: 'Cek Stok',
            onTap: onCheckStock,
          ),
          const SizedBox(width: 32),
          _buildItem(
            icon: const BillListLinearIcon(
              size: 24,
              color: AppColors.brandPrimary,
              strokeWidth: 2.0,
            ),
            label: 'Piutang',
            onTap: onReceivables,
          ),
          const SizedBox(width: 32),
          _buildItem(
            icon: const UsersGroupTwoRoundedLinearIcon(
              size: 24,
              color: AppColors.brandPrimary,
              strokeWidth: 2.0,
            ),
            label: 'Pelanggan',
            onTap: onCustomers,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required Widget icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.canvas,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

