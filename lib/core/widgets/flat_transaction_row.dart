import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'status_badge.dart';

/// Clean, high-density flat transaction row.
/// Pure textual layout without bulky capsule containers or decorative icon clutter.
/// Adheres strictly to GasHub anti-card-slop directives (flat divided rows).
class FlatTransactionRow extends StatelessWidget {
  const FlatTransactionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.statusLabel,
    this.statusType,
    this.time,
    this.leadingWidget,
    this.icon,
    this.iconWidget,
    this.iconColor,
    this.iconBg,
    this.amountColor,
    this.subtitleColor,
    this.trailingAction,
    this.onTap,
    this.showDivider = true,
    this.iconSize = 20.0,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String? statusLabel;
  final BadgeType? statusType;
  final String? time;
  final Widget? leadingWidget;
  final IconData? icon;
  final Widget? iconWidget;
  final Color? iconColor;
  final Color? iconBg;
  final Color? amountColor;
  final Color? subtitleColor;
  final Widget? trailingAction;
  final VoidCallback? onTap;
  final bool showDivider;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null || iconWidget != null;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: 12.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingWidget != null) ...[
            Skeleton.replace(
              replacement: const Bone.circle(size: 28),
              child: leadingWidget!,
            ),
            const SizedBox(width: AppDimensions.space12),
          ] else if (hasIcon) ...[
            Skeleton.replace(
              replacement: const Bone.circle(size: 36),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg ?? AppColors.canvas,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                alignment: Alignment.center,
                child: iconWidget ??
                    Icon(
                      icon,
                      size: iconSize,
                      color: iconColor ?? AppColors.brandPrimary,
                    ),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtitleColor ?? AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (amount.isNotEmpty ||
              statusLabel != null ||
              time != null ||
              trailingAction != null) ...[
            const SizedBox(width: AppDimensions.space12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (amount.isNotEmpty)
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: amountColor ?? AppColors.textPrimary,
                    ),
                  ),
                if (statusLabel != null ||
                    time != null ||
                    trailingAction != null) ...[
                  if (amount.isNotEmpty) const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (statusLabel != null && statusType != null)
                        StatusBadge(
                          label: statusLabel!,
                          type: statusType!,
                        ),
                      if (time != null) ...[
                        if (statusLabel != null) const SizedBox(width: 6),
                        Text(
                          time!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      if (trailingAction != null) ...[
                        if (statusLabel != null || time != null)
                          const SizedBox(width: 6),
                        trailingAction!,
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: content,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: showDivider
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 1.0,
                ),
              )
            : null,
      ),
      child: content,
    );
  }
}
