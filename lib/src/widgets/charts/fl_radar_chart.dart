import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'radar_chart.dart' show RadarDataPoint;

/// 使用 fl_chart 的雷達圖組件（支援動畫和互動）
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
  int? _selectedIndex;

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

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return fl_chart.RadarChart(
            fl_chart.RadarChartData(
              radarBackgroundColor: Colors.transparent,
              radarBorderData: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
              radarTouchData: fl_chart.RadarTouchData(
                touchCallback: (fl_chart.FlTouchEvent event, fl_chart.RadarTouchResponse? radarTouchResponse) {
                  if (event is fl_chart.FlTapUpEvent && radarTouchResponse != null) {
                    final touchedSpot = radarTouchResponse.touchedSpot;
                    if (touchedSpot != null) {
                      // 使用 touchedRadarEntryIndex（單數形式）
                      final touchedIndex = touchedSpot.touchedRadarEntryIndex;
                      if (touchedIndex >= 0 && touchedIndex < widget.dataPoints.length) {
                        setState(() {
                          _selectedIndex = touchedIndex;
                        });
                        if (widget.onPointTapped != null) {
                          widget.onPointTapped!(touchedIndex, widget.dataPoints[touchedIndex]);
                        }
                      }
                    }
                  }
                },
              ),
              titleTextStyle: AppTextStyles.captionEmphasis,
              getTitle: (index, angle) {
                return fl_chart.RadarChartTitle(
                  text: widget.dataPoints[index].label,
                  angle: angle,
                  positionPercentageOffset: 1.15,
                );
              },
              titlePositionPercentageOffset: 0.15,
              borderData: fl_chart.FlBorderData(show: false),
              gridBorderData: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
              tickCount: 5,
              ticksTextStyle: const TextStyle(
                color: Colors.transparent,
                fontSize: 0,
              ),
              tickBorderData: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
              radarShape: fl_chart.RadarShape.polygon,
              dataSets: [
                fl_chart.RadarDataSet(
                  fillColor: AppColors.primary.withOpacity(0.2),
                  borderColor: AppColors.primary,
                  borderWidth: 2,
                  entryRadius: 4,
                  dataEntries: widget.dataPoints.map((point) {
                    // point.value 已經是 0-1 之間的值（從 RadarDataPoint）
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
    );
  }
}


