import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 應用程式圖標庫
/// 管理所有自定義圖標資源
/// 
/// 注意：如果 SVG 文件不存在，會顯示錯誤信息
@immutable
class AppIcons {
  const AppIcons._();

  // 圖標資源路徑
  static const String _iconPath = 'assets/icons';

  // 對話相關
  static const String chatBubble = '$_iconPath/chat_bubble.svg';

  // 上傳
  static const String arrowUpCircle = '$_iconPath/arrow_up_circle.svg';

  // 愛心
  static const String heart = '$_iconPath/heart.svg';
  static const String heartOutline = '$_iconPath/heart_outline.svg';

  // 導航
  static const String home = '$_iconPath/home.svg';
  static const String homeSelected = '$_iconPath/home_selected.svg';
  static const String inbox = '$_iconPath/inbox.svg';
  static const String inboxSelected = '$_iconPath/inbox_selected.svg';

  // 操作
  static const String arrowBack = '$_iconPath/arrow_left.svg';
  static const String arrowLeft = '$_iconPath/arrow_left.svg';
  static const String check = '$_iconPath/check.svg';
  static const String delete = '$_iconPath/delete.svg';
  static const String camera = '$_iconPath/camera.svg';
  static const String list = '$_iconPath/list.svg';
  static const String settings = '$_iconPath/settings.svg';
  static const String activity = '$_iconPath/activity.svg';

  /// 載入 SVG 圖標（無 fallback，如果找不到會顯示錯誤）
  static Widget svg(
    String assetName, {
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      assetName,
      width: width,
      height: height,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
      fit: fit,
      // 如果找不到文件，顯示錯誤信息
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ SVG 圖標載入失敗: $assetName');
        debugPrint('錯誤: $error');
        return Container(
          width: width ?? 24,
          height: height ?? 24,
          color: Colors.red.withOpacity(0.2),
          child: Center(
            child: Text(
              '?',
              style: TextStyle(
                color: Colors.red,
                fontSize: (width ?? height ?? 24) * 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
