import 'package:flutter/material.dart';

// Mirrors the :root design tokens in the website's style.css. Keep the two in
// sync -- these are the same hex values the web UI uses for each theme.
class Tokens {
  final Color bg;
  final Color text;
  final Color muted;
  final Color glass;
  final Color glass2;
  final Color border;
  final Color border2;
  final Color accent;
  final Color accent2;
  final Color mint;
  final Color chip;
  final Color chipText;
  final Color glow1;
  final Color glow2;
  final Color glow3;
  final Color panelSolid;

  const Tokens({
    required this.bg,
    required this.text,
    required this.muted,
    required this.glass,
    required this.glass2,
    required this.border,
    required this.border2,
    required this.accent,
    required this.accent2,
    required this.mint,
    required this.chip,
    required this.chipText,
    required this.glow1,
    required this.glow2,
    required this.glow3,
    required this.panelSolid,
  });

  LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, accent2],
      );

  static const dark = Tokens(
    bg: Color(0xFF0C0E15),
    text: Color(0xFFF2F3F8),
    muted: Color(0xFF9BA0B5),
    glass: Color(0x0DFFFFFF),
    glass2: Color(0x14FFFFFF),
    border: Color(0x1AFFFFFF),
    border2: Color(0x2EFFFFFF),
    accent: Color(0xFF2F7EE3),
    accent2: Color(0xFF8A56D6),
    mint: Color(0xFF3FAE6A),
    chip: Color(0x292F7EE3),
    chipText: Color(0xFF8FBCF5),
    glow1: Color(0x332F7EE3),
    glow2: Color(0x298A56D6),
    glow3: Color(0x1AE8632C),
    panelSolid: Color(0xFF0E1118),
  );

  static const light = Tokens(
    bg: Color(0xFFF5F4F0),
    text: Color(0xFF1C1A17),
    muted: Color(0xFF5F6270),
    glass: Color(0xA6FFFFFF),
    glass2: Color(0xE6FFFFFF),
    border: Color(0x141C1A17),
    border2: Color(0x291C1A17),
    accent: Color(0xFF2F7EE3),
    accent2: Color(0xFF8A56D6),
    mint: Color(0xFF2A8863),
    chip: Color(0x1F2F7EE3),
    chipText: Color(0xFF1F5EB3),
    glow1: Color(0x402F7EE3),
    glow2: Color(0x338A56D6),
    glow3: Color(0x2EF0A92C),
    panelSolid: Color(0xFFFFFFFF),
  );
}
