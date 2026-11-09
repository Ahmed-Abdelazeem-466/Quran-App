import 'package:flutter/material.dart';

enum QuranThemeFamily {
  emerald('زمردي'),
  midnight('ليل أزرق'),
  desert('رملي ذهبي'),
  rosewood('خشب وردي'),
  ocean('محيطي'),
  violet('بنفسجي هادئ');

  const QuranThemeFamily(this.label);

  final String label;
}

class QuranThemePalette {
  const QuranThemePalette({
    required this.lightPrimary,
    required this.lightSecondary,
    required this.lightBackground,
    required this.lightSurface,
    required this.darkPrimary,
    required this.darkSecondary,
    required this.darkBackground,
    required this.darkSurface,
  });

  final Color lightPrimary;
  final Color lightSecondary;
  final Color lightBackground;
  final Color lightSurface;
  final Color darkPrimary;
  final Color darkSecondary;
  final Color darkBackground;
  final Color darkSurface;
}

abstract final class AppTheme {
  static const emerald = Color(0xFF0D5E4A);
  static const gold = Color(0xFFC79A3B);

  static const _palettes = <QuranThemeFamily, QuranThemePalette>{
    QuranThemeFamily.emerald: QuranThemePalette(
      lightPrimary: Color(0xFF0D5E4A),
      lightSecondary: Color(0xFFC79A3B),
      lightBackground: Color(0xFFF8F4E8),
      lightSurface: Color(0xFFFFFFFF),
      darkPrimary: Color(0xFF73C9A8),
      darkSecondary: Color(0xFFF0C46D),
      darkBackground: Color(0xFF0B1713),
      darkSurface: Color(0xFF15231E),
    ),
    QuranThemeFamily.midnight: QuranThemePalette(
      lightPrimary: Color(0xFF244D78),
      lightSecondary: Color(0xFF587FA6),
      lightBackground: Color(0xFFF6F8FC),
      lightSurface: Color(0xFFFFFFFF),
      darkPrimary: Color(0xFF9EC7F5),
      darkSecondary: Color(0xFFB7D5F4),
      darkBackground: Color(0xFF0D1728),
      darkSurface: Color(0xFF16243A),
    ),
    QuranThemeFamily.desert: QuranThemePalette(
      lightPrimary: Color(0xFF765028),
      lightSecondary: Color(0xFFAD7A37),
      lightBackground: Color(0xFFFBF3E5),
      lightSurface: Color(0xFFFFFDF8),
      darkPrimary: Color(0xFFE9BF7B),
      darkSecondary: Color(0xFFF1CC91),
      darkBackground: Color(0xFF21160D),
      darkSurface: Color(0xFF322316),
    ),
    QuranThemeFamily.rosewood: QuranThemePalette(
      lightPrimary: Color(0xFF79434F),
      lightSecondary: Color(0xFFA96578),
      lightBackground: Color(0xFFFFF6F7),
      lightSurface: Color(0xFFFFFFFF),
      darkPrimary: Color(0xFFF1B1C0),
      darkSecondary: Color(0xFFF3BEC9),
      darkBackground: Color(0xFF211217),
      darkSurface: Color(0xFF342029),
    ),
    QuranThemeFamily.ocean: QuranThemePalette(
      lightPrimary: Color(0xFF126878),
      lightSecondary: Color(0xFF2999A9),
      lightBackground: Color(0xFFF2FBFC),
      lightSurface: Color(0xFFFFFFFF),
      darkPrimary: Color(0xFF83D9E5),
      darkSecondary: Color(0xFFA0E6EF),
      darkBackground: Color(0xFF081C22),
      darkSurface: Color(0xFF102B33),
    ),
    QuranThemeFamily.violet: QuranThemePalette(
      lightPrimary: Color(0xFF61447F),
      lightSecondary: Color(0xFF9272B4),
      lightBackground: Color(0xFFF9F6FC),
      lightSurface: Color(0xFFFFFFFF),
      darkPrimary: Color(0xFFD4B9F1),
      darkSecondary: Color(0xFFE0CAF6),
      darkBackground: Color(0xFF181121),
      darkSurface: Color(0xFF282035),
    ),
  };

  static QuranThemePalette palette(QuranThemeFamily family) =>
      _palettes[family]!;

  static ThemeData light([
    QuranThemeFamily family = QuranThemeFamily.emerald,
  ]) => _build(Brightness.light, palette(family));

  static ThemeData dark([QuranThemeFamily family = QuranThemeFamily.emerald]) =>
      _build(Brightness.dark, palette(family));

  static ThemeData _build(Brightness brightness, QuranThemePalette palette) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? palette.darkPrimary : palette.lightPrimary;
    final secondary = isDark ? palette.darkSecondary : palette.lightSecondary;
    final surface = isDark ? palette.darkSurface : palette.lightSurface;
    final background = isDark
        ? palette.darkBackground
        : palette.lightBackground;
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      secondary: secondary,
      tertiary: secondary,
      surface: surface,
      outline: isDark
          ? surface.withValues(alpha: 0.92)
          : const Color(0xFFE2DCCB),
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'NotoNaskhArabic',
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: 'NotoNaskhArabic'),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontFamily: 'NotoNaskhArabic',
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.7)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'NotoNaskhArabic',
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.65),
      ),
    );
  }
}
