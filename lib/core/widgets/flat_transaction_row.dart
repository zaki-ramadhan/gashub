import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'status_badge.dart';

/// Standalone pill-shaped transaction card.
/// Replaces flat divided lists with distinct, separated UI cards.
class FlatTransactionRow extends StatelessWidget {
  const FlatTransactionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.statusLabel,
    this.statusType,
    this.time,
    this.icon,
    this.iconColor,
    this.iconBg,
    this.amountColor,
    this.subtitleColor,
    this.trailingAction,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String? statusLabel;
  final BadgeType? statusType;
  final String? time;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBg;
  final Color? amountColor;
  final Color? subtitleColor;
  final Widget? trailingAction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: EdgeInsets.only(
        left: icon != null ? AppDimensions.space12 : AppDimensions.space20,
        right: AppDimensions.space20,
        top: AppDimensions.space12,
        bottom: AppDimensions.space12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg ?? AppColors.canvas,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.0),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? AppColors.brandPrimary,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
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
              children: [
                if (amount.isNotEmpty)
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: amountColor ?? AppColors.textPrimary,
                    ),
                  ),
                if (statusLabel != null ||
                    time != null ||
                    trailingAction != null) ...[
                  if (amount.isNotEmpty)
                    const SizedBox(height: 4),
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
                            fontSize: 12,
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          child: content,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: content,
    );
  }
}
