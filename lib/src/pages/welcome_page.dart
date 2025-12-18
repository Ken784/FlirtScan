import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_radii.dart';
import '../core/providers/onboarding_provider.dart';
import 'home_page.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});
  static const String route = '/welcome';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDCF4FC), // #dcf4fc
              Color(0xFFE8E2FF), // #e8e2ff
            ],
          ),
        ),
        child: Column(
          children: [
            // 主圖像區域（延伸到 status bar 下方，緊貼左右）
            Expanded(
              flex: 3,
              child: _buildMainImage(context),
            ),
            // 文字和按鈕區域（底部使用 SafeArea）
            Expanded(
              flex: 2,
              child: SafeArea(
                top: false,
                child: _buildContent(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 建立主圖像區域
  Widget _buildMainImage(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Image.asset(
        'assets/welcome_main_image.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          // 如果圖片不存在，顯示佔位符
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Center(
              child: Icon(
                Icons.image,
                size: 64,
                color: AppColors.primary,
              ),
            ),
          );
        },
      ),
    );
  }


  /// 建立內容區域（文字和按鈕）
  Widget _buildContent(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 文字內容
          Column(
            children: [
              Text(
                '他/她對我有意思嗎？',
                style: AppTextStyles.body3Regular.copyWith(
                  color: AppColors.textBlack80,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                '他/她是在等我發出邀請嗎？',
                style: AppTextStyles.body3Regular.copyWith(
                  color: AppColors.textBlack80,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                '讓我們幫忙解析對話中的小心思',
                style: AppTextStyles.body2Bold.copyWith(
                  color: AppColors.textBlack,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s32),
          // 開始按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // 標記已看過歡迎頁面
                await ref.read(onboardingProvider.notifier).completeOnboarding();
                // 導航到首頁
                if (context.mounted) {
                  context.go(HomePage.route);
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.pill,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s24,
                  vertical: AppSpacing.s12,
                ),
                minimumSize: const Size(double.infinity, AppSpacing.s52),
              ),
              child: Text(
                '開始',
                style: AppTextStyles.body3Bold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
