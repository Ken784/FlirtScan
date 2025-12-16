import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/icons/app_icon_widgets.dart';
import '../buttons/app_button.dart';

class UploadCard extends StatelessWidget {
  const UploadCard({
    super.key,
    this.onUploadPressed,
  });

  final VoidCallback? onUploadPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 416,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        boxShadow: AppShadow.card,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: AppSpacing.s16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 圖標和文字組（gap: 8px）
          Column(
            children: [
              _ChatIcons(),
              const SizedBox(height: AppSpacing.s8),
              Text(
                '上傳你們的對話',
                style: AppTextStyles.body2Semi,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          // 圖標+文字組和按鈕之間的間距（gap: 36px）
          const SizedBox(height: AppSpacing.s36),
          // 上傳按鈕
          SizedBox(
            width: 266,
            child: AppButton(
              label: '選擇對話截圖',
              variant: AppButtonVariant.primary,
              leading: AppIconWidgets.arrowUpCircle(size: 24, color: Colors.white),
              onPressed: onUploadPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatIcons extends StatelessWidget {
  const _ChatIcons();

  @override
  Widget build(BuildContext context) {
    // chat_bubble.svg 已經包含了兩個對話泡泡的設計
    // 直接使用這個 SVG，不需要翻轉
    final chatColor = AppColors.bgGradientTop.withOpacity(0.8);
    
    return SizedBox(
      height: 107,
      width: 170,
      child: AppIconWidgets.chatBubble(size: 170, color: chatColor),
    );
  }
}



