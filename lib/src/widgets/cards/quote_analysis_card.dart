import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shadows.dart';

enum QuoteSide { opponent, me }

class QuoteAnalysisCard extends StatelessWidget {
  const QuoteAnalysisCard({
    super.key,
    required this.side,
    required this.quote,
    required this.meaning,
    required this.rating, // 0..10
    required this.ratingPercent, // e.g., 70
  });

  final QuoteSide side;
  final String quote;
  final String meaning;
  final int rating;
  final int ratingPercent;

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = side == QuoteSide.opponent ? AppColors.secondaryYellow : AppColors.secondaryBlue;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        boxShadow: AppShadow.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(color: bubbleColor, borderRadius: const BorderRadius.all(AppRadii.r16)),
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Text('“$quote”', style: AppTextStyles.callout.copyWith(color: AppColors.textBlack)),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text('背後含意', style: AppTextStyles.bodyEmphasis),
          const SizedBox(height: AppSpacing.s4),
          Text(meaning, style: AppTextStyles.subheadline),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Text('曖昧指數', style: AppTextStyles.bodyEmphasis),
              const SizedBox(width: AppSpacing.s8),
              _Stars(value: rating),
              const SizedBox(width: AppSpacing.s8),
              Text('($ratingPercent%)', style: AppTextStyles.footnote),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.value});
  final int value; // 0..10

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(10, (i) {
        final filled = i < value;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          color: filled ? AppColors.primary : AppColors.primary.withOpacity(0.4),
          size: 18,
        );
      }),
    );
  }
}



