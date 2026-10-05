import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'app_button.dart';

/// Reusable Cupertino drum-wheel time picker modal for GasHub.
/// Features a real clock ':' separator and dynamic time-of-day indicator.
class AppTimePickerSheet extends StatefulWidget {
  const AppTimePickerSheet({
    super.key,
    required this.initialTime,
    required this.title,
  });

  final TimeOfDay initialTime;
  final String title;

  static Future<TimeOfDay?> show({
    required BuildContext context,
    required TimeOfDay initialTime,
    String title = 'Pilih waktu',
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppTimePickerSheet(
        initialTime: initialTime,
        title: title,
      ),
    );
  }

  @override
  State<AppTimePickerSheet> createState() => _AppTimePickerSheetState();
}

class _AppTimePickerSheetState extends State<AppTimePickerSheet> {
  int _selectedHour = 0;
  int _selectedMinute = 0;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  bool _initialized = false;

  void _ensureInitialized() {
    if (!_initialized) {
      _selectedHour = widget.initialTime.hour;
      _selectedMinute = widget.initialTime.minute;
      _hourController = FixedExtentScrollController(initialItem: _selectedHour);
      _minuteController =
          FixedExtentScrollController(initialItem: _selectedMinute);
      _initialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _ensureInitialized();
  }

  @override
  void didUpdateWidget(covariant AppTimePickerSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureInitialized();
  }

  @override
  void dispose() {
    if (_initialized) {
      _hourController.dispose();
      _minuteController.dispose();
    }
    super.dispose();
  }

  String _getTimePeriod(int hour) {
    if (hour >= 4 && hour < 11) return 'Pagi';
    if (hour >= 11 && hour < 15) return 'Siang';
    if (hour >= 15 && hour < 18) return 'Sore';
    return 'Malam';
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized();
    return Container(
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

            // Header with Dynamic Time Period Badge
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
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandAccent,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusControl,
                            ),
                          ),
                          child: Text(
                            _getTimePeriod(_selectedHour),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 22,
                      color: AppColors.textMuted,
                    ),
                    splashRadius: 20,
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),

            // Drum Wheel with ':' Separator and 2-digit numbers
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center selection highlight bar
                  Container(
                    height: 42,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space32,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusControl),
                    ),
                  ),

                  // Wheels Row with Real Digital Clock Colon ':'
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hours Wheel (00 - 23)
                      SizedBox(
                        width: 76,
                        child: CupertinoPicker(
                          itemExtent: 42,
                          scrollController: _hourController,
                          selectionOverlay: const SizedBox.shrink(),
                          looping: true,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedHour = index % 24;
                            });
                          },
                          children: List.generate(24, (i) {
                            return Center(
                              child: Text(
                                i.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Real Digital Clock Colon ':'
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.0,
                          ),
                        ),
                      ),

                      // Minutes Wheel (00 - 59)
                      SizedBox(
                        width: 76,
                        child: CupertinoPicker(
                          itemExtent: 42,
                          scrollController: _minuteController,
                          selectionOverlay: const SizedBox.shrink(),
                          looping: true,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedMinute = index % 60;
                            });
                          },
                          children: List.generate(60, (i) {
                            return Center(
                              child: Text(
                                i.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer Actions (Matched 8px corner radii & standard buttons)
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Batal',
                      isSecondary: true,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusControl),
                      textColor: AppColors.textPrimary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: AppButton(
                      text: 'Terapkan',
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusControl),
                      onPressed: () {
                        final time = TimeOfDay(
                          hour: _selectedHour,
                          minute: _selectedMinute,
                        );
                        Navigator.of(context).pop(time);
                      },
                    ),
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
