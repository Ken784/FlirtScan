import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 顯示錯誤對話框
/// 參考設計: https://www.figma.com/design/Z2YBZJO8AEbauRkU6YuwRQ/Flirt-Analysis?node-id=139-344
void showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? buttonText,
  VoidCallback? onPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ErrorDialog(
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    ),
  );
}

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 249,
        decoration: BoxDecoration(
          color: Colors.white, // 白色背景（根據 Figma 設計）
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題和訊息容器（gap: 16px）
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 標題區域
                Text(
                  title,
                  style: AppTextStyles.body1Semi.copyWith(
                    fontSize: 18,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 16),
                // 訊息區域（使用 grey/80 顏色）
                Text(
                  message,
                  style: AppTextStyles.body3Regular.copyWith(
                    color: AppColors.textBlack80,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 按鈕（主要按鈕樣式：紫色背景 + 白色文字）
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onPressed ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  buttonText ?? '確定',
                  style: AppTextStyles.body2Bold.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
