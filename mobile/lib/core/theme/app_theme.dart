import 'package:material_ui/material_ui.dart';

import 'tokens.g.dart';

/// Builds the app theme from the Direction B tokens.
///
/// Urdu uses Gulzar (Nastaliq) for every text style; English uses Baloo 2 for
/// headings and buttons and Atkinson Hyperlegible for body text.
abstract final class AppTheme {
  /// Bold weight for the Baloo 2 variable font.
  static const List<FontVariation> headingBold = [FontVariation('wght', 700)];

  static ThemeData light({Locale locale = const Locale('en')}) {
    final isUrdu = locale.languageCode == 'ur';
    final headingFamily = isUrdu ? IlmFonts.urdu : IlmFonts.heading;
    final bodyFamily = isUrdu ? IlmFonts.urdu : IlmFonts.body;
    // Nastaliq needs taller lines so dots and descenders are not clipped.
    final bodyHeight = isUrdu ? 1.9 : 1.4;

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: IlmColors.marigold,
      onPrimary: IlmColors.aubergine,
      secondary: IlmColors.peacock,
      onSecondary: IlmColors.white,
      tertiary: IlmColors.rose,
      onTertiary: IlmColors.white,
      error: IlmColors.rose,
      onError: IlmColors.white,
      surface: IlmColors.white,
      onSurface: IlmColors.aubergine,
      surfaceContainerLowest: IlmColors.cream,
      outline: IlmColors.sand,
    );

    TextStyle heading(double size) => TextStyle(
      fontFamily: headingFamily,
      fontSize: size,
      fontWeight: FontWeight.w700,
      fontVariations: isUrdu ? null : headingBold,
      color: IlmColors.aubergine,
      height: isUrdu ? 1.8 : 1.2,
    );

    TextStyle body(double size, {FontWeight weight = FontWeight.w400}) =>
        TextStyle(
          fontFamily: bodyFamily,
          fontSize: size,
          fontWeight: weight,
          color: IlmColors.aubergine,
          height: bodyHeight,
        );

    final textTheme = TextTheme(
      displaySmall: heading(32),
      headlineMedium: heading(26),
      headlineSmall: heading(22),
      titleLarge: heading(20),
      titleMedium: body(IlmSize.bodyText, weight: FontWeight.w700),
      bodyLarge: body(IlmSize.bodyText),
      bodyMedium: body(IlmSize.bodyText),
      bodySmall: body(IlmSize.smallText),
      labelLarge: heading(IlmSize.bodyText),
      labelMedium: body(IlmSize.smallText, weight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: IlmColors.cream,
      fontFamily: bodyFamily,
      textTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: IlmColors.aubergine,
        foregroundColor: IlmColors.white,
        elevation: 0,
        titleTextStyle: heading(20).copyWith(color: IlmColors.white),
      ),
      cardTheme: const CardThemeData(
        color: IlmColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(IlmRadius.md)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: IlmColors.sand, thickness: 1),
      focusColor: IlmColors.peacock.withAlpha(60),
    );
  }
}
