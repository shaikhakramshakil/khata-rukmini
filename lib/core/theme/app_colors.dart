import 'package:flutter/material.dart';

/// Geist / Vercel design system color tokens as specified in the PRD.
class AppColors {
  // Monochromatic core
  static const Color ink = Color(0xFF171717);
  static const Color body = Color(0xFF4D4D4D);
  static const Color mute = Color(0xFF8F8F8F);
  static const Color faint = Color(0xFFA1A1A1);

  // Surfaces
  static const Color canvas = Color(0xFFFAFAFA);
  static const Color elevated = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFEBEBEB);
  static const Color hairlineSoft = Color(0xFFF2F2F2);

  // Semantic
  static const Color link = Color(0xFF0070F3);
  static const Color error = Color(0xFFEE0000);
  static const Color warning = Color(0xFFF5A623);
  static const Color success = Color(
    0xFF0070F3,
  ); // Blue is used for positive focus per design system

  // Subtle badge backgrounds
  static const Color badgeDrBg = Color(0xFFFDF2F2);
  static const Color badgeDrText = Color(0xFF991B1B);
  static const Color badgeCrBg = Color(0xFFF0FDF4);
  static const Color badgeCrText = Color(0xFF166534);
  static const Color badgeNeutralBg = Color(0xFFF4F4F5);
  static const Color badgeNeutralText = Color(0xFF52525B);
}
