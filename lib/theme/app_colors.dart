import 'package:flutter/material.dart';

/// Brand colors lifted from the UPSHIFT / USEYI Monitor app icon:
/// a QR pattern in UPSHIFT blue with orange finder markers on white.
class AppColors {
  AppColors._();

  static const Color upshiftBlue = Color(0xFF1268B3);
  static const Color upshiftBlueDark = Color(0xFF0D4E87);
  static const Color upshiftOrange = Color(0xFFF58220);
  static const Color upshiftOrangeDark = Color(0xFFD86A0E);

  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;

  // Semantic colors kept separate from brand colors on purpose, so
  // attendance status (present/absent) stays readable at a glance.
  static const Color present = Color(0xFF2E9E5B);
  static const Color absent = Color(0xFFE0473F);
}
