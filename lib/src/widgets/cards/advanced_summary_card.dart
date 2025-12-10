import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// 進階分析總結卡片
class AdvancedSummaryCard extends StatelessWidget {
  const AdvancedSummaryCard({
    super.key,
    required this.summary,
  });

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 根據 Figma 設計，使用漸層背景
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B4FE0), // 紫色
            Color(0xFF4F8FE0), // 藍色
          ],
        ),
        borderRadius: AppRadii.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✨ 總結',
            style: AppTextStyles.bodyEmphasis.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            summary,
            style: AppTextStyles.subheadline.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

