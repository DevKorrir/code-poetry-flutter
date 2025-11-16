import 'package:flutter/material.dart';

/// Midnight Poetry Color Palette
/// A dark, elegant theme inspired by code aesthetics and poetic beauty
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============================================================
  // DARK THEME COLORS (Default)
  // ============================================================

  /// Deep navy background - primary app background
  static const Color darkBackground = Color(0xFF0D1117);

  /// Lighter navy surface - cards, containers
  static const Color darkSurface = Color(0xFF161B22);

  /// Even lighter surface for elevated elements
  static const Color darkSurfaceLight = Color(0xFF21262D);

  /// Subtle surface for hover/pressed states
  static const Color darkSurfaceHover = Color(0xFF30363D);

  // Text Colors (Dark Theme)
  static const Color darkTextPrimary = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFFC9D1D9);
  static const Color darkTextTertiary = Color(0xFF8B949E);
  static const Color darkTextDisabled = Color(0xFF484F58);

  // ============================================================
  // LIGHT THEME COLORS
  // ============================================================

  /// Light background
  static const Color lightBackground = Color(0xFFFFFFFF);

  /// Light surface - cards, containers
  static const Color lightSurface = Color(0xFFF6F8FA);

  /// Slightly darker surface for depth
  static const Color lightSurfaceDark = Color(0xFFEAECEF);

  /// Hover state
  static const Color lightSurfaceHover = Color(0xFFD0D7DE);

  // Text Colors (Light Theme)
  static const Color lightTextPrimary = Color(0xFF1F2328);
  static const Color lightTextSecondary = Color(0xFF656D76);
  static const Color lightTextTertiary = Color(0xFF8B949E);
  static const Color lightTextDisabled = Color(0xFFA0AEC0);

  // ============================================================
  // BRAND COLORS (Gradients)
  // ============================================================

  /// Primary gradient - Purple-Blue
  static const Color primaryStart = Color(0xFF6E40C9);
  static const Color primaryEnd = Color(0xFF2D7FF9);

  /// Secondary gradient - Cyan
  static const Color secondaryStart = Color(0xFF2D7FF9);
  static const Color secondaryEnd = Color(0xFF79C0FF);

  /// Accent gradient - Pink-Orange (for special elements)
  static const Color accentStart = Color(0xFFF778BA);
  static const Color accentEnd = Color(0xFFFFA7D4);

  /// Success gradient - Green
  static const Color successStart = Color(0xFF3FB950);
  static const Color successEnd = Color(0xFF56D364);

  // ============================================================
  // SEMANTIC COLORS
  // ============================================================

  /// Success state
  static const Color success = Color(0xFF3FB950);
  static const Color successLight = Color(0xFF56D364);
  static const Color successDark = Color(0xFF2EA043);

  /// Error state
  static const Color error = Color(0xFFF85149);
  static const Color errorLight = Color(0xFFFA6B65);
  static const Color errorDark = Color(0xFFDA3633);

  /// Warning state
  static const Color warning = Color(0xFFE3B341);
  static const Color warningLight = Color(0xFFE9C366);
  static const Color warningDark = Color(0xFFD29922);

  /// Info state
  static const Color info = Color(0xFF2D7FF9);
  static const Color infoLight = Color(0xFF5B9CFB);
  static const Color infoDark = Color(0xFF1A5FC1);

  // ============================================================
  // SPECIAL PURPOSE COLORS
  // ============================================================

  /// Code background (VS Code dark theme inspired)
  static const Color codeBackground = Color(0xFF161B22);
  static const Color codeBackgroundLight = Color(0xFFF6F8FA);

  /// Poetry glow effect
  static const Color poetryGlow = Color(0xFF6E40C9);

  /// Premium/Pro badge color
  static const Color premium = Color(0xFFE3B341); // Gold

  /// Guest mode indicator
  static const Color guest = Color(0xFF8B949E);

  // ============================================================
  // SYNTAX HIGHLIGHTING COLORS (for code editor)
  // ============================================================

  static const Color syntaxKeyword = Color(0xFFFF7B72);
  static const Color syntaxString = Color(0xFFA5D6FF);
  static const Color syntaxComment = Color(0xFF8B949E);
  static const Color syntaxFunction = Color(0xFFD2A8FF);
  static const Color syntaxVariable = Color(0xFF79C0FF);
  static const Color syntaxNumber = Color(0xFF56D364);

  // ============================================================
  // OPACITY VARIANTS (for overlays, shadows)
  // ============================================================

  static Color darkOverlay({double opacity = 0.5}) =>
      darkBackground.withOpacity(opacity);

  static Color lightOverlay({double opacity = 0.5}) =>
      lightBackground.withOpacity(opacity);

  // ============================================================
  // GRADIENT DEFINITIONS
  // ============================================================

  /// Primary gradient (used for buttons, headers)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary gradient (used for accents)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryStart, secondaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient (for special elements)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentStart, accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [successStart, successEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background gradient (animated)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF0D1117),
      Color(0xFF161B22),
      Color(0xFF21262D),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // SHADOW COLORS
  // ============================================================

  static final Color shadowDark = Colors.black.withOpacity(0.4);
  static final Color shadowLight = Colors.black.withOpacity(0.1);
  static final Color glowShadow = poetryGlow.withOpacity(0.3);

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get text color based on background brightness
  static Color getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? lightTextPrimary
        : darkTextPrimary;
  }

  /// Create a gradient from any two colors
  static LinearGradient customGradient(
      Color startColor,
      Color endColor, {
        AlignmentGeometry begin = Alignment.topLeft,
        AlignmentGeometry end = Alignment.bottomRight,
      }) {
    return LinearGradient(
      colors: [startColor, endColor],
      begin: begin,
      end: end,
    );
  }

  /// Get color based on theme mode
  static Color adaptive({
    required Color light,
    required Color dark,
    required bool isDark,
  }) {
    return isDark ? dark : light;
  }
}

/// Poetry Style Colors
/// Each poetry style gets its own color scheme
class PoetryStyleColors {
  PoetryStyleColors._();

  // Haiku - Calm, minimalist (Blue)
  static const Color haikuPrimary = Color(0xFF2D7FF9);
  static const Color haikuSecondary = Color(0xFF79C0FF);
  static const LinearGradient haikuGradient = LinearGradient(
    colors: [haikuPrimary, haikuSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sonnet - Classical, elegant (Purple)
  static const Color sonnetPrimary = Color(0xFF6E40C9);
  static const Color sonnetSecondary = Color(0xFFD2A8FF);
  static const LinearGradient sonnetGradient = LinearGradient(
    colors: [sonnetPrimary, sonnetSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Free Verse - Creative, flowing (Pink)
  static const Color freeVersePrimary = Color(0xFFF778BA);
  static const Color freeVerseSecondary = Color(0xFFFFA7D4);
  static const LinearGradient freeVerseGradient = LinearGradient(
    colors: [freeVersePrimary, freeVerseSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Cyberpunk - Edgy, futuristic (Green)
  static const Color cyberpunkPrimary = Color(0xFF56D364);
  static const Color cyberpunkSecondary = Color(0xFF3FB950);
  static const LinearGradient cyberpunkGradient = LinearGradient(
    colors: [cyberpunkPrimary, cyberpunkSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Get gradient by style name
  static LinearGradient getGradient(String styleName) {
    switch (styleName.toLowerCase()) {
      case 'haiku':
        return haikuGradient;
      case 'sonnet':
        return sonnetGradient;
      case 'free verse':
        return freeVerseGradient;
      case 'cyberpunk':
        return cyberpunkGradient;
      default:
        return AppColors.primaryGradient;
    }
  }
}