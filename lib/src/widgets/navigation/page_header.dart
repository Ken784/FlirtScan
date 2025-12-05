import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
      child: Row(
        children: [
          if (leading != null) ...[
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: leading!,
            ),
            const SizedBox(width: AppSpacing.s16),
          ],
          Expanded(child: Text(title, style: AppTextStyles.title1)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}






