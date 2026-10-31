import 'package:flutter/material.dart';
import 'package:inkflow/theme/app_theme.dart';

// Re-export design system so consumers of constants.dart get AppColors, AppTextStyles, AppTheme
export 'package:inkflow/theme/app_theme.dart';

/// Legacy color constants delegated to [AppColors] design tokens.
/// Maintained for backwards compatibility across existing widgets and screens.
/// Zero breaking changes: all identifiers retain exact types and visual values.
const Color kBlackColor = AppColors.textPrimary;
const Color kLightBlackColor = AppColors.textSecondary;
const Color kIconColor = AppColors.accent;
const Color kProgressIndicator = AppColors.primary;
const Color kScaffoldDarkBackgroundColor = AppColors.backgroundDark;
const Color kAppBarDarkColor = AppColors.surfaceDark;
const Color kBottomNavBarDarkColor = AppColors.surfaceDark;

// Deprecated .withOpacity(.84) replaced with compile-time const 0xD6D3D3D3 ARGB hex via AppColors.shadow
const Color kShadowColor = AppColors.shadow;

const Color kScaffoldBackgroundColor = AppColors.background;
const Color kLogoColor = AppColors.spinnerLogo;
const Color kWaveColor = AppColors.spinnerWave;
const Color kTrackColor = AppColors.spinnerTrack;

// Application Configuration Constants
const String kAppName = 'Inkflow';

/// Google Books API key is loaded dynamically from local.properties or compile-time dart-define.
/// Keep sensitive keys out of tracked source code!
const String kGoogleBooksApiKey =
    String.fromEnvironment('GOOGLE_BOOKS_API_KEY', defaultValue: '');

// Shared Preferences Storage Keys
const String kPrefIsLoggedIn = 'isLoggedIn';
const String kPrefIsFirstOpen = 'isFirstOpen';
const String kPrefIsDarkMode = 'isDarkMode';
const String kPrefEmail = 'email';
const String kPrefUsername = 'username';
