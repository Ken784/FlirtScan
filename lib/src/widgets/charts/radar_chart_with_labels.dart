import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'radar_chart.dart';

/// 帶標籤的雷達圖組件
class RadarChartWithLabels extends StatelessWidget {
  const RadarChartWithLabels({
    super.key,
    required this.dataPoints,
    this.size = 230,
  });

  final List<RadarDataPoint> dataPoints;
  final double size;

  @override
  Widget build(BuildContext context) {
    final count = dataPoints.length;
    if (count < 3) return const SizedBox.shrink();

    final angleStep = (2 * math.pi) / count;
    final startAngle = -math.pi / 2; // 從頂部開始
    final chartRadius = size / 2;
    final labelRadius = chartRadius * 0.95; // 標籤位置稍微在圖表邊緣內

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 雷達圖
          Center(
            child: RadarChart(
              dataPoints: dataPoints,
              size: size * 0.75,
            ),
          ),
          // 標籤
          ...List.generate(count, (index) {
            final angle = startAngle + (index * angleStep);
            final label = dataPoints[index].label;
            
            // 計算標籤位置（稍微在圖表外）
            final labelDistance = chartRadius * 1.1;
            final labelX = chartRadius + labelDistance * math.cos(angle);
            final labelY = chartRadius + labelDistance * math.sin(angle);
            
            // 根據位置調整對齊方式
            TextAlign textAlign;
            double leftOffset;
            double topOffset;
            
            if (math.cos(angle).abs() > 0.7) {
              // 左右側
              textAlign = math.cos(angle) > 0 ? TextAlign.left : TextAlign.right;
              leftOffset = math.cos(angle) > 0 ? 0 : -60;
              topOffset = -8;
            } else {
              // 上下側
              textAlign = TextAlign.center;
              leftOffset = -30;
              topOffset = math.sin(angle) > 0 ? 0 : -16;
            }
            
            return Positioned(
              left: labelX + leftOffset,
              top: labelY + topOffset,
              child: SizedBox(
                width: 60,
                child: Text(
                  label,
                  style: AppTextStyles.captionEmphasis,
                  textAlign: textAlign,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

