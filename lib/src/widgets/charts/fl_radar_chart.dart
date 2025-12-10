import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import '../../core/theme/app_text_styles.dart';
import 'radar_chart.dart' show RadarDataPoint;

/// 使用 fl_chart 的雷達圖組件（支援動畫和互動）
/// 修復版本：
/// 1. 移除所有垂直標籤
/// 2. 網格間隔為5個（0-10分，每個間隔2分）
/// 3. 正確映射0-10分到雷達圖
/// 4. 依照Figma設計調整樣式
class FlRadarChart extends StatefulWidget {
  const FlRadarChart({
    super.key,
    required this.dataPoints,
    this.size = 230,
    this.onPointTapped,
  });

  final List<RadarDataPoint> dataPoints;
  final double size;
  final Function(int index, RadarDataPoint point)? onPointTapped;

  @override
  State<FlRadarChart> createState() => _FlRadarChartState();
}

class _FlRadarChartState extends State<FlRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.dataPoints.length;
    if (count < 3) return const SizedBox.shrink();

    // 計算標籤位置（根據 Figma 設計）
    final chartRadius = widget.size / 2;
    final labelRadius = chartRadius * 1.15; // 標籤在圖表外圍
    final angleStep = (2 * math.pi) / count;
    final startAngle = -math.pi / 2; // 從頂部開始

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 雷達圖
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return fl_chart.RadarChart(
                fl_chart.RadarChartData(
                  radarBackgroundColor: Colors.transparent,
                  radarBorderData: const BorderSide(
                    color: Color(0xFFE8E8E8), // 淡灰色外框
                    width: 1.5,
                  ),
                  radarTouchData: fl_chart.RadarTouchData(
                    touchCallback: (fl_chart.FlTouchEvent event,
                        fl_chart.RadarTouchResponse? radarTouchResponse) {
                      if (event is fl_chart.FlTapUpEvent &&
                          radarTouchResponse != null) {
                        final touchedSpot = radarTouchResponse.touchedSpot;
                        if (touchedSpot != null) {
                          final touchedIndex =
                              touchedSpot.touchedRadarEntryIndex;
                          if (touchedIndex >= 0 &&
                              touchedIndex < widget.dataPoints.length) {
                            if (widget.onPointTapped != null) {
                              widget.onPointTapped!(
                                  touchedIndex, widget.dataPoints[touchedIndex]);
                            }
                          }
                        }
                      }
                    },
                  ),
                  // 不顯示內建的標籤
                  getTitle: (index, angle) {
                    return const fl_chart.RadarChartTitle(
                      text: '',
                    );
                  },
                  titlePositionPercentageOffset: 0.15,
                  borderData: fl_chart.FlBorderData(show: false),
                  gridBorderData: const BorderSide(
                    color: Color(0xFFE8E8E8), // 淡灰色網格線
                    width: 1,
                  ),
                  // 5個網格（代表0, 2, 4, 6, 8, 10分）
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 0,
                  ),
                  tickBorderData: const BorderSide(
                    color: Color(0xFFE8E8E8), // 淡灰色刻度線
                    width: 1,
                  ),
                  radarShape: fl_chart.RadarShape.polygon,
                  dataSets: [
                    fl_chart.RadarDataSet(
                      // 粉紅色半透明填充（根據Figma設計）
                      fillColor: const Color(0xFFFFD9E7).withOpacity(0.4),
                      // 紅色邊框（根據Figma設計）
                      borderColor: const Color(0xFFF02D2D),
                      borderWidth: 2.5,
                      entryRadius: 5,
                      // 節點顏色
                      dataEntries: widget.dataPoints.map((point) {
                        // point.value 是 0-1 之間的值
                        // fl_chart 預設最大值是 1，所以我們直接使用
                        // 應用動畫：從 0 到目標值
                        final animatedValue = point.value * _animation.value;
                        return fl_chart.RadarEntry(value: animatedValue);
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          // 自定義標籤（全部水平顯示，根據 Figma 設計精確定位）
          ...List.generate(count, (index) {
            final angle = startAngle + (index * angleStep);
            final label = widget.dataPoints[index].label;

            // 計算標籤位置（根據 Figma 設計調整偏移）
            final labelX = chartRadius + labelRadius * math.cos(angle);
            final labelY = chartRadius + labelRadius * math.sin(angle);

            // 根據角度決定標籤的對齊和偏移
            double offsetX = 0;
            double offsetY = 0;
            TextAlign textAlign = TextAlign.center;
            double labelWidth = 80;

            // 根據角度決定位置
            if (angle.abs() < 0.1) {
              // 頂部（情緒投入度）
              offsetX = -labelWidth / 2;
              offsetY = -30;
              textAlign = TextAlign.center;
            } else if (angle > 0.9 && angle < 1.7) {
              // 右側（語氣親密度）
              offsetX = 5;
              offsetY = -10;
              textAlign = TextAlign.left;
              labelWidth = 70;
            } else if (angle > 1.7) {
              // 右下（玩笑/調情程度）
              offsetX = -labelWidth / 2;
              offsetY = 5;
              textAlign = TextAlign.center;
              labelWidth = 100;
            } else if (angle < -0.9 && angle > -1.7) {
              // 左側（互動平衡度）
              offsetX = -labelWidth - 5;
              offsetY = -10;
              textAlign = TextAlign.right;
              labelWidth = 70;
            } else {
              // 左下（回覆積極度）
              offsetX = -labelWidth / 2;
              offsetY = 5;
              textAlign = TextAlign.center;
              labelWidth = 70;
            }

            return Positioned(
              left: labelX + offsetX,
              top: labelY + offsetY,
              child: SizedBox(
                width: labelWidth,
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
