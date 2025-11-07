import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

/// App Theme Configuration
/// Defines both dark and light themes with complete styling
class AppTheme {
  AppTheme._();

  // ============================================================
  // DARK THEME (Default - Midnight Poetry)
  // ============================================================

  static ThemeData darkTheme = ThemeData(
    // Brightness
    brightness: Brightness.dark,
    useMaterial3: true,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryStart,
      secondary: AppColors.secondaryStart,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      onBackground: AppColors.darkTextPrimary,
      onError: Colors.white,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.darkBackground,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.h3(),
      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
        size: 24,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 4,
      shadowColor: AppColors.shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(8),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryStart,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: AppColors.shadowDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.buttonMedium(),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryStart,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTextStyles.buttonMedium(),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryStart,
        side: const BorderSide(color: AppColors.primaryStart, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.buttonMedium(),
      ),
    ),

    // Input Decoration (Text Fields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryStart, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: AppTextStyles.bodyMedium(color: AppColors.darkTextTertiary),
      labelStyle: AppTextStyles.labelMedium(),
      errorStyle: AppTextStyles.error(),
    ),

    // Icon
    iconTheme: const IconThemeData(
      color: AppColors.darkTextSecondary,
      size: 24,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.darkSurfaceLight,
      thickness: 1,
      space: 1,
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryStart,
      unselectedItemColor: AppColors.darkTextTertiary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: AppTextStyles.h3(),
      contentTextStyle: AppTextStyles.bodyMedium(),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryStart,
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurfaceLight,
      deleteIconColor: AppColors.darkTextSecondary,
      labelStyle: AppTextStyles.labelMedium(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurface,
      contentTextStyle: AppTextStyles.bodyMedium(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryStart,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1(),
      displayMedium: AppTextStyles.h2(),
      displaySmall: AppTextStyles.h3(),
      headlineLarge: AppTextStyles.h3(),
      headlineMedium: AppTextStyles.h4(),
      headlineSmall: AppTextStyles.h5(),
      titleLarge: AppTextStyles.h4(),
      titleMedium: AppTextStyles.h5(),
      titleSmall: AppTextStyles.labelLarge(),
      bodyLarge: AppTextStyles.bodyLarge(),
      bodyMedium: AppTextStyles.bodyMedium(),
      bodySmall: AppTextStyles.bodySmall(),
      labelLarge: AppTextStyles.labelLarge(),
      labelMedium: AppTextStyles.labelMedium(),
      labelSmall: AppTextStyles.labelSmall(),
    ),
  );

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData lightTheme = ThemeData(
    // Brightness
    brightness: Brightness.light,
    useMaterial3: true,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryStart,
      secondary: AppColors.secondaryStart,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      onBackground: AppColors.lightTextPrimary,
      onError: Colors.white,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.lightBackground,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.h3(color: AppColors.lightTextPrimary),
      iconTheme: const IconThemeData(
        color: AppColors.lightTextPrimary,
        size: 24,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(8),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryStart,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.buttonMedium(),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryStart,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTextStyles.buttonMedium(),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryStart,
        side: const BorderSide(color: AppColors.primaryStart, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.buttonMedium(),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryStart, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle:
      AppTextStyles.bodyMedium(color: AppColors.lightTextTertiary),
      labelStyle: AppTextStyles.labelMedium(color: AppColors.lightTextSecondary),
      errorStyle: AppTextStyles.error(),
    ),

    // Icon
    iconTheme: const IconThemeData(
      color: AppColors.lightTextSecondary,
      size: 24,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.lightSurfaceDark,
      thickness: 1,
      space: 1,
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.primaryStart,
      unselectedItemColor: AppColors.lightTextTertiary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: AppTextStyles.h3(color: AppColors.lightTextPrimary),
      contentTextStyle: AppTextStyles.bodyMedium(color: AppColors.lightTextSecondary),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryStart,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSurfaceDark,
      deleteIconColor: AppColors.lightTextSecondary,
      labelStyle: AppTextStyles.labelMedium(color: AppColors.lightTextPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightSurface,
      contentTextStyle: AppTextStyles.bodyMedium(color: AppColors.lightTextPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryStart,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1(color: AppColors.lightTextPrimary),
      displayMedium: AppTextStyles.h2(color: AppColors.lightTextPrimary),
      displaySmall: AppTextStyles.h3(color: AppColors.lightTextPrimary),
      headlineLarge: AppTextStyles.h3(color: AppColors.lightTextPrimary),
      headlineMedium: AppTextStyles.h4(color: AppColors.lightTextPrimary),
      headlineSmall: AppTextStyles.h5(color: AppColors.lightTextPrimary),
      titleLarge: AppTextStyles.h4(color: AppColors.lightTextPrimary),
      titleMedium: AppTextStyles.h5(color: AppColors.lightTextPrimary),
      titleSmall: AppTextStyles.labelLarge(color: AppColors.lightTextPrimary),
      bodyLarge: AppTextStyles.bodyLarge(color: AppColors.lightTextSecondary),
      bodyMedium: AppTextStyles.bodyMedium(color: AppColors.lightTextSecondary),
      bodySmall: AppTextStyles.bodySmall(color: AppColors.lightTextTertiary),
      labelLarge: AppTextStyles.labelLarge(color: AppColors.lightTextSecondary),
      labelMedium: AppTextStyles.labelMedium(color: AppColors.lightTextSecondary),
      labelSmall: AppTextStyles.labelSmall(color: AppColors.lightTextTertiary),
    ),
  );

  // ============================================================
  // SYSTEM UI OVERLAY STYLES
  // ============================================================

  /// Dark status bar (for light backgrounds)
  static const SystemUiOverlayStyle darkStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.lightSurface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// Light status bar (for dark backgrounds)
  static const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.darkBackground,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}