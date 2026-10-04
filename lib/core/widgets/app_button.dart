import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Utilitarian button.
/// Strictly 14px, weight 500/600, 8px radius, text-only by default.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.isCompact = false,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon; // Functional icons only (e.g. [+ Catat])
  final bool isLoading;
  final bool isSecondary;
  final bool isCompact;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final height = isCompact ? AppDimensions.buttonHeightCompact : AppDimensions.buttonHeight;
    final fontSize = isCompact ? 13.0 : 14.0;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppDimensions.radiusPill);

    final resolvedBg = isSecondary
        ? (backgroundColor ?? Colors.transparent)
        : (backgroundColor ?? AppColors.brandPrimary);

    final resolvedFg = isSecondary
        ? (textColor ?? AppColors.brandPrimary)
        : (textColor ?? Colors.white);

    final child = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(resolvedFg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppDimensions.space8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: resolvedFg,
                ),
              ),
            ],
          );

    return SizedBox(
      height: height,
      child: Material(
        color: isLoading ? resolvedBg.withValues(alpha: 0.75) : resolvedBg,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: effectiveRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              border: isSecondary ? Border.all(color: AppColors.border) : null,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
