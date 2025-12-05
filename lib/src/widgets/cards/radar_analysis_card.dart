import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../charts/radar_chart.dart';
import '../charts/radar_chart_with_labels.dart';

/// 雷達圖分析卡片（包含雷達圖和詳細分析）
class RadarAnalysisCard extends StatelessWidget {
  const RadarAnalysisCard({
    super.key,
    required this.dataPoints,
    required this.dimensionAnalyses,
  });

  final List<RadarDataPoint> dataPoints;
  final List<DimensionAnalysis> dimensionAnalyses;

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
        children: [
          // 雷達圖
          Center(
            child: RadarChartWithLabels(
              dataPoints: dataPoints,
              size: 230,
            ),
          ),
          const SizedBox(height: AppSpacing.s32),
          // 詳細分析
          ...dimensionAnalyses.map((analysis) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${analysis.title} (${analysis.score}/${analysis.maxScore})：',
                      style: AppTextStyles.bodyEmphasis,
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      analysis.description,
                      style: AppTextStyles.subheadline,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// 維度分析數據
class DimensionAnalysis {
  final String title;
  final int score;
  final int maxScore;
  final String description;

  const DimensionAnalysis({
    required this.title,
    required this.score,
    required this.maxScore,
    required this.description,
  });
}

