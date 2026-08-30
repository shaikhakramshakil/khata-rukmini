import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography tokens adhering to Geist design philosophy.
class AppTypography {
  static const String sansFontFamily = 'Inter';
  static const String monoFontFamily = 'JetBrains Mono';

  static const TextStyle display = TextStyle(
    fontFamily: sansFontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w600,
    height: 48 / 48,
    letterSpacing: -1.4,
    color: AppColors.ink,
  );

  static const TextStyle headingLarge = TextStyle(
    fontFamily: sansFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 40 / 32,
    letterSpacing: -0.8,
    color: AppColors.ink,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: sansFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );

  static const TextStyle label = TextStyle(
    fontFamily: sansFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.ink,
  );

  static const TextStyle monoEyebrow = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.5,
    color: AppColors.mute,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: sansFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.body,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sansFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.body,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sansFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.mute,
  );

  static const TextStyle button = TextStyle(
    fontFamily: sansFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.elevated,
  );

  static const TextStyle codeMono = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.ink,
  );
}
