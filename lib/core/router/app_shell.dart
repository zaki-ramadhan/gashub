import 'package:flutter/material.dart';
import 'package:flutter_solar_icons/bold.dart';
import 'package:flutter_solar_icons/linear.dart';
import 'package:go_router/go_router.dart';
import '../widgets/global_create_sheet.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'animated_branch_container.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: children != null
          ? AnimatedBranchContainer(
              currentIndex: navigationShell.currentIndex,
              children: children!,
            )
          : navigationShell,
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: SizedBox(
            height: 76,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    border: Border.all(color: AppColors.border, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    child: Row(
                      children: [
                        _buildNavItem(
                          index: 0,
                          iconBuilder: (isSelected) => isSelected
                              ? const Home2BoldIcon(size: 24, color: AppColors.brandPrimary)
                              : const Home2LinearIcon(size: 24, color: AppColors.textMuted),
                          label: 'Beranda',
                        ),
                        _buildNavItem(
                          index: 1,
                          iconBuilder: (isSelected) => isSelected
                              ? const DeliveryBoldIcon(size: 24, color: AppColors.brandPrimary)
                              : const DeliveryLinearIcon(size: 24, color: AppColors.textMuted),
                          label: 'Penjualan',
                        ),
                        const SizedBox(width: 52),
                        _buildNavItem(
                          index: 2,
                          iconBuilder: (isSelected) => isSelected
                              ? const BoxBoldIcon(size: 24, color: AppColors.brandPrimary)
                              : const BoxLinearIcon(size: 24, color: AppColors.textMuted),
                          label: 'Stok',
                        ),
                        _buildNavItem(
                          index: 3,
                          iconBuilder: (isSelected) => isSelected
                              ? const Chart2BoldIcon(size: 24, color: AppColors.brandPrimary)
                              : const Chart2LinearIcon(size: 24, color: AppColors.textMuted),
                          label: 'Laporan',
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: GestureDetector(
                    onTap: () => GlobalCreateSheet.show(context),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: AppColors.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: AddLinearIcon(
                          color: Colors.white,
                          size: 26,
                          strokeWidth: 2.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required Widget Function(bool isSelected) iconBuilder,
    required String label,
  }) {
    final isSelected = navigationShell.currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          onTap: () {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconBuilder(isSelected),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.brandPrimary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
