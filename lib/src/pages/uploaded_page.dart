import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/upload/upload_card.dart';
import '../widgets/buttons/app_button.dart';
import '../widgets/navigation/bottom_nav.dart';
import 'result_page.dart';

class UploadedPage extends StatefulWidget {
  const UploadedPage({super.key});
  static const String route = '/uploaded';

  @override
  State<UploadedPage> createState() => _UploadedPageState();
}

class _UploadedPageState extends State<UploadedPage> {
  int _navIndex = 0;
  bool _hasImage = true;

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
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const PageHeader(
                title: '曖昧分析',
                leading: Icon(Icons.favorite_border),
              ),
              const SizedBox(height: AppSpacing.s16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                child: UploadCard(
                  image: _hasImage ? null : null,
                  onRemove: () => setState(() => _hasImage = false),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: AppButton(
                  label: '開始分析對話',
                  onPressed: () => Navigator.pushNamed(context, ResultPage.route),
                  variant: AppButtonVariant.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s40),
                child: Text(
                  '深度解析對話中的情緒、語氣與曖昧指數，還能生成雷達圖和可分享的金句！',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}


