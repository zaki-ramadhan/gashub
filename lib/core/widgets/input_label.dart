import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Standardized input field label with optional red asterisk suffix for required fields.
class InputLabel extends StatelessWidget {
  const InputLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w500,
    this.color = AppColors.textPrimary,
  });

  final String label;
  final bool isRequired;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (!isRequired) {
      return Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        text: label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.dangerText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

