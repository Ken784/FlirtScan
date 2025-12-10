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
        width: 270,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E), // 深灰色背景
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 標題區域
            Padding(
              padding: const EdgeInsets.only(
                top: 19,
                left: 16,
                right: 16,
              ),
              child: Text(
                title,
                style: AppTextStyles.title2.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // 訊息區域
            Padding(
              padding: const EdgeInsets.only(
                top: 2,
                left: 16,
                right: 16,
                bottom: 19,
              ),
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: -0.08,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // 分隔線
            Container(
              height: 0.5,
              color: Colors.white.withOpacity(0.2),
            ),
            
            // 按鈕
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed ?? () => Navigator.of(context).pop(),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  alignment: Alignment.center,
                  child: Text(
                    buttonText ?? '確定',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: -0.4,
                    ),
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

