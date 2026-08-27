import 'package:flutter/material.dart';

/// Bubble Chain palette — deep-navy backdrop with 5 vivid bubble
/// colours. Chrome is glassy and low-weight so the bubbles + waves
/// carry every frame.
class GameTheme {
  GameTheme._();

  // Chrome
  static const Color bg = Color(0xFF04061A);
  static const Color bgTop = Color(0xFF0A1030);
  static const Color surface = Color(0xFF10152E);
  static const Color chromeGlass = Color(0x1FFFFFFF);
  static const Color chromeBorder = Color(0x1FFFFFFF);

  static const Color textPrimary = Color(0xFFF3F5FB);
  static const Color textSecondary = Color(0xCCF3F5FB);
  static const Color textMuted = Color(0x80F3F5FB);

  // Bubble hero colours.
  static const Color purple = Color(0xFFB56BFF);
  static const Color pink = Color(0xFFFF6DB2);
  static const Color blue = Color(0xFF4FA9FF);
  static const Color cyan = Color(0xFF4FE1DE);
  static const Color yellow = Color(0xFFFFD34E);

  static const List<Color> heroColors = [purple, pink, blue, cyan, yellow];

  // Semantic
  static const Color success = Color(0xFF4EE0AF);
  static const Color danger = Color(0xFFFF5A6E);
}
