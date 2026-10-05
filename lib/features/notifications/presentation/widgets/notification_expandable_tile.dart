import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/formatters/app_formatters.dart';
import '../../domain/notification_models.dart';

class NotificationExpandableTile extends StatefulWidget {
  const NotificationExpandableTile({
    super.key,
    required this.item,
    required this.onAction,
    required this.onMarkRead,
  });

  final NotificationItem item;
  final VoidCallback onAction;
  final VoidCallback onMarkRead;

  @override
  State<NotificationExpandableTile> createState() =>
      _NotificationExpandableTileState();
}

class _NotificationExpandableTileState
    extends State<NotificationExpandableTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isUnread = !item.isRead;
    final isDebt = item.type == NotificationType.debt;

    final String dateStr = AppFormatters.relativeDateHeader(item.dateTime);
    final String metadataText = isDebt && item.amount != null
        ? '$dateStr - ${AppFormatters.currency(item.amount!)}'
        : dateStr;

    // Semantic colors for unread items; clean high-contrast neutral slate for already read items
    final Color iconBg = isUnread
        ? (isDebt ? AppColors.warningBg : const Color(0xFFDCFCE7))
        : const Color(0xFFF1F5F9);
    final Color iconBorder = isUnread
        ? (isDebt ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0))
        : const Color(0xFFCBD5E1);
    final Color iconFg = isUnread
        ? (isDebt ? AppColors.warningText : AppColors.brandPrimary)
        : AppColors.textPrimary;

    final IconData iconData =
        isDebt ? Icons.receipt_long_outlined : Icons.local_shipping_outlined;

    // Opacity: full 1.0 for unread or expanded, 0.78 for collapsed read items (sharp & high contrast)
    final double contentOpacity = (isUnread || _isExpanded) ? 1.0 : 0.78;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          setState(() => _isExpanded = !_isExpanded);
          if (isUnread) widget.onMarkRead();
        },
        child: AnimatedOpacity(
          opacity: contentOpacity,
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Toggle Row (Always visible)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Type Icon with Unread Status Badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: iconBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: iconBorder, width: 1.0),
                          ),
                          child: Icon(
                            iconData,
                            size: 18,
                            color: iconFg,
                          ),
                        ),
                        if (isUnread)
                          Positioned(
                            top: -1,
                            right: -1,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: AppDimensions.space12),

                    // Title + Subtitle Metadata (Uniform font weight, differentiated by opacity)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            metadataText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: AppDimensions.space8),

                  // Animated Chevron Toggle
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),

              // Expanded Content Area (Toggled)
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(
                    left: 48, // 36px icon + 12px gap
                    top: AppDimensions.space10,
                    bottom: AppDimensions.space4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Natural sentence message
                      Text(
                        item.message,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      // Action Button Row
                      Row(
                        children: [
                          InkWell(
                            onTap: widget.onAction,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusControl,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusControl,
                                ),
                              ),
                              child: Text(
                                item.actionText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (isUnread)
                            InkWell(
                              onTap: widget.onMarkRead,
                              borderRadius: BorderRadius.circular(4),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                child: Text(
                                  'Tandai sudah dibaca',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
