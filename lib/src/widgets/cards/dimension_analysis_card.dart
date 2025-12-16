import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// 維度分析卡片
class DimensionAnalysisCard extends StatelessWidget {
  const DimensionAnalysisCard({
    super.key,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.description,
  });

  final String title;
  final int score;
  final int maxScore;
  final String description;

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
          Text(
            '$title ($score/$maxScore)：',
            style: AppTextStyles.bodyEmphasis,
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            description,
            style: AppTextStyles.subheadline,
          ),
        ],
      ),
    );
  }
}







