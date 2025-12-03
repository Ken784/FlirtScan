import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/upload/upload_card.dart';
import '../widgets/buttons/app_button.dart';
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
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const PageHeader(
                title: '曖昧分析',
                leading: Icon(Icons.favorite_border),
              ),
              const SizedBox(height: AppSpacing.s16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                child: UploadCard(),
              ),
              const SizedBox(height: AppSpacing.s16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                child: AppButton(
                  label: '選擇對話截圖',
                  variant: AppButtonVariant.primary,
                  leading: const Icon(Icons.arrow_upward, color: Colors.white),
                  onPressed: () => Navigator.pushNamed(context, UploadedPage.route),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('如何更精準的分析你們的曖昧程度？'),
                    SizedBox(height: AppSpacing.s8),
                    _CheckItem(text: '確保截圖包含完整的上下文'),
                    _CheckItem(text: '只能分析雙人對話'),
                    _CheckItem(text: '建議包含5句以上的對話'),
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

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check, color: AppColors.success, size: 20),
          const SizedBox(width: AppSpacing.s10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}



