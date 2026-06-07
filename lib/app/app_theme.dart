import 'package:flutter/material.dart';

class CatchLingoColors {
  const CatchLingoColors._();

  static const seed = Color(0xFF5B5FEF);
  static const background = Color(0xFFF7F8FC);
  static const textPrimary = Color(0xFF202338);
  static const successSurface = Color(0xFFE5F7EF);
  static const successBorder = Color(0xFF65C99A);
  static const successText = Color(0xFF145C3F);
  static const successIcon = Color(0xFF168657);
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
        color: Colors.white,
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
        side: BorderSide(color: Color(0xFFE2E5F2)),
      ),
      useMaterial3: true,
    );
  }
}
