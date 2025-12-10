import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/icons/app_icon_widgets.dart';
import '../core/providers/analysis_provider.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/cards/score_summary_card.dart';
import '../widgets/cards/insight_card.dart';
import '../widgets/cards/summary_card.dart';
import '../widgets/charts/fl_radar_chart.dart';
import '../widgets/charts/radar_chart.dart';
import '../widgets/buttons/app_button.dart';
import '../core/models/analysis_result.dart';
import 'result_sentence_page.dart';

class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({
    super.key,
    this.imageBase64,
  });

  static const String route = '/result';
  final String? imageBase64;

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  final ValueNotifier<bool> _isMovingRightNotifier = ValueNotifier<bool>(true);
  double _previousAnimationValue = 0.0;

  @override
  void initState() {
    super.initState();
    
    // 初始化掃描動畫（用於「正在解讀...」）
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scanAnimation.addListener(() {
      final currentValue = _scanAnimation.value;
      final bool isMovingRight = currentValue >= _previousAnimationValue;
      
      if (_isMovingRightNotifier.value != isMovingRight) {
        _isMovingRightNotifier.value = isMovingRight;
      }
      
      _previousAnimationValue = currentValue;
    });

    // 不需要在這裡開始分析，因為 AnalysisPage 已經開始了
    // ResultPage 只需要監聽 analysisProvider 的狀態
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _isMovingRightNotifier.dispose();
    super.dispose();
  }


  void _onRadarPointTapped(int index, RadarDataPoint point, AnalysisResult result) {
    // 根據索引獲取對應的維度描述
    String description = '';
    switch (index) {
      case 0:
        description = result.emotional.description;
        break;
      case 1:
        description = result.intimacy.description;
        break;
      case 2:
        description = result.playfulness.description;
        break;
      case 3:
        description = result.responsive.description;
        break;
      case 4:
        description = result.balance.description;
        break;
    }

    // 顯示對話框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(point.label),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 監聽分析狀態
    final analysisState = ref.watch(analysisProvider);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgGradientTop, AppColors.bgGradientBottom],
          ),
        ),
        child: SafeArea(
          child: analysisState.isAnalyzing
              ? _buildAnalyzingView()
              : analysisState.hasError
                  ? _buildErrorView(analysisState.errorMessage)
                  : analysisState.result != null
                      ? _buildResultView(analysisState.result!)
                      : _buildEmptyView(),
        ),
      ),
    );
  }

  Widget _buildAnalyzingView() {
    return Column(
      children: [
        // 上方處理條（類似 AnalysisPage）
        Container(
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
                        '正在解讀...',
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
        ),
        // 下方空白區域（可以顯示廣告或其他內容）
        Expanded(
          child: Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(String? errorMessage) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s24),
      children: [
        PageHeader(
          title: '分析結果',
          leading: AppIconWidgets.arrowBack(),
          trailing: AppIconWidgets.delete(),
        ),
        const SizedBox(height: AppSpacing.s24),
        Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: AppSpacing.s16),
              Text(
                '分析失敗',
                style: AppTextStyles.title2,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                errorMessage ?? '未知錯誤',
                style: AppTextStyles.subheadline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s24),
              AppButton(
                label: '返回',
                variant: AppButtonVariant.primary,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s24),
      children: [
        PageHeader(
          title: '分析結果',
          leading: AppIconWidgets.arrowBack(),
          trailing: AppIconWidgets.delete(),
        ),
        const SizedBox(height: AppSpacing.s24),
        Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Text('沒有分析數據'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(AnalysisResult result) {
    
    // 準備雷達圖數據（保持 0-1 的值，讓 fl_chart 內部轉換為 0-10）
    // fl_chart 會將 value * 10 來顯示在圖表上
    final radarDataPoints = [
      RadarDataPoint(
        label: '情緒投入度',
        value: (result.emotional.score / 10.0).clamp(0.0, 1.0),
      ),
      RadarDataPoint(
        label: '語氣親密度',
        value: (result.intimacy.score / 10.0).clamp(0.0, 1.0),
      ),
      RadarDataPoint(
        label: '玩笑 / 調情程度',
        value: (result.playfulness.score / 10.0).clamp(0.0, 1.0),
      ),
      RadarDataPoint(
        label: '回覆積極度',
        value: (result.responsive.score / 10.0).clamp(0.0, 1.0),
      ),
      RadarDataPoint(
        label: '互動平衡度',
        value: (result.balance.score / 10.0).clamp(0.0, 1.0),
      ),
    ];

    // 準備維度分析列表
    final dimensionAnalyses = [
      DimensionAnalysis(
        title: '情緒投入度',
        score: result.emotional.score.round(),
        maxScore: 10,
        description: result.emotional.description,
      ),
      DimensionAnalysis(
        title: '語氣親密度',
        score: result.intimacy.score.round(),
        maxScore: 10,
        description: result.intimacy.description,
      ),
      DimensionAnalysis(
        title: '玩笑 / 調情程度',
        score: result.playfulness.score.round(),
        maxScore: 10,
        description: result.playfulness.description,
      ),
      DimensionAnalysis(
        title: '回覆積極度',
        score: result.responsive.score.round(),
        maxScore: 10,
        description: result.responsive.description,
      ),
      DimensionAnalysis(
        title: '互動平衡度',
        score: result.balance.score.round(),
        maxScore: 10,
        description: result.balance.description,
      ),
    ];

    // 解析總結（可能包含 bullet points）
    final summaryLines = result.summary.split('\n');
    String summaryContent = '';
    List<String> bulletPoints = [];
    
    for (final line in summaryLines) {
      if (line.trim().isEmpty) continue;
      if (line.trim().startsWith('-') || line.trim().startsWith('•')) {
        bulletPoints.add(line.trim().substring(1).trim());
      } else {
        if (summaryContent.isEmpty) {
          summaryContent = line.trim();
        } else {
          summaryContent += '\n${line.trim()}';
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s24),
      children: [
        PageHeader(
          title: '分析結果',
          leading: AppIconWidgets.arrowBack(),
          trailing: AppIconWidgets.delete(),
        ),
        const SizedBox(height: AppSpacing.s16),
        ScoreSummaryCard(
          title: '曖昧指數',
          stateText: result.relationshipStatus,
          scoreMajor: result.totalScore.round(),
          scoreMinor: 10,
        ),
        const SizedBox(height: AppSpacing.s24),
        // 雷達圖分析卡片
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            children: [
              // 雷達圖
              Center(
                child: FlRadarChart(
                  dataPoints: radarDataPoints,
                  size: 230,
                  onPointTapped: (index, point) => _onRadarPointTapped(index, point, result),
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
        ),
        const SizedBox(height: AppSpacing.s16),
        InsightCard(
          title: '🔍 語氣洞察',
          body: result.toneInsight,
        ),
        const SizedBox(height: AppSpacing.s16),
        SummaryCard(
          title: '✨ 總結',
          content: summaryContent,
          bulletPoints: bulletPoints,
        ),
        const SizedBox(height: AppSpacing.s24),
        AppButton(
          label: '進階逐句分析',
          variant: AppButtonVariant.primary,
          leading: AppIconWidgets.list(size: 24, color: Colors.white),
          onPressed: () {
            // TODO: 傳遞分析結果到逐句分析頁面
            context.push(ResultSentencePage.route);
          },
        ),
        const SizedBox(height: AppSpacing.s16),
        AppButton(
          label: '截圖',
          variant: AppButtonVariant.primary,
          leading: AppIconWidgets.camera(size: 24, color: Colors.white),
          onPressed: () {
            // TODO: 實作截圖功能
          },
        ),
      ],
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

// 掃描漸層繪製器（從 AnalysisPage 複製）
class _ScanGradientPainter extends CustomPainter {
  final double animationValue;
  final bool isMovingRight;

  _ScanGradientPainter({
    required this.animationValue,
    required this.isMovingRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scanWidth = 96;
    final double scanLeft = -scanWidth + animationValue * (size.width + scanWidth * 2);

    final LinearGradient gradient;
    if (isMovingRight) {
      gradient = LinearGradient(
        colors: [
          const Color(0xFF333333).withOpacity(0.0),
          const Color(0xFF333333),
        ],
      );
    } else {
      gradient = LinearGradient(
        colors: [
          const Color(0xFF333333),
          const Color(0xFF333333).withOpacity(0.0),
        ],
      );
    }

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

// 動畫點點 Widget（從 AnalysisPage 複製）
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
            final double segmentStart = index / 3.0;
            final double segmentEnd = (index + 1) / 3.0;
            final double segmentDuration = segmentEnd - segmentStart;
            
            double localProgress = 0.0;
            if (_controller.value >= segmentStart && _controller.value <= segmentEnd) {
              localProgress = (_controller.value - segmentStart) / segmentDuration;
            } else if (_controller.value > segmentEnd) {
              localProgress = 1.0;
            }
            
            double opacity;
            if (localProgress < 0.7) {
              opacity = (localProgress / 0.7).clamp(0.0, 1.0);
            } else {
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
