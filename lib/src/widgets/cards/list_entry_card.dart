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
    this.onTap,
  });

  final String partnerName;
  final String scoreText;
  final String summary;
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
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder
            ClipRRect(
              borderRadius: BorderRadius.all(AppRadii.r4),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Icon(Icons.image, color: Colors.white70),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(partnerName, style: AppTextStyles.bodyEmphasis)),
                      Text(scoreText, style: AppTextStyles.bodyEmphasis.copyWith(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(summary, style: AppTextStyles.subheadline),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}






