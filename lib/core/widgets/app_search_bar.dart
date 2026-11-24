import 'package:flutter/material.dart';
import 'package:flutter_solar_icons/linear.dart';
import '../constants/app_colors.dart';
import '../formatters/app_input_formatters.dart';

/// Reusable ergonomic search bar adhering to GasHub design system:
/// - Prefix magnifier icon with fixed constraints
/// - Suffix clear button when query is active
/// - Auto-trim and cleanText formatter
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    this.hasQuery = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14),
      inputFormatters: [AppInputFormatters.cleanText],
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 8),
          child: MagnifierLinearIcon(size: 20, color: AppColors.textMuted),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        suffixIcon: hasQuery
            ? IconButton(
                icon: const CloseCircleLinearIcon(size: 18, color: AppColors.textMuted),
                onPressed: onClear,
              )
            : null,
        isDense: true,
        fillColor: Colors.white,
      ),
    );
  }
}

