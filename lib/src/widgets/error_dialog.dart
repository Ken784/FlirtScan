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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 標題區域
            Text(
              title,
              style: AppTextStyles.body1Semi.copyWith(
                fontSize: 18,
                color: AppColors.textBlack,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),

            // 訊息區域
            Text(
              message,
              style: AppTextStyles.body3Regular,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 40),

            // 按鈕（次要按鈕樣式：白色背景 + 紅色邊框）
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: onPressed ?? () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  buttonText ?? '確定',
                  style: AppTextStyles.body2Semi.copyWith(
                    color: AppColors.primary,
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
