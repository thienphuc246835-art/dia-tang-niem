import 'package:flutter/material.dart';

/// Design tokens from CLAUDE.md section 4.
class Palette {
  const Palette({
    required this.background,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.border,
  });

  final Color background;
  final Color surface;
  final Color text;
  final Color textMuted;
  final Color accent; // vàng đồng
  final Color accentSoft; // xanh rêu / lá sen
  final Color border;

  static const light = Palette(
    background: Color(0xFFF7F3EA),
    surface: Color(0xFFFBF8F1),
    text: Color(0xFF2B2620),
    textMuted: Color(0xFF7A7266),
    accent: Color(0xFFB08D3E),
    accentSoft: Color(0xFF6B7F5E),
    border: Color(0xFFE3DCCB),
  );

  static const dark = Palette(
    background: Color(0xFF16130F),
    surface: Color(0xFF1E1A15),
    text: Color(0xFFE9E2D0),
    textMuted: Color(0xFF9A917F),
    accent: Color(0xFFC9A75A),
    accentSoft: Color(0xFF7E9470),
    border: Color(0xFF2A251E),
  );

  /// Reader-only "giấy ngả" mode.
  static const sepia = Palette(
    background: Color(0xFFF1E7D0),
    surface: Color(0xFFF5ECD8),
    text: Color(0xFF3B2F22),
    textMuted: Color(0xFF7D6B55),
    accent: Color(0xFFA07F35),
    accentSoft: Color(0xFF6B7F5E),
    border: Color(0xFFE0D2B4),
  );
}

abstract final class Fonts {
  static const serif = 'NotoSerif';
}

abstract final class Space {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 16.0;
  static const l = 24.0;
  static const xl = 40.0;
}

/// Slow, calm transitions (CLAUDE.md: fade chậm, không trượt mạnh).
abstract final class Motion {
  static const slow = Duration(milliseconds: 600);
  static const medium = Duration(milliseconds: 300);
}
