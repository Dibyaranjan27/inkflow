import 'package:flutter/material.dart';

/// Centralized Design System Colors for Inkflow
class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFFBE7066); // Warm Terra Cotta / Rose Brown
  static const Color primaryLight = Color(0xFFFFD5CA); // Soft Peach Track
  static const Color primaryDark = Color(0xFF8E4038); // Deep Rose
  static const Color primaryContainer = Color(0xFFEFC5C1); // Light Accent Container
  static const Color primaryContainerDark = Color(0xFF5A2A25); // Dark Accent Container

  // Background & Surface - Light
  static const Color background = Color(0xFFF1F4ED); // Pale Sage Cream (Scaffold Background)
  static const Color backgroundLight = Color(0xFFF1F4ED); // Semantic alias
  static const Color surface = Colors.white; // Pure White Surface (Cards, Dialogs, Inputs)
  static const Color surfaceLight = Colors.white; // Semantic alias
  static const Color cardLight = Colors.white;

  // Background & Surface - Dark
  static const Color backgroundDark = Color(0xFF121212); // Deep Charcoal / Dark Scaffold
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark Surface / AppBar
  static const Color cardDark = Color(0xFF242424); // Dark Card Surface

  // Text Colors - Light
  static const Color textPrimary = Color(0xFF2C2C2C); // Standardized Charcoal Primary Text
  static const Color textPrimaryLegacy = Color(0xFF393939); // Legacy alias for kBlackColor
  static const Color textPrimaryLight = textPrimary;
  static const Color textSecondary = Color(0xFF757575); // Neutral Grey Secondary Text
  static const Color textSecondaryLight = Color(0xFF8F8F8F); // Legacy secondary (kLightBlackColor)
  static const Color textMuted = Color(0xFF9E9E9E); // Muted Hint / Caption Text

  // Text Colors - Dark
  static const Color textPrimaryDark = Color(0xFFF5F5F5); // High Contrast Light Grey
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // Medium Grey
  static const Color textMutedDark = Color(0x8AFFFFFF); // Muted Hint Dark (60% white)

  // Functional & Semantic Colors
  static const Color accent = Color(0xFFF48A37); // Warm Amber / kIconColor
  static const Color error = Color(0xFFD32F2F); // Material Red
  static const Color success = Color(0xFF388E3C); // Forest Green
  static const Color warning = Color(0xFFF57C00); // Deep Orange
  static const Color info = Color(0xFF1976D2); // Royal Blue
  static const Color star = Color(0xFFFFC107); // Amber Star Rating
  static const Color ratingStar = Color(0xFFFFC107); // Semantic alias

  // Structural & Border Tokens
  static const Color border = Color(0xFFD0D5DD); // Input / Card Border Light
  static const Color borderDark = Color(0xFF424242); // Border Dark
  static const Color divider = Color(0x2E000000); // Light Divider (~18% black)
  static const Color dividerDark = Color(0x1FFFFFFF); // Dark Divider (~12% white)

  // Shadow Tokens (Compile-time const 8-digit ARGB hex - zero precision loss, replaces deprecated .withOpacity)
  static const Color shadow = Color(0xD6D3D3D3); // 84% opacity on #D3D3D3 (kShadowColor)
  static const Color shadowLight = Color(0x1A000000); // Subtle 10% black elevation
  static const Color shadowMedium = Color(0x33000000); // 20% black elevation
  static const Color shadowDark = Color(0x80000000); // 50% black dark mode shadow

  // Wave Spinner & Loading Tokens (kLogoColor, kWaveColor, kTrackColor)
  static const Color spinnerLogo = Color(0xFFF5C0B9);
  static const Color spinnerWave = Color(0xFFB7B7B7);
  static const Color spinnerTrack = Color(0xFFE6E6E6);

  // Category Badge Palette
  static const Color categoryFiction = Color(0xFFBE7066);
  static const Color categoryScience = Color(0xFFFFD5CA);
  static const Color categoryHistory = Color(0xFF8D6E63);
  static const Color categoryTechnology = Color(0xFFD7CCC8);
}

/// Centralized Typography Hierarchy for Inkflow
class AppTextStyles {
  AppTextStyles._();

  // Display Styles
  static const TextStyle display = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Headline Styles
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Semantic Aliases
  static const TextStyle button = labelLarge;
  static const TextStyle caption = bodySmall;

  // TextTheme Generators
  static TextTheme get lightTextTheme => const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryDark),
        displaySmall: displaySmall.copyWith(color: AppColors.textPrimaryDark),
        headlineLarge: headlineLarge.copyWith(color: AppColors.textPrimaryDark),
        headlineMedium: headlineMedium.copyWith(color: AppColors.textPrimaryDark),
        headlineSmall: headlineSmall.copyWith(color: AppColors.textPrimaryDark),
        titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryDark),
        titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryDark),
        titleSmall: titleSmall.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: bodySmall.copyWith(color: AppColors.textSecondaryDark),
        labelLarge: labelLarge,
        labelMedium: labelMedium.copyWith(color: AppColors.textSecondaryDark),
        labelSmall: labelSmall.copyWith(color: AppColors.textSecondaryDark),
      );
}

/// Centralized ThemeData Provider for Inkflow
class AppTheme {
  AppTheme._();

  /// Light Theme Definition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.border,
        shadow: AppColors.shadowLight,
      ),
      textTheme: AppTextStyles.lightTextTheme,
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white70,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.primaryLight,
      ),
    );
  }

  /// Dark Theme Definition
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainerDark,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.borderDark,
        shadow: AppColors.shadowDark,
      ),
      textTheme: AppTextStyles.darkTextTheme,
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 2,
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white70,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        prefixIconColor: AppColors.textSecondaryDark,
        suffixIconColor: AppColors.textSecondaryDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.primaryLight,
      ),
    );
  }
}
