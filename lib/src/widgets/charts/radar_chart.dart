import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 雷達圖數據點
class RadarDataPoint {
  final String label;
  final double value; // 0.0 到 1.0 之間的值

  const RadarDataPoint({
    required this.label,
    required this.value,
  });
}

/// 雷達圖組件
class RadarChart extends StatelessWidget {
  const RadarChart({
    super.key,
    required this.dataPoints,
    this.size = 200,
  });

  final List<RadarDataPoint> dataPoints;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarChartPainter(dataPoints: dataPoints),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<RadarDataPoint> dataPoints;

  _RadarChartPainter({required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.85; // 留一些邊距給標籤

    final count = dataPoints.length;
    if (count < 3) return;

    // 計算每個軸的角度（從頂部開始，順時針）
    final angleStep = (2 * math.pi) / count;
    final startAngle = -math.pi / 2; // 從頂部開始

    // 繪製網格線（同心圓）
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 5; i++) {
      final gridRadius = radius * (i / 5);
      canvas.drawCircle(center, gridRadius, gridPaint);
    }

    // 繪製軸線
    final axisPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < count; i++) {
      final angle = startAngle + (i * angleStep);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(endX, endY), axisPaint);
    }

    // 繪製數據多邊形
    final dataPath = Path();
    final dataPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < count; i++) {
      final angle = startAngle + (i * angleStep);
      final value = dataPoints[i].value.clamp(0.0, 1.0);
      final pointRadius = radius * value;
      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);

      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    canvas.drawPath(dataPath, dataPaint);
    canvas.drawPath(dataPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

