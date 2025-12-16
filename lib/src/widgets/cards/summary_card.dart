import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// 總結卡片（支援列表格式）
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.content,
    this.bulletPoints = const [],
    this.footer,
  });

  final String title;
  final String content;
  final List<String> bulletPoints;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        boxShadow: AppShadow.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.body2Bold),
          const SizedBox(height: AppSpacing.s8),
          if (content.isNotEmpty) ...[
            Text(content, style: AppTextStyles.body3Regular),
            if (bulletPoints.isNotEmpty) const SizedBox(height: AppSpacing.s8),
          ],
          if (bulletPoints.isNotEmpty) ...[
            ...bulletPoints.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                          right: AppSpacing.s8,
                        ),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.textBlack80,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: AppTextStyles.body3Regular,
                        ),
                      ),
                    ],
                  ),
                )),
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.s8),
              Text(footer!, style: AppTextStyles.body3Regular),
            ],
          ] else if (footer != null) ...[
            const SizedBox(height: AppSpacing.s8),
            Text(footer!, style: AppTextStyles.body3Regular),
          ],
        ],
      ),
    );
  }
}

