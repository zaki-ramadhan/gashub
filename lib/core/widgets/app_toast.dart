import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../constants/app_dimensions.dart';

/// Centralized GasHub in-app toast utility using Toastification.
/// Replaces all raw SnackBars with clean, accessible, domain-styled notifications.
abstract final class AppToast {
  static void success({
    BuildContext? context,
    required String title,
    String? description,
  }) {
    _show(
      context: context,
      type: ToastificationType.success,
      title: title,
      description: description,
      primaryColor: const Color(0xFF166534), // Emerald Green
    );
  }

  static void error({
    BuildContext? context,
    required String title,
    String? description,
  }) {
    _show(
      context: context,
      type: ToastificationType.error,
      title: title,
      description: description,
      primaryColor: const Color(0xFFB91C1C), // Crimson Red
    );
  }

  static void warning({
    BuildContext? context,
    required String title,
    String? description,
  }) {
    _show(
      context: context,
      type: ToastificationType.warning,
      title: title,
      description: description,
      primaryColor: const Color(0xFFD97706), // Amber
    );
  }

  static void info({
    BuildContext? context,
    required String title,
    String? description,
  }) {
    _show(
      context: context,
      type: ToastificationType.info,
      title: title,
      description: description,
      primaryColor: const Color(0xFF1D4ED8), // Royal Blue
    );
  }

  static void _show({
    BuildContext? context,
    required ToastificationType type,
    required String title,
    String? description,
    required Color primaryColor,
  }) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.fillColored,
      primaryColor: primaryColor,
      foregroundColor: Colors.white,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(milliseconds: 2400),
      borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
      showProgressBar: false,
      dragToClose: true,
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      description: description != null && description.isNotEmpty
          ? Text(
              description,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            )
          : null,
    );
  }
}
