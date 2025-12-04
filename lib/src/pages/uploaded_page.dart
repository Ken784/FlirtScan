import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/icons/app_icon_widgets.dart';
import '../widgets/navigation/page_header.dart';

class UploadedPage extends StatelessWidget {
  const UploadedPage({super.key});
  static const String route = '/uploaded';

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
              PageHeader(title: '上傳截圖', leading: AppIconWidgets.arrowBack()),
              const SizedBox(height: AppSpacing.s24),
              // TODO: 實作上傳功能
            ],
          ),
        ),
      ),
    );
  }
}

