/// Centralized spatial system, radii, and touch dimensions.
/// Strictly follows GasHub_Final_Specification_FINAL/03_DESIGN/DESIGN_SYSTEM.md
abstract final class AppDimensions {
  // Spacing Rhythm (4px base, 8px rhythm)
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Corner Radii (Modern, soft, non-sharp aesthetic matching Hero Card)
  static const double radiusControl = 12.0;   // Buttons, inputs, chips, search bars
  static const double radiusCard = 24.0;     // Containers, surface cards, list wrappers
  static const double radiusLarge = 24.0;    // Modals, bottom sheets, hero containers
  static const double radiusPill = 999.0;    // Semantic status pills only

  // Mobile Ergonomics & Touch Targets
  static const double minTouchTarget = 48.0;
  static const double buttonHeight = 48.0;
  static const double buttonHeightCompact = 40.0;
}
