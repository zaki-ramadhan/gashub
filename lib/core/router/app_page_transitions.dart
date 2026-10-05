import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

/// Utilitas modular untuk transisi halaman menggunakan package `page_transition`.
class AppPageTransitions {
  const AppPageTransitions._();

  static const Duration defaultSlideDuration = Duration(milliseconds: 280);
  static const Duration defaultFadeDuration = Duration(milliseconds: 320);
  static const Curve defaultCurve = Curves.easeInOutCubic;

  /// Transisi geser horizontal (forward: kanan-ke-kiri, backward/pop: kiri-ke-kanan).
  static CustomTransitionPage<T> slide<T>({
    required GoRouterState state,
    required Widget child,
    Duration duration = defaultSlideDuration,
    Curve curve = defaultCurve,
  }) {
    return build<T>(
      state: state,
      child: child,
      type: PageTransitionType.rightToLeft,
      duration: duration,
      curve: curve,
    );
  }

  /// Transisi fade halus (misal dari splash screen menuju beranda).
  static CustomTransitionPage<T> fade<T>({
    required GoRouterState state,
    required Widget child,
    Duration duration = defaultFadeDuration,
    Curve curve = Curves.easeInOut,
  }) {
    return build<T>(
      state: state,
      child: child,
      type: PageTransitionType.fade,
      duration: duration,
      curve: curve,
    );
  }

  /// Builder terpusat yang mendelegasikan animasi ke `PageTransition`.
  static CustomTransitionPage<T> build<T>({
    required GoRouterState state,
    required Widget child,
    required PageTransitionType type,
    Duration duration = defaultSlideDuration,
    Curve curve = defaultCurve,
    Alignment? alignment,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return PageTransition<T>(
          type: type,
          child: child,
          curve: curve,
          alignment: alignment,
          duration: duration,
          reverseDuration: duration,
        ).buildTransitions(context, animation, secondaryAnimation, child);
      },
    );
  }
}
