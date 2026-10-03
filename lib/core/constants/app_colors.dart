import 'package:flutter/material.dart';

/// Centralized palette using Deep Forest Green brand foundation and high-contrast neutral surfaces.
/// Strictly follows GasHub_Final_Specification_FINAL/03_DESIGN/COLOR_TOKENS.md
abstract final class AppColors {
  // Brand Foundation
  static const Color brandPrimary = Color(0xFF14432A); // Deep Forest Green (Top header, bottom nav, primary actions)
  static const Color brandAccent = Color(0xFFDCFCE7);  // Pale Mint / Sage (Badge background, chip selections)
  static const Color brandSuccess = Color(0xFF16A34A); // Positive financial net, active indicator

  // Neutral Canvas & Surfaces
  static const Color canvas = Color(0xFFF0F1F3);       // Soft neutral background (#F0F1F3)
  static const Color surface = Color(0xFFFFFFFF);      // Crisp White (Card & sheets)
  static const Color border = Color(0xFFE5E7EB);       // Subtle, ultra-soft neutral border
  static const Color textPrimary = Color(0xFF0F172A);  // Dark Charcoal / Slate 900
  static const Color textMuted = Color(0xFF64748B);    // Slate 500 (Captions, timestamps)

  // Semantic Status Tokens
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color successText = Color(0xFF15803D);

  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFFB45309);

  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFFB91C1C);

  static const Color infoBg = Color(0xFFDBEAFE);
  static const Color infoText = Color(0xFF1D4ED8);
}
