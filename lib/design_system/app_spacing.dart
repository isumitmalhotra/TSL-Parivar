/// TSL Parivar Design System - Spacing Constants
///
/// This file contains all spacing definitions following the 8px base unit system.
///
/// Spacing Scale:
/// - xs: 4px
/// - sm: 8px (base)
/// - md: 12px
/// - lg: 16px
/// - xl: 24px
/// - xxl: 32px
abstract final class AppSpacing {
  // ============================================
  // BASE SPACING UNIT
  // ============================================

  /// Base spacing unit (8px)
  static const double base = 8.0;

  // ============================================
  // SPACING SCALE
  // ============================================

  /// 0px - No spacing
  static const double zero = 0.0;

  /// 2px - Extra extra small
  static const double xxs = 2.0;

  /// 4px - Extra small
  static const double xs = 4.0;

  /// 8px - Small (base unit)
  static const double sm = 8.0;

  /// 12px - Medium
  static const double md = 12.0;

  /// 16px - Large
  static const double lg = 16.0;

  /// 20px - Large plus
  static const double lgPlus = 20.0;

  /// 24px - Extra large
  static const double xl = 24.0;

  /// 32px - Extra extra large
  static const double xxl = 32.0;

  /// 40px - Triple extra large
  static const double xxxl = 40.0;

  /// 48px - Quad extra large
  static const double xxxxl = 48.0;

  /// 56px - 5x large
  static const double xxxxxl = 56.0;

  /// 64px - 6x large
  static const double xxxxxxl = 64.0;

  // ============================================
  // SEMANTIC SPACING
  // ============================================

  /// Screen horizontal padding (16px)
  static const double screenPaddingHorizontal = lg;

  /// Screen vertical padding (16px)
  static const double screenPaddingVertical = lg;

  /// Card internal padding (16px)
  static const double cardPadding = lg;

  /// Card internal padding small (12px)
  static const double cardPaddingSmall = md;

  /// List item padding vertical (12px)
  static const double listItemPaddingVertical = md;

  /// List item padding horizontal (16px)
  static const double listItemPaddingHorizontal = lg;

  /// Section spacing (24px)
  static const double sectionSpacing = xl;

  /// Component spacing (16px)
  static const double componentSpacing = lg;

  /// Input field spacing (8px)
  static const double inputSpacing = sm;

  /// Button padding horizontal (24px)
  static const double buttonPaddingHorizontal = xl;

  /// Button padding vertical (16px)
  static const double buttonPaddingVertical = lg;

  /// Icon padding (8px)
  static const double iconPadding = sm;

  /// Divider spacing (16px)
  static const double dividerSpacing = lg;

  /// Bottom navigation height (80px)
  static const double bottomNavHeight = 80.0;

  /// App bar height (56px)
  static const double appBarHeight = 56.0;

  /// FAB margin (16px)
  static const double fabMargin = lg;

  // ============================================
  // GAP SIZES (for use with SizedBox or Gap)
  // ============================================

  /// Tiny gap (2px)
  static const double gapTiny = xxs;

  /// Small gap (4px)
  static const double gapSmall = xs;

  /// Medium gap (8px)
  static const double gapMedium = sm;

  /// Large gap (12px)
  static const double gapLarge = md;

  /// Extra large gap (16px)
  static const double gapXLarge = lg;

  /// Section gap (24px)
  static const double gapSection = xl;

  // ============================================
  // ICON SIZES
  // ============================================

  /// Extra small icon size (16px)
  static const double iconXs = 16.0;

  /// Small icon size (20px)
  static const double iconSm = 20.0;

  /// Medium icon size (24px)
  static const double iconMd = 24.0;

  /// Large icon size (32px)
  static const double iconLg = 32.0;

  /// Extra large icon size (40px)
  static const double iconXl = 40.0;

  /// Extra extra large icon size (48px)
  static const double iconXxl = 48.0;

  /// Huge icon size (64px)
  static const double iconHuge = 64.0;

  // ============================================
  // AVATAR SIZES
  // ============================================

  /// Extra small avatar (24px)
  static const double avatarXs = 24.0;

  /// Small avatar (32px)
  static const double avatarSm = 32.0;

  /// Medium avatar (40px)
  static const double avatarMd = 40.0;

  /// Large avatar (48px)
  static const double avatarLg = 48.0;

  /// Extra large avatar (56px)
  static const double avatarXl = 56.0;

  /// Extra extra large avatar (72px)
  static const double avatarXxl = 72.0;

  /// Profile avatar (100px)
  static const double avatarProfile = 100.0;

  // ============================================
  // BUTTON HEIGHTS
  // ============================================

  /// Small button height (36px)
  static const double buttonHeightSm = 36.0;

  /// Medium button height (44px) - Minimum touch target
  static const double buttonHeightMd = 44.0;

  /// Large button height (52px)
  static const double buttonHeightLg = 52.0;

  /// Extra large button height (56px)
  static const double buttonHeightXl = 56.0;

  // ============================================
  // INPUT HEIGHTS
  // ============================================

  /// Small input height (40px)
  static const double inputHeightSm = 40.0;

  /// Medium input height (48px)
  static const double inputHeightMd = 48.0;

  /// Large input height (56px)
  static const double inputHeightLg = 56.0;

  // ============================================
  // MINIMUM TOUCH TARGET
  // ============================================

  /// Minimum touch target size (44px) - Accessibility requirement
  static const double minTouchTarget = 44.0;

  // ============================================
  // CARD DIMENSIONS
  // ============================================

  /// Small card height (80px)
  static const double cardHeightSm = 80.0;

  /// Medium card height (120px)
  static const double cardHeightMd = 120.0;

  /// Large card height (160px)
  static const double cardHeightLg = 160.0;

  /// Carousel card height (180px)
  static const double carouselCardHeight = 180.0;

  /// Hero banner height (200px)
  static const double heroBannerHeight = 200.0;

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get spacing value by multiplier (base * multiplier)
  static double multiply(double multiplier) => base * multiplier;

  /// Get responsive spacing based on screen width
  static double responsive(double screenWidth, {double factor = 1.0}) {
    if (screenWidth < 360) {
      return base * 0.75 * factor;
    } else if (screenWidth < 400) {
      return base * factor;
    } else if (screenWidth < 600) {
      return base * 1.25 * factor;
    } else {
      return base * 1.5 * factor;
    }
  }
}

