import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/icons/app_icon_widgets.dart';
import '../core/providers/analysis_provider.dart';
import '../core/models/analysis_result.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/cards/quote_analysis_card.dart';
import '../widgets/cards/advanced_summary_card.dart';
import '../widgets/buttons/app_button.dart';

class ResultSentencePage extends ConsumerWidget {
  const ResultSentencePage({super.key});
  static const String route = '/result-sentence';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s24),
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
                onPressed: () {
                  // TODO: 實作截圖功能
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}






