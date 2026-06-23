import 'package:flutter/material.dart';

/// Design tokens + theme for MultiFileOpener.
///
/// Ported 1:1 from the Google **Stitch** "MultiFile Batch Opener" design system
/// (indigo `#3F51B5` seed, Material 3 FIDELITY tonal, light mode, 8px roundness,
/// Roboto Flex / native Roboto). The exact token values come from the generated
/// design captured in `design/stitch/`.
abstract final class AppColors {
  // ---- Primary -------------------------------------------------------------
  static const Color primary = Color(0xFF24389C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF3F51B5); // the indigo seed
  static const Color onPrimaryContainer = Color(0xFFCACFFF);
  static const Color inversePrimary = Color(0xFFBAC3FF);

  // ---- Secondary -----------------------------------------------------------
  static const Color secondary = Color(0xFF5B5D70);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE0E1F8);
  static const Color onSecondaryContainer = Color(0xFF616376);

  // ---- Tertiary ------------------------------------------------------------
  static const Color tertiary = Color(0xFF5A384F);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF744F67);
  static const Color onTertiaryContainer = Color(0xFFF4C5E1);

  // ---- Error ---------------------------------------------------------------
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ---- Success (file opened) — not an M3 scheme slot -----------------------
  static const Color success = Color(0xFF146C2E);

  // ---- Surfaces ------------------------------------------------------------
  static const Color surface = Color(0xFFFBF8FE);
  static const Color onSurface = Color(0xFF1B1B1F);
  static const Color onSurfaceVariant = Color(0xFF454652);
  static const Color surfaceBright = Color(0xFFFBF8FE);
  static const Color surfaceDim = Color(0xFFDCD9DE);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F2F8);
  static const Color surfaceContainer = Color(0xFFF0EDF2);
  static const Color surfaceContainerHigh = Color(0xFFEAE7ED);
  static const Color surfaceContainerHighest = Color(0xFFE4E1E7);

  // ---- Outline / misc ------------------------------------------------------
  static const Color outline = Color(0xFF757684);
  static const Color outlineVariant = Color(0xFFC5C5D4);
  static const Color inverseSurface = Color(0xFF303034);
  static const Color onInverseSurface = Color(0xFFF3F0F5);
  static const Color surfaceTint = Color(0xFF4355B9);
}

/// Responsive layout breakpoints + content max-widths (logical pixels).
///
/// Below [tablet] the UI is the compact phone layout; at or above it the
/// content is centred within a max width and the home cards sit side-by-side.
abstract final class Breakpoints {
  /// Width at/above which the tablet (medium+) layout kicks in.
  static const double tablet = 600;

  /// Max width the home content column is centred within on large screens.
  static const double maxContentWidth = 840;

  /// Max width the settings content column is centred within.
  static const double maxSettingsWidth = 720;

  /// Max width the modal sheets (app picker) are capped to on large screens.
  static const double maxSheetWidth = 560;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;
}

const ColorScheme _kColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  primaryContainer: AppColors.primaryContainer,
  onPrimaryContainer: AppColors.onPrimaryContainer,
  inversePrimary: AppColors.inversePrimary,
  secondary: AppColors.secondary,
  onSecondary: AppColors.onSecondary,
  secondaryContainer: AppColors.secondaryContainer,
  onSecondaryContainer: AppColors.onSecondaryContainer,
  tertiary: AppColors.tertiary,
  onTertiary: AppColors.onTertiary,
  tertiaryContainer: AppColors.tertiaryContainer,
  onTertiaryContainer: AppColors.onTertiaryContainer,
  error: AppColors.error,
  onError: AppColors.onError,
  errorContainer: AppColors.errorContainer,
  onErrorContainer: AppColors.onErrorContainer,
  surface: AppColors.surface,
  onSurface: AppColors.onSurface,
  onSurfaceVariant: AppColors.onSurfaceVariant,
  surfaceBright: AppColors.surfaceBright,
  surfaceDim: AppColors.surfaceDim,
  surfaceContainerLowest: AppColors.surfaceContainerLowest,
  surfaceContainerLow: AppColors.surfaceContainerLow,
  surfaceContainer: AppColors.surfaceContainer,
  surfaceContainerHigh: AppColors.surfaceContainerHigh,
  surfaceContainerHighest: AppColors.surfaceContainerHighest,
  outline: AppColors.outline,
  outlineVariant: AppColors.outlineVariant,
  inverseSurface: AppColors.inverseSurface,
  onInverseSurface: AppColors.onInverseSurface,
  surfaceTint: AppColors.surfaceTint,
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
);

/// Builds the app-wide [ThemeData] from the Stitch design tokens.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: _kColorScheme,
    scaffoldBackgroundColor: _kColorScheme.surface,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.outlineVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.inverseSurface,
      contentTextStyle: const TextStyle(color: AppColors.onInverseSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
