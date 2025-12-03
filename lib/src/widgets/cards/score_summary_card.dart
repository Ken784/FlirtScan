import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class ScoreSummaryCard extends StatelessWidget {
  const ScoreSummaryCard({
    super.key,
    required this.title,
    required this.stateText,
    required this.scoreMajor,
    required this.scoreMinor,
  });

  final String title;
  final String stateText;
  final int scoreMajor; // e.g., 9
  final int scoreMinor; // e.g., 10

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD9E7),
        borderRadius: AppRadii.card,
        boxShadow: AppShadow.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.footnote),
              const SizedBox(height: AppSpacing.s4),
              Text(stateText, style: AppTextStyles.title2),
            ],
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '$scoreMajor', style: TextStyle(fontSize: 80, height: 60 / 80, fontWeight: FontWeight.w600, color: AppColors.primary)),
                TextSpan(text: '/$scoreMinor', style: AppTextStyles.title3.copyWith(color: AppColors.textBlack80)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



