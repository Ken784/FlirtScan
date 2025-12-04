import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/icons/app_icon_widgets.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/upload/upload_card.dart';
import '../widgets/navigation/bottom_nav.dart';
import 'uploaded_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String route = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

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
          child: Column(
            children: [
              // 標題欄
              PageHeader(
                title: '曖昧分析',
                leading: AppIconWidgets.heartOutline(size: 24),
              ),
              // 主要內容區域
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                  children: [
                    const SizedBox(height: AppSpacing.s16),
                    // 上傳卡片（按鈕在卡片內）
                    UploadCard(
                      onUploadPressed: () => context.push(UploadedPage.route),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    // 說明區域
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _SectionTitle(text: '如何更精準的分析你們的曖昧程度？'),
                          SizedBox(height: AppSpacing.s16),
                          _CheckItem(text: '確保截圖包含完整的上下文'),
                          SizedBox(height: AppSpacing.s8),
                          _CheckItem(text: '只能分析雙人對話'),
                          SizedBox(height: AppSpacing.s8),
                          _CheckItem(text: '建議包含5句以上的對話'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                  ],
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.title3,
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.text});
  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIconWidgets.check(size: 24, color: AppColors.success),
        const SizedBox(width: AppSpacing.s10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.callout,
          ),
        ),
      ],
    );
  }
}





