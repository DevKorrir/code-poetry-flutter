import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Text Styles for Code Poetry
/// Defines typography system with three font families:
/// - JetBrains Mono: For code
/// - Spectral: For poetry
/// - System Default: For UI elements
class AppTextStyles {
  const AppTextStyles();

  // ============================================================
  // FONT FAMILIES
  // ============================================================

  static const String fontCode = 'JetBrainsMono';
  static const String fontPoetry = 'Spectral';
  static const String fontUI = 'System'; // Uses system default

  // ============================================================
  // HEADING STYLES (UI)
  // ============================================================

  /// H1 - Large titles
  static TextStyle h1({Color? color}) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: color,
  );

  /// H2 - Section headers
  static TextStyle h2({Color? color}) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.3,
    color: color,
  );

  /// H3 - Card headers
  static TextStyle h3({Color? color}) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: color,
  );

  /// H4 - Small headers
  static TextStyle h4({Color? color}) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: color,
  );

  /// H5 - Tiny headers
  static TextStyle h5({Color? color}) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: color,
  );

  // ============================================================
  // BODY STYLES (UI)
  // ============================================================

  /// Body Large - Main content
  static TextStyle bodyLarge({Color? color}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: color,
  );

  /// Body Medium - Secondary content
  static TextStyle bodyMedium({Color? color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: color,
  );

  /// Body Small - Tertiary content
  static TextStyle bodySmall({Color? color}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: color,
  );

  // ============================================================
  // BUTTON STYLES
  // ============================================================

  /// Button Large
  static TextStyle buttonLarge({Color? color}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: color ?? Colors.white,
  );

  /// Button Medium
  static TextStyle buttonMedium({Color? color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: color ?? Colors.white,
  );

  /// Button Small
  static TextStyle buttonSmall({Color? color}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: color ?? Colors.white,
  );

  // ============================================================
  // LABEL STYLES
  // ============================================================

  /// Label Large
  static TextStyle labelLarge({Color? color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.1,
    color: color,
  );

  /// Label Medium
  static TextStyle labelMedium({Color? color}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.1,
    color: color,
  );

  /// Label Small
  static TextStyle labelSmall({Color? color}) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.2,
    color: color,
  );

  // ============================================================
  // CODE STYLES (Monospace)
  // ============================================================

  /// Code Large - Main code editor
  static TextStyle codeLarge({Color? color}) => TextStyle(
    fontFamily: fontCode,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.6,
    letterSpacing: 0,
    color: color,
  );

  /// Code Medium - Inline code
  static TextStyle codeMedium({Color? color}) => TextStyle(
    fontFamily: fontCode,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0,
    color: color,
  );

  /// Code Small - Code snippets
  static TextStyle codeSmall({Color? color}) => TextStyle(
    fontFamily: fontCode,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0,
    color: color,
  );

  // ============================================================
  // POETRY STYLES (Serif - Elegant)
  // ============================================================

  /// Poetry Title - Poem header
  static TextStyle poetryTitle({Color? color}) => TextStyle(
    fontFamily: fontPoetry,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: color ?? AppColors.darkTextPrimary,
  );

  /// Poetry Large - Main poem text
  static TextStyle poetryLarge({Color? color}) => TextStyle(
    fontFamily: fontPoetry,
    fontSize: 20,
    fontWeight: FontWeight.normal,
    height: 1.8,
    letterSpacing: 0.3,
    fontStyle: FontStyle.italic,
    color: color ?? AppColors.darkTextPrimary,
  );

  /// Poetry Medium - Secondary poem text
  static TextStyle poetryMedium({Color? color}) => TextStyle(
    fontFamily: fontPoetry,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.7,
    letterSpacing: 0.2,
    fontStyle: FontStyle.italic,
    color: color,
  );

  /// Poetry Small - Poem metadata
  static TextStyle poetrySmall({Color? color}) => TextStyle(
    fontFamily: fontPoetry,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.6,
    fontStyle: FontStyle.italic,
    color: color,
  );

  // ============================================================
  // SPECIAL STYLES
  // ============================================================

  /// Caption - For small text, timestamps
  static TextStyle caption({Color? color}) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.3,
    color: color,
  );

  /// Overline - For labels above content
  static TextStyle overline({Color? color}) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 1.5,
    color: color,
  ).copyWith(
    // Make uppercase
    fontFeatures: [const FontFeature.enable('smcp')],
  );

  /// Link style
  static TextStyle link({Color? color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    decoration: TextDecoration.underline,
    color: color ?? AppColors.primaryStart,
  );

  /// Error text
  static TextStyle error({Color? color}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: color ?? AppColors.error,
  );

  // ============================================================
  // GRADIENT TEXT (for special headings)
  // ============================================================

  /// Apply gradient to text (use with Shader)
  static TextStyle gradientText(TextStyle baseStyle) {
    return baseStyle.copyWith(
      foreground: Paint()
        ..shader = AppColors.primaryGradient.createShader(
          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
        ),
    );
  }

  // ============================================================
  // THEME-AWARE STYLES
  // ============================================================

  /// Get text style adapted for theme
  static TextStyle adaptive({
    required TextStyle baseStyle,
    required bool isDark,
    Color? lightColor,
    Color? darkColor,
  }) {
    return baseStyle.copyWith(
      color: isDark
          ? (darkColor ?? AppColors.darkTextPrimary)
          : (lightColor ?? AppColors.lightTextPrimary),
    );
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Make text bold
  static TextStyle bold(TextStyle style) => style.copyWith(
    fontWeight: FontWeight.bold,
  );

  /// Make text italic
  static TextStyle italic(TextStyle style) => style.copyWith(
    fontStyle: FontStyle.italic,
  );

  /// Change color
  static TextStyle withColor(TextStyle style, Color color) => style.copyWith(
    color: color,
  );

  /// Change size
  static TextStyle withSize(TextStyle style, double size) => style.copyWith(
    fontSize: size,
  );

  /// Add letter spacing
  static TextStyle withSpacing(TextStyle style, double spacing) =>
      style.copyWith(
        letterSpacing: spacing,
      );

  /// Add underline
  static TextStyle underlined(TextStyle style) => style.copyWith(
    decoration: TextDecoration.underline,
  );

  /// Add strikethrough
  static TextStyle strikethrough(TextStyle style) => style.copyWith(
    decoration: TextDecoration.lineThrough,
  );
}

/// Text Theme Extensions
/// Provides quick access to text styles
extension TextStyleExtensions on BuildContext {
  /// Quick access to text styles
  AppTextStyles get textStyles => AppTextStyles();
}