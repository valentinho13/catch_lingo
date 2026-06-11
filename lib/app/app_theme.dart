import 'package:flutter/material.dart';

/// CatchLingo warm field-journal palette.
///
/// Locked direction: cream paper, leaf green, honey amber.
/// The cool indigo/teal "scanner" look is retired — do not reintroduce it.
class CatchLingoColors {
  const CatchLingoColors._();

  /// Leaf green. Seed for the Material 3 scheme and main action color.
  static const seed = Color(0xFF3F6B4A);

  /// Warm cream paper background.
  static const background = Color(0xFFFAF6EB);

  /// Warm near-white for cards.
  static const card = Color(0xFFFFFDF6);

  static const textPrimary = Color(0xFF2F2C20);
  static const textMuted = Color(0xFF7A745F);

  /// Parchment surface for discovery panels.
  static const discoverySurface = Color(0xFFF4EEDD);

  /// Honey amber accent — used sparingly for celebration and review hints.
  static const amberAccent = Color(0xFFD99A2B);
  static const amberSurface = Color(0xFFF9EFD8);
  static const amberText = Color(0xFF7A5614);

  static const successSurface = Color(0xFFE9F2E2);
  static const successBorder = Color(0xFF8FBC83);
  static const successText = Color(0xFF2C5230);
  static const successIcon = Color(0xFF3E7A47);
}

class CatchLingoSpacing {
  const CatchLingoSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const screen = 24.0;
}

class CatchLingoRadius {
  const CatchLingoRadius._();

  static const button = 18.0;
  static const card = 24.0;
  static const panel = 28.0;
  static const chip = 999.0;
}

class CatchLingoMotion {
  const CatchLingoMotion._();

  static const tap = Duration(milliseconds: 100);
  static const chip = Duration(milliseconds: 180);
  static const state = Duration(milliseconds: 220);
  static const feedback = Duration(milliseconds: 240);
  static const reveal = Duration(milliseconds: 320);
  static const homeIntro = Duration(milliseconds: 760);
}

class CatchLingoTheme {
  const CatchLingoTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: CatchLingoColors.seed,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CatchLingoColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: CatchLingoColors.background,
        foregroundColor: CatchLingoColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: CatchLingoColors.card,
        surfaceTintColor: CatchLingoColors.card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CatchLingoRadius.card),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CatchLingoRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CatchLingoRadius.button),
          ),
        ),
      ),
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(),
        side: BorderSide(color: Color(0xFFE6DEC8)),
      ),
      useMaterial3: true,
    );
  }
}
