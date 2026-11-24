import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Top AppBar for DashboardScreen with clean greeting and date.
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return AppBar(
      toolbarHeight: 56,
      backgroundColor: AppColors.brandPrimary,
      automaticallyImplyLeading: false,
      titleSpacing: AppDimensions.space16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${AppFormatters.dayOfWeek(now)},',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            AppFormatters.fullDate(now),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
