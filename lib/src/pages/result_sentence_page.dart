import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/cards/quote_analysis_card.dart';
import '../widgets/buttons/app_button.dart';

class ResultSentencePage extends StatelessWidget {
  const ResultSentencePage({super.key});
  static const String route = '/result-sentence';

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
              const PageHeader(title: '逐句分析', leading: Icon(Icons.arrow_back)),
              const SizedBox(height: AppSpacing.s16),
              const QuoteAnalysisCard(
                side: QuoteSide.opponent,
                quote: '幹...我快氣到哭 全部都老一滴血輸掉ㄟ🥲',
                meaning: '對方在抱怨輸遊戲、情緒很真實，語氣放輕鬆像在和熟人撒嬌。',
                rating: 2,
                ratingPercent: 20,
              ),
              const SizedBox(height: AppSpacing.s16),
              const QuoteAnalysisCard(
                side: QuoteSide.me,
                quote: '學妹要不要玩遊戲 ❤️',
                meaning: '主動邀約、加上❤️，是明顯試探；稱呼「學妹」營造一種角色關係（有趣＋親密）。',
                rating: 7,
                ratingPercent: 70,
              ),
              const SizedBox(height: AppSpacing.s16),
              const QuoteAnalysisCard(
                side: QuoteSide.opponent,
                quote: '好啊哈哈哈',
                meaning: '表面輕鬆回應，但沒有拒絕對方的邀約，保留了繼續互動的空間。',
                rating: 5,
                ratingPercent: 50,
              ),
              const SizedBox(height: AppSpacing.s24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: const Text(
                  '✨ 總結\n從這些對話可以看出，你們之間存在超越普通朋友的情感連結。',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
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






