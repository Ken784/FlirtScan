import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_radii.dart';

/// 顯示確認刪除對話框
/// 參考設計: https://www.figma.com/design/Z2YBZJO8AEbauRkU6YuwRQ/Flirt-Analysis?node-id=219-362
Future<bool?> showConfirmDeleteDialog(
  BuildContext context, {
  String? title,
  String? message,
  String? confirmText,
  String? cancelText,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: AppColors.overlay,
    barrierDismissible: true,
    builder: (context) => ConfirmDeleteDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
    ),
  );
}

class ConfirmDeleteDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final String? confirmText;
  final String? cancelText;

  const ConfirmDeleteDialog({
    super.key,
    this.title,
    this.message,
    this.confirmText,
    this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: AppColors.surface, // 白色背景
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題
            Text(
              title ?? '確認刪除？',
              style: AppTextStyles.title2.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textBlack,
                letterSpacing: -0.26,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            
            // 訊息內容
            Text(
              message ?? '確定要刪除這筆分析結果嗎？此操作無法復原。',
              style: AppTextStyles.body.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: AppColors.textBlack,
                letterSpacing: -0.43,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            
            // 確定按鈕（主要按鈕：紅色背景 + 白色文字）
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.pill,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s20,
                    vertical: AppSpacing.s12,
                  ),
                ),
                child: Text(
                  confirmText ?? '確定',
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.43,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            
            // 取消按鈕（次要按鈕：白色背景 + 紅色文字 + 紅色邊框）
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 1,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.pill,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s20,
                    vertical: AppSpacing.s12,
                  ),
                ),
                child: Text(
                  cancelText ?? '取消',
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: -0.43,
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




