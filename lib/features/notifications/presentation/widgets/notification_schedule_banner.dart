import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../data/notifications_repository.dart';
import '../../domain/notification_models.dart';

class NotificationScheduleBanner extends StatelessWidget {
  const NotificationScheduleBanner({
    super.key,
    required this.onEdit,
  });

  final VoidCallback onEdit;

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<NotificationSettings>(
      valueListenable: NotificationsRepository.instance.settingsNotifier,
      builder: (context, settings, _) {
        final timeStr = _formatTime(settings.restockTime);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.schedule_outlined,
              size: 16,
              color: AppColors.brandPrimary,
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Pengingat aktif: ',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: 'Jadwal muat pkl $timeStr',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Ubah',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
