import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/cards/score_summary_card.dart';
import '../widgets/cards/insight_card.dart';
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
              const PageHeader(
                title: '分析結果',
                leading: Icon(Icons.arrow_back),
                trailing: Icon(Icons.delete_outline),
              ),
              const SizedBox(height: AppSpacing.s16),
              const ScoreSummaryCard(
                title: '曖昧指數',
                stateText: '準告白狀態',
                scoreMajor: 9,
                scoreMinor: 10,
              ),
              const SizedBox(height: AppSpacing.s24),
              InsightCard(
                title: '🔍 語氣洞察',
                body: '語氣特徵落在 甜 × 撒嬌 × 半角色扮演的輕挑對話。',
              ),
              const SizedBox(height: AppSpacing.s16),
              InsightCard(
                title: '✨ 總結',
                body:
                    '這段對話呈現 雙方互相調情＋高度語氣親密＋明顯情緒投入。若這是雙向關係，已非常接近表白前的階段。',
              ),
              const SizedBox(height: AppSpacing.s24),
              AppButton(
                label: '進階逐句分析',
                variant: AppButtonVariant.primary,
                leading: const Icon(Icons.list, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, ResultSentencePage.route),
              ),
              const SizedBox(height: AppSpacing.s16),
              AppButton(
                label: '截圖',
                variant: AppButtonVariant.primary,
                leading: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}



