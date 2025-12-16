import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class ListEntryCard extends StatelessWidget {
  const ListEntryCard({
    super.key,
    required this.partnerName,
    required this.scoreText,
    required this.summary,
    required this.dateText,
    this.onTap,
  });

  final String partnerName;
  final String scoreText;
  final String summary;
  final String dateText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.card,
          boxShadow: AppShadow.card,
        ),
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 左側：分數（大數字）
            SizedBox(
              width: 70,
              child: Text(
                scoreText,
                style: AppTextStyles.body2Bold.copyWith(
                  fontSize: 52,
                  height: 64 / 52,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            // 右側：名稱、日期、摘要
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 名稱和日期在同一行
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          partnerName,
                          style: AppTextStyles.body3Bold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Text(
                        dateText,
                        style: AppTextStyles.captionRegular.copyWith(
                          color: AppColors.grey40,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    summary,
                    style: AppTextStyles.body3Regular,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}







