import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/distribution/presentation/distribution_form_sheet.dart';
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
            height: 72,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 60,
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
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home,
                          label: 'Beranda',
                        ),
                        _buildNavItem(
                          index: 1,
                          icon: Icons.local_shipping_outlined,
                          activeIcon: Icons.local_shipping,
                          label: 'Distribusi',
                        ),
                        const SizedBox(width: 52),
                        _buildNavItem(
                          index: 2,
                          icon: Icons.propane_tank_outlined,
                          activeIcon: Icons.propane_tank,
                          label: 'Stok',
                        ),
                        _buildNavItem(
                          index: 3,
                          icon: Icons.bar_chart_outlined,
                          activeIcon: Icons.bar_chart,
                          label: 'Laporan',
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: GestureDetector(
                    onTap: () => DistributionFormSheet.show(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 26,
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
    required IconData icon,
    required IconData activeIcon,
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
              Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? AppColors.brandPrimary : AppColors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
