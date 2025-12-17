import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.onTrailingTap,
    this.centerTitle = false,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    // #region agent log
    final mediaQuery = MediaQuery.of(context);
    final hasLeading = leading != null;
    final hasTrailing = trailing != null;
    // ignore: avoid_print
    debugPrint(
        'DEBUG_PAGEHEADER: title="$title", hasLeading=$hasLeading, hasTrailing=$hasTrailing, centerTitle=$centerTitle, screenWidth=${mediaQuery.size.width}');
    // #endregion
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
      child: centerTitle
          ? Stack(
              alignment: Alignment.center,
              children: [
                // Leading icon on the left
                if (leading != null)
                  Positioned(
                    left: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: leading!,
                    ),
                  ),
                // Centered title
                Text(title, style: AppTextStyles.header1Bold),
                // Trailing icon on the right
                if (trailing != null)
                  Positioned(
                    right: 0,
                    child: onTrailingTap != null
                        ? GestureDetector(
                            onTap: onTrailingTap,
                            child: trailing!,
                          )
                        : trailing!,
                  ),
              ],
            )
          : Row(
              children: [
                if (leading != null) ...[
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: leading!,
                  ),
                  const SizedBox(width: AppSpacing.s16),
                ],
                Expanded(child: Text(title, style: AppTextStyles.header1Bold)),
                if (trailing != null)
                  onTrailingTap != null
                      ? GestureDetector(
                          onTap: onTrailingTap,
                          child: trailing!,
                        )
                      : trailing!,
              ],
            ),
    );
  }
}
