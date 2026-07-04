import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

// Carries the web design tokens through the widget tree so any widget can read
// context.tokens, the same way CSS reads var(--accent).
class AppTokens extends ThemeExtension<AppTokens> {
  final Tokens tokens;
  const AppTokens(this.tokens);

  @override
  AppTokens copyWith({Tokens? tokens}) => AppTokens(tokens ?? this.tokens);

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) => this;
}

extension TokensContext on BuildContext {
  Tokens get tokens => Theme.of(this).extension<AppTokens>()!.tokens;
}

// Fonts mirror the site: Sora (headings), DM Sans (body), JetBrains Mono
// (chips/meta), Baloo 2 (buddy letters, used directly in the tile widget).
TextStyle sora(double size, {FontWeight weight = FontWeight.w700, Color? color}) =>
    GoogleFonts.sora(fontSize: size, fontWeight: weight, color: color, height: 1.1);

TextStyle dmSans(double size, {FontWeight weight = FontWeight.w400, Color? color}) =>
    GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color, height: 1.5);

TextStyle mono(double size, {Color? color}) =>
    GoogleFonts.jetBrainsMono(fontSize: size, color: color, height: 1.3);

ThemeData buildTheme(Tokens t, Brightness brightness) {
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: t.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: t.accent,
      secondary: t.accent2,
      surface: t.panelSolid,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
      bodyColor: t.text,
      displayColor: t.text,
    ),
    extensions: [AppTokens(t)],
  );
}
