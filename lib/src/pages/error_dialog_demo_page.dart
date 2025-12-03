import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/buttons/app_button.dart';

class ErrorDialogDemoPage extends StatelessWidget {
  const ErrorDialogDemoPage({super.key});
  static const String route = '/error';

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
              const PageHeader(title: '錯誤訊息範例', leading: Icon(Icons.favorite_border)),
              const SizedBox(height: AppSpacing.s24),
              AppButton(
                label: '顯示錯誤 Dialog',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('錯誤標題'),
                      content: const Text('錯誤訊息內容顯示錯誤訊息內容顯示錯誤訊息內容顯示錯誤訊息內容顯示'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('button')),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



