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
  static const Color darkBackground = Color(0xFF0A0E27);

  /// Lighter navy surface - cards, containers
  static const Color darkSurface = Color(0xFF1A1F3A);

  /// Even lighter surface for elevated elements
  static const Color darkSurfaceLight = Color(0xFF2A2F4A);

  /// Subtle surface for hover/pressed states
  static const Color darkSurfaceHover = Color(0xFF353A5A);

  // Text Colors (Dark Theme)
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB8B8D1);
  static const Color darkTextTertiary = Color(0xFF6B6B8C);
  static const Color darkTextDisabled = Color(0xFF4A4A5C);

  // ============================================================
  // LIGHT THEME COLORS
  // ============================================================

  /// Light background
  static const Color lightBackground = Color(0xFFF5F7FA);

  /// Light surface - cards, containers
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Slightly darker surface for depth
  static const Color lightSurfaceDark = Color(0xFFF0F2F5);

  /// Hover state
  static const Color lightSurfaceHover = Color(0xFFE8EAED);

  // Text Colors (Light Theme)
  static const Color lightTextPrimary = Color(0xFF1A1F3A);
  static const Color lightTextSecondary = Color(0xFF4A5568);
  static const Color lightTextTertiary = Color(0xFF718096);
  static const Color lightTextDisabled = Color(0xFFA0AEC0);

  // ============================================================
  // BRAND COLORS (Gradients)
  // ============================================================

  /// Primary gradient - Purple-Blue
  static const Color primaryStart = Color(0xFF667EEA);
  static const Color primaryEnd = Color(0xFF764BA2);

  /// Secondary gradient - Cyan
  static const Color secondaryStart = Color(0xFF4FACFE);
  static const Color secondaryEnd = Color(0xFF00F2FE);

  /// Accent gradient - Pink-Orange (for special elements)
  static const Color accentStart = Color(0xFFF093FB);
  static const Color accentEnd = Color(0xFFF5576C);

  /// Success gradient - Green
  static const Color successStart = Color(0xFF43E97B);
  static const Color successEnd = Color(0xFF38F9D7);

  // ============================================================
  // SEMANTIC COLORS
  // ============================================================

  /// Success state
  static const Color success = Color(0xFF43E97B);
  static const Color successLight = Color(0xFF6FFFA1);
  static const Color successDark = Color(0xFF2EC55F);

  /// Error state
  static const Color error = Color(0xFFFF6A88);
  static const Color errorLight = Color(0xFFFF8FA5);
  static const Color errorDark = Color(0xFFE5546E);

  /// Warning state
  static const Color warning = Color(0xFFFEE140);
  static const Color warningLight = Color(0xFFFFED70);
  static const Color warningDark = Color(0xFFE5CA2E);

  /// Info state
  static const Color info = Color(0xFF4FACFE);
  static const Color infoLight = Color(0xFF7DC4FF);
  static const Color infoDark = Color(0xFF3594E5);

  // ============================================================
  // SPECIAL PURPOSE COLORS
  // ============================================================

  /// Code background (VS Code dark theme inspired)
  static const Color codeBackground = Color(0xFF1E1E1E);
  static const Color codeBackgroundLight = Color(0xFFF8F9FA);

  /// Poetry glow effect
  static const Color poetryGlow = Color(0xFF9D50BB);

  /// Premium/Pro badge color
  static const Color premium = Color(0xFFFFD700); // Gold

  /// Guest mode indicator
  static const Color guest = Color(0xFF718096);

  // ============================================================
  // SYNTAX HIGHLIGHTING COLORS (for code editor)
  // ============================================================

  static const Color syntaxKeyword = Color(0xFFC586C0);
  static const Color syntaxString = Color(0xFFCE9178);
  static const Color syntaxComment = Color(0xFF6A9955);
  static const Color syntaxFunction = Color(0xFFDCDCAA);
  static const Color syntaxVariable = Color(0xFF9CDCFE);
  static const Color syntaxNumber = Color(0xFFB5CEA8);

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
      Color(0xFF0A0E27),
      Color(0xFF1A1F3A),
      Color(0xFF2A2F4A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // SHADOW COLORS
  // ============================================================

  static final Color shadowDark = Colors.black.withOpacity(0.3);
  static final Color shadowLight = Colors.black.withOpacity(0.1);
  static final Color glowShadow = poetryGlow.withOpacity(0.4);

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
      Color start,
      Color end, {
        AlignmentGeometry begin = Alignment.topLeft,
        AlignmentGeometry end = Alignment.bottomRight,
      }) {
    return LinearGradient(
      colors: [start, end],
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

  // Haiku - Calm, minimalist (Blue-Green)
  static const Color haikuPrimary = Color(0xFF4FACFE);
  static const Color haikuSecondary = Color(0xFF38F9D7);
  static const LinearGradient haikuGradient = LinearGradient(
    colors: [haikuPrimary, haikuSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sonnet - Classical, elegant (Purple-Gold)
  static const Color sonnetPrimary = Color(0xFF764BA2);
  static const Color sonnetSecondary = Color(0xFFFFD700);
  static const LinearGradient sonnetGradient = LinearGradient(
    colors: [sonnetPrimary, sonnetSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Free Verse - Creative, flowing (Pink-Orange)
  static const Color freeVersePrimary = Color(0xFFF093FB);
  static const Color freeVerseSecondary = Color(0xFFF5576C);
  static const LinearGradient freeVerseGradient = LinearGradient(
    colors: [freeVersePrimary, freeVerseSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Cyberpunk - Edgy, futuristic (Neon Green-Blue)
  static const Color cyberpunkPrimary = Color(0xFF00F2FE);
  static const Color cyberpunkSecondary = Color(0xFF43E97B);
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