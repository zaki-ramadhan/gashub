import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Reusable modal bottom sheet container for GasHub forms and quick actions.
/// Designed for elderly ergonomics: large close target, drag handle,
/// automatic keyboard inset handling, and bounded height.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.bottomAction,
    this.showDragHandle = true,
  });

  final String title;
  final Widget child;
  final Widget? bottomAction;
  final bool showDragHandle;

  /// Helper to display this bottom sheet with standard modal configuration.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? bottomAction,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppBottomSheet(
        title: title,
        bottomAction: bottomAction,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final maxHeight = mediaQuery.size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusCard),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag Handle Pill
              if (showDragHandle) ...[
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                  ),
                ),
              ],

              // 2. Header: Title + Close Button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.space16,
                  AppDimensions.space8,
                  AppDimensions.space8,
                  AppDimensions.space8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 22, color: AppColors.textMuted),
                      splashRadius: 20,
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),

              // 3. Scrollable Content Area
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: child,
                ),
              ),

              // 4. Sticky Bottom Action (if provided)
              if (bottomAction != null) ...[
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: bottomAction!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
