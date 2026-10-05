import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// 4 secondary quick operational tools on the dashboard.
class DashboardQuickTools extends StatelessWidget {
  const DashboardQuickTools({
    super.key,
    required this.onCatatUtang,
    required this.onStokGas,
    required this.onPelanggan,
    required this.onAturHarga,
  });

  final VoidCallback onCatatUtang;
  final VoidCallback onStokGas;
  final VoidCallback onPelanggan;
  final VoidCallback onAturHarga;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.space16,
        horizontal: AppDimensions.space8,
      ),
      child: Row(
        children: [
          _buildToolItem(
            icon: Icons.menu_book_outlined,
            label: 'Catat Utang',
            onTap: onCatatUtang,
          ),
          _buildToolItem(
            icon: Icons.propane_tank_outlined,
            label: 'Stok Gas',
            onTap: onStokGas,
          ),
          _buildToolItem(
            icon: Icons.person_outline,
            label: 'Pelanggan',
            onTap: onPelanggan,
          ),
          _buildToolItem(
            icon: Icons.sell_outlined,
            label: 'Atur Harga',
            onTap: onAturHarga,
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Skeleton.replace(
                replacement: const Bone.circle(size: 44),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(icon, size: 24, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
