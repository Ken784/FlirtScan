import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/icons/app_icon_widgets.dart';
import '../core/models/analysis_result.dart';
import '../core/providers/analysis_provider.dart';
import '../core/providers/history_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../services/ad_service.dart';
import '../services/screenshot_service.dart';
import '../widgets/buttons/app_button.dart';
import '../widgets/cards/insight_card.dart';
import '../widgets/cards/score_summary_card.dart';
import '../widgets/cards/summary_card.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/confirm_delete_dialog.dart';
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
  final AdService _adService = AdService();
  final ScreenshotService _screenshotService = ScreenshotService();
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isLoadingAd = false;

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

  /// 處理進階分析按鈕點擊
  Future<void> _handleAdvancedAnalysis(AnalysisResult result) async {
    // 檢查是否已解鎖
    if (result.isAdvancedUnlocked) {
      // 已解鎖，直接跳轉
      _navigateToAdvancedAnalysis();
      return;
    }

    // 未解鎖，需要播放廣告
    setState(() {
      _isLoadingAd = true;
    });

    // 檢查廣告是否已載入（使用進階分析廣告）
    if (!_adService.isAdLoaded(AdType.advancedAnalysis)) {
      // 顯示載入提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('廣告載入中，請稍候...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 等待廣告載入（進階分析廣告）
      await _adService.loadRewardedAd(AdType.advancedAnalysis);

      // 再次檢查廣告是否載入成功
      if (!_adService.isAdLoaded(AdType.advancedAnalysis)) {
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('廣告載入失敗，請稍後再試'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }

    // 播放廣告（進階分析廣告）
    await _adService.showRewardedAd(
      adType: AdType.advancedAnalysis,
      onUserEarnedReward: () {
        // 用戶看完廣告，解鎖進階分析
        debugPrint('ResultPage: 用戶看完廣告，解鎖進階分析');
        ref.read(analysisProvider.notifier).unlockAdvancedAnalysis();

        // 跳轉到進階分析頁面
        if (mounted) {
          _navigateToAdvancedAnalysis();
        }
      },
      onAdDismissed: () {
        // 廣告關閉
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
          });
        }
      },
      onAdFailedToShow: () {
        // 廣告播放失敗
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('廣告播放失敗，請稍後再試'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  /// 跳轉到進階分析頁面
  void _navigateToAdvancedAnalysis() {
    context.push(ResultSentencePage.route);
  }

  /// 處理刪除按鈕點擊
  Future<void> _handleDelete() async {
    final analysisState = ref.read(analysisProvider);
    final result = analysisState.result;

    if (result == null) {
      return;
    }

    // 顯示確認對話框（使用符合 Figma 設計的對話框）
    final confirmed = await showConfirmDeleteDialog(context);

    if (confirmed == true && mounted) {
      // 刪除分析結果（使用 historyProvider）
      try {
        await ref.read(historyProvider.notifier).deleteById(result.id);

        // 返回上一頁
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        // 刪除失敗時顯示錯誤訊息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('刪除失敗：$e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 顯示對話截圖（Base64 圖片）
  void _showConversationImage(String imageBase64) {
    try {
      final Uint8List bytes = base64Decode(imageBase64);

      showDialog<void>(
        context: context,
        barrierColor: AppColors.overlay,
        builder: (context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Stack(
                  children: [
                    Center(
                      child: InteractiveViewer(
                        child: Image.memory(
                          bytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('截圖載入失敗，請稍後再試')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 監聽分析狀態
    final analysisState = ref.watch(analysisProvider);

    // 監聽分析錯誤，如果有錯誤則返回 HomePage
    ref.listen<AnalysisState>(analysisProvider, (previous, next) {
      if (next.hasError && mounted) {
        debugPrint('ResultPage: 偵測到分析錯誤，返回 HomePage');
        // 返回 HomePage
        context.pop();
      }
    });

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
                      ? _buildResultView(
                          analysisState.result!,
                          analysisState.imageBase64 ?? widget.imageBase64,
                        )
                      : _buildEmptyView(),
        ),
      ),
    );
  }

  Widget _buildAnalyzingView() {
    return Center(
      child: Container(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '正在解讀',
                style: AppTextStyles.body2Semi.copyWith(
                  color: AppColors.textBlack,
                ),
              ),
              _AnimatedDots(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String? errorMessage) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s24),
      children: [
        PageHeader(
          title: '分析結果',
          leading: AppIconWidgets.arrowBack(),
          trailing: AppIconWidgets.delete(),
          onTrailingTap: _handleDelete,
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
                style: AppTextStyles.header2Semi,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                errorMessage ?? '未知錯誤',
                style: AppTextStyles.body3Regular,
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s24),
      children: [
        PageHeader(
          title: '分析結果',
          leading: AppIconWidgets.arrowBack(),
          trailing: AppIconWidgets.delete(),
          onTrailingTap: _handleDelete,
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

  Widget _buildResultView(AnalysisResult result, String? imageBase64) {
    // 準備維度分析列表
    final dimensionAnalyses = [
      DimensionAnalysis(
        title: '撩撥張力',
        score: result.radar.tension.score.round(),
        maxScore: 10,
        description: result.radar.tension.description,
      ),
      DimensionAnalysis(
        title: '自我揭露',
        score: result.radar.disclosure.score.round(),
        maxScore: 10,
        description: result.radar.disclosure.description,
      ),
      DimensionAnalysis(
        title: '關係動能',
        score: result.radar.momentum.score.round(),
        maxScore: 10,
        description: result.radar.momentum.description,
      ),
      DimensionAnalysis(
        title: '專屬特權',
        score: result.radar.exclusivity.score.round(),
        maxScore: 10,
        description: result.radar.exclusivity.description,
      ),
      DimensionAnalysis(
        title: '誘敵導引',
        score: result.radar.baiting.score.round(),
        maxScore: 10,
        description: result.radar.baiting.description,
      ),
      DimensionAnalysis(
        title: '心理防禦',
        score: result.radar.defense.score.round(),
        maxScore: 10,
        description: result.radar.defense.description,
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

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgGradientTop, AppColors.bgGradientBottom],
        ),
      ),
      child: SingleChildScrollView(
        child: RepaintBoundary(
          key: _repaintBoundaryKey,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s24),
            child: Column(
              children: [
                PageHeader(
                  title: '分析結果',
                  leading: AppIconWidgets.arrowBack(),
                  trailing: AppIconWidgets.delete(),
                  onTrailingTap: _handleDelete,
                ),
                const SizedBox(height: AppSpacing.s16),
                ScoreSummaryCard(
                  title: '曖昧指數',
                  stateText: result.relationshipStatus,
                  scoreMajor: result.totalScore.round(),
                  scoreMinor: 10,
                ),
                const SizedBox(height: AppSpacing.s24),
                // 評分分析卡片（查看對話截圖 + 六個維度說明）
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 查看對話截圖
                      if (imageBase64 != null)
                        GestureDetector(
                          onTap: () => _showConversationImage(imageBase64),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '查看對話截圖',
                                style: AppTextStyles.body2Semi.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              AppIconWidgets.camera(
                                size: 24,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '沒有對話截圖',
                              style: AppTextStyles.body3Regular.copyWith(
                                color: AppColors.textBlack80,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.s16),
                      // 分隔線
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      // 六個維度詳細分析
                      ...dimensionAnalyses.map(
                        (analysis) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.s16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${analysis.title} (${analysis.score}/${analysis.maxScore})：',
                                style: AppTextStyles.body2Bold,
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: AppSpacing.s4),
                              Text(
                                analysis.description,
                                style: AppTextStyles.body3Regular,
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                InsightCard(
                  title: '語氣洞察',
                  body: result.toneInsight,
                ),
                const SizedBox(height: AppSpacing.s16),
                SummaryCard(
                  title: '總結',
                  content: summaryContent,
                  bulletPoints: bulletPoints,
                ),
                const SizedBox(height: AppSpacing.s24),
                AppButton(
                  label: '進階逐句分析',
                  variant: AppButtonVariant.primary,
                  leading: AppIconWidgets.list(size: 24, color: Colors.white),
                  onPressed: _isLoadingAd
                      ? null
                      : () => _handleAdvancedAnalysis(result),
                ),
                const SizedBox(height: AppSpacing.s16),
                AppButton(
                  label: '截圖',
                  variant: AppButtonVariant.primary,
                  leading: AppIconWidgets.camera(size: 24, color: Colors.white),
                  onPressed: () => _handleScreenshot(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 處理截圖分享
  Future<void> _handleScreenshot() async {
    try {
      // 顯示載入提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('正在生成截圖...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 滾動到頂部，確保所有內容都已渲染
      final ScrollController? scrollController = _repaintBoundaryKey
          .currentContext
          ?.findAncestorWidgetOfExactType<SingleChildScrollView>()
          ?.controller;

      if (scrollController != null && scrollController.hasClients) {
        await scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }

      // 等待多幀，確保 RepaintBoundary 已完全渲染所有內容
      // 使用 SchedulerBinding 確保在下一幀後執行
      await Future.delayed(const Duration(milliseconds: 500));
      await SchedulerBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 200));

      // 生成截圖並分享
      if (!mounted) return;
      await _screenshotService.captureAndShare(
        repaintBoundaryKey: _repaintBoundaryKey,
        pixelRatio: 3.0, // 高解析度
        context: context, // 傳遞 context 用於 iOS sharePositionOrigin
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('截圖失敗：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    final double scanLeft =
        -scanWidth + animationValue * (size.width + scanWidth * 2);

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
            if (_controller.value >= segmentStart &&
                _controller.value <= segmentEnd) {
              localProgress =
                  (_controller.value - segmentStart) / segmentDuration;
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
                  style: AppTextStyles.body2Semi.copyWith(
                    color: AppColors.textBlack,
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
