import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_time_picker_sheet.dart';
import '../../data/notifications_repository.dart';
import '../../domain/notification_models.dart';

class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({
    super.key,
    required this.initialSettings,
  });

  final NotificationSettings initialSettings;

  static Future<void> show({
    required BuildContext context,
    required NotificationSettings initialSettings,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationSettingsSheet(initialSettings: initialSettings),
    );
  }

  @override
  State<NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  late TimeOfDay _restockTime;
  late int _debtDueDays;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _restockTime = widget.initialSettings.restockTime;
    _debtDueDays = widget.initialSettings.debtDueDays;
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  String _getTimePeriod(int hour) {
    if (hour >= 4 && hour < 11) return 'Pagi';
    if (hour >= 11 && hour < 15) return 'Siang';
    if (hour >= 15 && hour < 18) return 'Sore';
    return 'Malam';
  }

  Future<void> _pickTime({
    required BuildContext context,
    required TimeOfDay current,
    required String title,
    required ValueChanged<TimeOfDay> onSelected,
  }) async {
    final picked = await AppTimePickerSheet.show(
      context: context,
      initialTime: current,
      title: title,
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final newSettings = NotificationSettings(
      restockTime: _restockTime,
      debtDueDays: _debtDueDays,
    );
    await NotificationsRepository.instance.updateSettings(newSettings);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context, rootNavigator: true).pop();
      AppToast.success(title: 'Pengaturan pengingat berhasil disimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.85;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
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

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space16,
                AppDimensions.space8,
                AppDimensions.space8,
                AppDimensions.space8,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Atur waktu pengingat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
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

            // Content (Simplified, clear, dynamic periods)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: AppDimensions.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pengingat Jadwal Muat Gas
                    _buildSimpleTimeRow(
                      label: 'Pengingat jadwal muat gas',
                      periodText: _getTimePeriod(_restockTime.hour),
                      timeText: _formatTime(_restockTime),
                      onTap: () => _pickTime(
                        context: context,
                        current: _restockTime,
                        title: 'Pilih jam pengingat muat gas',
                        onSelected: (t) => setState(() => _restockTime = t),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.border),
                    const SizedBox(height: AppDimensions.space16),

                    // Section: Batas tagihan pelanggan
                    const Text(
                      'Batas waktu tagihan pelanggan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [3, 5, 7, 14].map((days) {
                        final isSelected = _debtDueDays == days;
                        return ChoiceChip(
                          showCheckmark: true,
                          checkmarkColor: Colors.white,
                          label: Text('$days Hari'),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _debtDueDays = days);
                          },
                          selectedColor: AppColors.brandPrimary,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                            side: BorderSide(
                              color: isSelected ? AppColors.brandPrimary : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimensions.space12),
                  ],
                ),
              ),
            ),

            // Footer Button
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: AppButton(
                text: 'Simpan pengaturan',
                isLoading: _isSaving,
                onPressed: _saveSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTimeRow({
    required String label,
    required String periodText,
    required String timeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space12),
        child: Row(
          children: [
            const Icon(
              Icons.schedule_outlined,
              size: 20,
              color: AppColors.brandPrimary,
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Waktu: $periodText',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.edit_outlined,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
