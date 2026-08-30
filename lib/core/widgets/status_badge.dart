import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

class BalanceBadge extends StatelessWidget {
  final double balance;
  final bool forceDecimals;

  const BalanceBadge({
    super.key,
    required this.balance,
    this.forceDecimals = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text = AppFormatters.formatBalance(
      balance,
      forceDecimals: forceDecimals,
    );

    if (balance > 0.0001) {
      bg = AppColors.badgeDrBg;
      fg = AppColors.badgeDrText;
    } else if (balance < -0.0001) {
      bg = AppColors.badgeCrBg;
      fg = AppColors.badgeCrText;
    } else {
      bg = AppColors.badgeNeutralBg;
      fg = AppColors.badgeNeutralText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.codeMono.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class TypeBadge extends StatelessWidget {
  final String label;

  const TypeBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.hairlineSoft,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.monoEyebrow.copyWith(
          fontSize: 10,
          color: AppColors.ink,
        ),
      ),
    );
  }
}
