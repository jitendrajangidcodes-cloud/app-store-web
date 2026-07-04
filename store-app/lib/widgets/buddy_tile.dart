import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// The brand "buddy": a rounded tile with two eyes and a letter, matching the
// web buddyTileHTML. Sizing scales off `size` exactly like the CSS version.
class BuddyTile extends StatelessWidget {
  final String ch;
  final Color bg;
  final Color fg;
  final double size;
  const BuddyTile({
    super.key,
    required this.ch,
    required this.bg,
    required this.fg,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.28;
    final eye = (size * 0.13).clamp(3.0, size);
    final gap = size * 0.19;
    final top = size * 0.19;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: top,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(eye, fg),
                SizedBox(width: gap),
                _dot(eye, fg),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: size * 0.1),
            child: Text(
              ch,
              style: GoogleFonts.baloo2(
                fontSize: size * 0.55,
                fontWeight: FontWeight.w800,
                color: fg,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double d, Color c) => Container(
        width: d,
        height: d,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

// The five-letter PNSJY row used as the wordmark/logo.
class BuddyRow extends StatelessWidget {
  final double size;
  const BuddyRow({super.key, required this.size});

  static const _letters = [
    ("P", Color(0xFFE8632C), Color(0xFFFFFFFF)),
    ("N", Color(0xFFF0A92C), Color(0xFF6B4400)),
    ("S", Color(0xFF3FAE6A), Color(0xFFFFFFFF)),
    ("J", Color(0xFF2F7EE3), Color(0xFFFFFFFF)),
    ("Y", Color(0xFF8A56D6), Color(0xFFFFFFFF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final l in _letters)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: BuddyTile(ch: l.$1, bg: l.$2, fg: l.$3, size: size),
          ),
      ],
    );
  }
}

Color hexColor(String hex) {
  final h = hex.replaceFirst("#", "");
  return Color(int.parse("FF$h", radix: 16));
}
