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
    this.reason,
  });

  final QuoteSide side;
  final String quote;
  final String meaning;
  final int rating;
  final int ratingPercent;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = side == QuoteSide.opponent
        ? AppColors.secondaryYellow
        : AppColors.secondaryBlue;
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
          // 有色氣泡框 - 寬度撐滿
          Container(
            width: double.infinity, // 撐滿卡片寬度
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: const BorderRadius.all(AppRadii.r16),
            ),
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Text(
              '"$quote"',
              style:
                  AppTextStyles.body3Semi.copyWith(color: AppColors.textBlack),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text('背後含意', style: AppTextStyles.body3Bold),
          const SizedBox(height: AppSpacing.s4),
          Text(meaning,
              style: AppTextStyles.body3Regular
                  .copyWith(color: AppColors.textBlack80)),
          const SizedBox(height: AppSpacing.s16),
          // 曖昧指數標題
          Text('曖昧指數', style: AppTextStyles.body3Bold),
          const SizedBox(height: AppSpacing.s4),
          // 星星和百分比在下一行
          Row(
            children: [
              _Stars(value: rating),
              const SizedBox(width: AppSpacing.s8),
              Text(
                '($ratingPercent%)',
                style: AppTextStyles.captionRegular.copyWith(
                  fontSize: 13,
                  height: 18 / 13,
                  letterSpacing: -0.08,
                ),
              ),
            ],
          ),
          if (reason != null && reason!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(reason!,
                style: AppTextStyles.body3Regular
                    .copyWith(color: AppColors.textBlack80)),
          ],
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
          color: filled ? AppColors.star : AppColors.star.withOpacity(0.4),
          size: 15,
        );
      }),
    );
  }
}
