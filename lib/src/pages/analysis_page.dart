import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});
  static const String route = '/analysis';

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  Timer? _adCountdownTimer;
  int _adCountdown = 20; // 廣告倒數計時（秒）
  final ValueNotifier<bool> _isMovingRightNotifier = ValueNotifier<bool>(true);
  double _previousAnimationValue = 0.0; // 追蹤前一個動畫值

  @override
  void initState() {
    super.initState();
    
    // 初始化掃描動畫（來回掃描）
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // 使用 reverse: true 實現來回掃描
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 監聽動畫值變化來判斷方向（使用 ValueNotifier 避免 setState）
    _scanAnimation.addListener(() {
      final currentValue = _scanAnimation.value;
      final bool isMovingRight = currentValue >= _previousAnimationValue;
      
      // 只在方向改變時更新 ValueNotifier
      if (_isMovingRightNotifier.value != isMovingRight) {
        _isMovingRightNotifier.value = isMovingRight;
      }
      
      _previousAnimationValue = currentValue;
    });

    // 初始化廣告倒數計時
    _startAdCountdown();
  }

  void _startAdCountdown() {
    _adCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_adCountdown > 0) {
            _adCountdown--;
          } else {
            _adCountdown = 20; // 重置倒數計時
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _adCountdownTimer?.cancel();
    _isMovingRightNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060000), // 全黑背景
      body: SafeArea(
        child: Column(
          children: [
            // 上方處理條
            _buildProcessingBar(),
            // 下方廣告區
            Expanded(
              child: _buildAdArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingBar() {
    return Container(
      height: 44,
      color: Colors.black,
      child: Stack(
        children: [
          // 左右掃描的漸層動畫
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return ValueListenableBuilder<bool>(
                valueListenable: _isMovingRightNotifier,
                builder: (context, isMovingRight, child) {
                  return Positioned.fill(
                    child: CustomPaint(
                      painter: _ScanGradientPainter(
                        animationValue: _scanAnimation.value,
                        isMovingRight: isMovingRight,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // 文字內容
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '正在揣摩他/她的心思',
                    style: AppTextStyles.bodyEmphasis.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                    ),
                  ),
                  _AnimatedDots(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdArea() {
    return Stack(
      children: [
        // 廣告內容區域（目前為佔位符）
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[900],
          child: Center(
            child: Text(
              '廣告內容',
              style: AppTextStyles.body.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
        // 右上角廣告倒數計時器
        Positioned(
          top: 21,
          right: 20,
          child: _buildAdCountdown(),
        ),
      ],
    );
  }

  Widget _buildAdCountdown() {
    return Container(
      width: 29,
      height: 29,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.5),
      ),
      child: Center(
        child: Text(
          '$_adCountdown',
          style: AppTextStyles.subheadline.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.8),
            letterSpacing: -0.23,
          ),
        ),
      ),
    );
  }
}

// 自定義繪製器：實現左右掃描的漸層動畫
class _ScanGradientPainter extends CustomPainter {
  final double animationValue;
  final bool isMovingRight;

  _ScanGradientPainter({
    required this.animationValue,
    required this.isMovingRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 計算掃描條的位置（從螢幕外左側到螢幕外右側）
    // animationValue 現在是 0.0 到 1.0（來回掃描）
    final double scanWidth = 96; // 掃描條的寬度
    // 動畫範圍：從 -96px（螢幕左側外）到 size.width + 96px（螢幕右側外）
    // 總距離 = size.width + 192px
    final double scanLeft = -scanWidth + animationValue * (size.width + scanWidth * 2);

    // 根據移動方向創建不同的漸層
    // 根據 Figma 設計，漸層顏色是從透明到深灰色 #333333
    final LinearGradient gradient;
    if (isMovingRight) {
      // 往右移動：從透明到深灰色
      gradient = LinearGradient(
        colors: [
          const Color(0xFF333333).withOpacity(0.0), // 透明（左側）
          const Color(0xFF333333), // 深灰色（右側）
        ],
      );
    } else {
      // 往左移動：從深灰色到透明
      gradient = LinearGradient(
        colors: [
          const Color(0xFF333333), // 深灰色（左側）
          const Color(0xFF333333).withOpacity(0.0), // 透明（右側）
        ],
      );
    }

    // 繪製掃描條
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(scanLeft, 0, scanWidth, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(scanLeft, 0, scanWidth, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ScanGradientPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// 動畫點點 Widget：顯示「...」的動畫效果
class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // 將整個動畫週期分成 3 段，每個點點佔用一段
            // 第一個點點（index=0）在 0-0.33 出現和消失
            // 第二個點點（index=1）在 0.33-0.66 出現和消失
            // 第三個點點（index=2）在 0.66-1.0 出現和消失
            final double segmentStart = index / 3.0;
            final double segmentEnd = (index + 1) / 3.0;
            final double segmentDuration = segmentEnd - segmentStart;
            
            // 計算當前點點在其段內的動畫進度（0.0 到 1.0）
            double localProgress = 0.0;
            if (_controller.value >= segmentStart && _controller.value <= segmentEnd) {
              localProgress = (_controller.value - segmentStart) / segmentDuration;
            } else if (_controller.value > segmentEnd) {
              localProgress = 1.0; // 已經過了這個點點的時段
            }
            
            // 計算透明度：前 70% 時間出現，後 30% 時間消失
            double opacity;
            if (localProgress < 0.7) {
              // 出現階段：從 0 到 1（localProgress 從 0 到 0.7）
              opacity = (localProgress / 0.7).clamp(0.0, 1.0);
            } else {
              // 消失階段：從 1 到 0（localProgress 從 0.7 到 1.0）
              opacity = ((1.0 - localProgress) / 0.3).clamp(0.0, 1.0);
            }
            
            return Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Opacity(
                opacity: opacity,
                child: Text(
                  '·',
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

