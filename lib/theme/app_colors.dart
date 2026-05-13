import 'package:flutter/material.dart';

class AppColors {
  static const Color accent = Color(0xFFFFB300);
  static const Color accentLight = Color(0xFFFFCB4D);
  static const Color surfaceTop = Color(0xFF0E1620);
  static const Color surfaceBottom = Color(0xFF050608);
  static const Color cardBg = Color(0xFF141B26);
  static const Color textPrimary = Color(0xFFE8EAED);
  static const Color textSecondary = Color(0xFF9AA0A6);
  static const Color textMuted = Color(0xFF5F6368);
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color danger = Color(0xFFEA4335);

  static const Gradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [surfaceTop, surfaceBottom],
  );
  static const Gradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft, end: Alignment.centerRight,
    colors: [accent, accentLight],
  );
}
