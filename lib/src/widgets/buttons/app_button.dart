import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, tertiary }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;
    final Color fg;
    final Color bg;
    final BorderSide? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = disabled ? AppColors.primary.withOpacity(0.5) : AppColors.primary;
        fg = Colors.white;
        border = null;
        break;
      case AppButtonVariant.secondary:
        bg = Colors.white;
        fg = disabled ? AppColors.primary.withOpacity(0.5) : AppColors.primary;
        border = BorderSide(color: AppColors.primary, width: 1);
        break;
      case AppButtonVariant.tertiary:
        bg = Colors.transparent;
        fg = disabled ? Colors.black38 : AppColors.textBlack;
        border = BorderSide(color: Colors.black12, width: 1);
        break;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.s52),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: bg,
            foregroundColor: fg,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.pill, side: border ?? BorderSide.none),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.s12),
              ],
              Text(label, style: AppTextStyles.bodyEmphasis.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}










