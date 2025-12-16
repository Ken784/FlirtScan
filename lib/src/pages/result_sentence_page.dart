import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/icons/app_icon_widgets.dart';
import '../core/providers/analysis_provider.dart';
import '../core/models/analysis_result.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/cards/quote_analysis_card.dart';
import '../widgets/cards/advanced_summary_card.dart';
import '../widgets/buttons/app_button.dart';
import '../services/screenshot_service.dart';

class ResultSentencePage extends ConsumerStatefulWidget {
  const ResultSentencePage({super.key});
  static const String route = '/result-sentence';

  @override
  ConsumerState<ResultSentencePage> createState() => _ResultSentencePageState();
}

class _ResultSentencePageState extends ConsumerState<ResultSentencePage> {
  final ScreenshotService _screenshotService = ScreenshotService();
  final GlobalKey _repaintBoundaryKey = GlobalKey();

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
      final ScrollController? scrollController = _repaintBoundaryKey.currentContext
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

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisProvider);
    final result = analysisState.result;

    // 如果沒有分析結果，顯示錯誤頁面
    if (result == null) {
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('沒有分析結果'),
                  const SizedBox(height: 16),
                  AppButton(
                    label: '返回',
                    variant: AppButtonVariant.primary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
          child: Container(
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
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s24),
                  child: Column(
                    children: [
              PageHeader(title: '逐句分析', leading: AppIconWidgets.arrowBack()),
              const SizedBox(height: AppSpacing.s16),
              
              // 逐句分析卡片 - 根據發話者對齊
              ...result.sentences.asMap().entries.map((entry) {
                final sentence = entry.value;
                final isLastItem = entry.key == result.sentences.length - 1;
                final isMe = sentence.speaker == Speaker.me;
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLastItem ? 0 : AppSpacing.s16,
                    // Partner 左對齊，Me 右對齊
                    left: isMe ? AppSpacing.s24 : 0,
                    right: isMe ? 0 : AppSpacing.s24,
                  ),
                  child: QuoteAnalysisCard(
                    side: isMe ? QuoteSide.me : QuoteSide.opponent,
                    quote: sentence.originalText,
                    meaning: sentence.hiddenMeaning,
                    rating: sentence.flirtScore,
                    ratingPercent: (sentence.flirtScore * 10).clamp(0, 100),
                    reason: sentence.scoreReason,
                  ),
                );
              }),
              
              const SizedBox(height: AppSpacing.s24),
              
              // 進階總結卡片
              AdvancedSummaryCard(summary: result.advancedSummary),
              
              const SizedBox(height: AppSpacing.s24),
              
                // 截圖按鈕
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
          ),
        ),
      ),
    );
  }
}






