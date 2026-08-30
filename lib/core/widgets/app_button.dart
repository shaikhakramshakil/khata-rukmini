import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final Widget? customIcon;
  final bool isLoading;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.customIcon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.ink;
        fg = AppColors.elevated;
        border = BorderSide.none;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.elevated;
        fg = AppColors.ink;
        border = const BorderSide(color: AppColors.hairline, width: 1);
        break;
      case AppButtonVariant.danger:
        bg = AppColors.error;
        fg = AppColors.elevated;
        border = BorderSide.none;
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.ink;
        border = BorderSide.none;
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (customIcon != null) ...[
          customIcon!,
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
        ],
        Text(label, style: AppTypography.button.copyWith(color: fg)),
      ],
    );

    return SizedBox(
      width: width,
      height: 38,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: border,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        child: content,
      ),
    );
  }
}
