import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/icons/app_icon_widgets.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/cards/score_summary_card.dart';
import '../widgets/cards/insight_card.dart';
import '../widgets/cards/radar_analysis_card.dart';
import '../widgets/cards/summary_card.dart';
import '../widgets/charts/radar_chart.dart';
import '../widgets/buttons/app_button.dart';
import 'result_sentence_page.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});
  static const String route = '/result';

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 0, AppSpacing.s20, 120),
            children: [
              PageHeader(
                title: '分析結果',
                leading: AppIconWidgets.arrowBack(),
                trailing: AppIconWidgets.delete(),
              ),
              const SizedBox(height: AppSpacing.s16),
              const ScoreSummaryCard(
                title: '曖昧指數',
                stateText: '準告白狀態',
                scoreMajor: 9,
                scoreMinor: 10,
              ),
              const SizedBox(height: AppSpacing.s24),
              // 雷達圖分析卡片
              RadarAnalysisCard(
                dataPoints: const [
                  RadarDataPoint(label: '情緒投入度', value: 0.8),
                  RadarDataPoint(label: '語氣親密度', value: 0.9),
                  RadarDataPoint(label: '玩笑 / 調情程度', value: 0.9),
                  RadarDataPoint(label: '回覆積極度', value: 0.8),
                  RadarDataPoint(label: '互動平衡度', value: 0.7),
                ],
                dimensionAnalyses: const [
                  DimensionAnalysis(
                    title: '情緒投入度',
                    score: 8,
                    maxScore: 10,
                    description: '雙方都有情緒色彩：忘記回覆→懊惱、自責；對方回應→關心＋撒嬌。「心疼」「啾幾口」屬高情緒字眼。',
                  ),
                  DimensionAnalysis(
                    title: '語氣親密度',
                    score: 9,
                    maxScore: 10,
                    description: '「我跪」「不用跪」「心疼」「啾幾口」都是明確親密語氣。',
                  ),
                  DimensionAnalysis(
                    title: '玩笑 / 調情程度',
                    score: 9,
                    maxScore: 10,
                    description: '「跪」→自嘲；「啾幾口」→明顯調情；貼圖也加強互動感。',
                  ),
                  DimensionAnalysis(
                    title: '回覆積極度',
                    score: 8,
                    maxScore: 10,
                    description: '雙方都有明確回應意圖，不敷衍；沒有延遲、沒有冷淡。',
                  ),
                  DimensionAnalysis(
                    title: '互動平衡度',
                    score: 7,
                    maxScore: 10,
                    description: '一方道歉示弱，一方給予溫柔「心疼式」回應，互補關係良好。',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              InsightCard(
                title: '🔍 語氣洞察',
                body: '語氣特徵很明顯落在 甜 × 撒嬌 × 半角色扮演的輕挑對話。',
              ),
              const SizedBox(height: AppSpacing.s16),
              SummaryCard(
                title: '✨ 總結',
                content: '這段對話呈現 雙方互相調情＋高度語氣親密＋明顯情緒投入。',
                bulletPoints: const [
                  '對方用「跪」「忘記回你」呈現 重視你＋撒嬌式道歉',
                  '你回「心疼」「啾幾口」＝明確情感暗示',
                  '整體語氣像是「半交往」狀態',
                  '若這是雙向關係，已經非常接近表白前的階段',
                ],
                footer: '這是一個互相拉近距離成功的例子，雙向明確甜味。',
              ),
              const SizedBox(height: AppSpacing.s24),
              AppButton(
                label: '進階逐句分析',
                variant: AppButtonVariant.primary,
                leading: AppIconWidgets.list(size: 24, color: Colors.white),
                onPressed: () => context.push(ResultSentencePage.route),
              ),
              const SizedBox(height: AppSpacing.s16),
              AppButton(
                label: '截圖',
                variant: AppButtonVariant.primary,
                leading: AppIconWidgets.camera(size: 24, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}





