import 'package:flutter/material.dart';
import 'app_icons.dart';

/// 預定義的圖標 Widget
/// 直接使用 SVG，如果找不到會顯示錯誤
class AppIconWidgets {
  const AppIconWidgets._();

  // 對話相關
  static Widget chatBubble({double size = 24, Color? color}) {
    return AppIcons.svg(
      AppIcons.chatBubble,
      width: size,
      height: size,
      color: color,
    );
  }

  // 上傳
  static Widget arrowUpCircle({double size = 24, Color? color}) {
    return AppIcons.svg(
      AppIcons.arrowUpCircle,
      width: size,
      height: size,
      color: color,
    );
  }

  // 愛心
  static Widget heart({double size = 24, Color? color}) {
    return AppIcons.svg(
      AppIcons.heart,
      width: size,
      height: size,
      color: color,
    );
  }

  static Widget heartOutline({double size = 24, Color? color}) {
    return AppIcons.svg(
      AppIcons.heartOutline,
      width: size,
      height: size,
      color: color,
    );
  }

  // 導航
  static Widget home({double size = 24, Color? color, bool selected = false}) {
    return AppIcons.svg(
      selected ? AppIcons.homeSelected : AppIcons.home,
      width: size,
      height: size,
      color: color,
    );
  }

  static Widget inbox({double size = 24, Color? color, bool selected = false}) {
    return AppIcons.svg(
      selected ? AppIcons.inboxSelected : AppIcons.inbox,
      width: size,
      height: size,
      color: color,
    );
  }

  // 操作
  static Widget arrowBack({double size = 24, Color? color}) {
    return AppIcons.svg(
      AppIcons.arrowBack,
      width: size,
      height: size,
      color: color,
    );
  }

  static Widget check({double size = 24, Color? color}) {
    return AppIcons.svg(
      AppIcons.check,
      width: size,
      height: size,
      color: color,
    );
  }

  static Widget delete({double size = 24, Color? color}) {
    return AppIcons.svg(
      AppIcons.delete,
      width: size,
      height: size,
      color: color,
    );
  }

  static Widget camera({double size = 24, Color? color}) {
    return AppIcons.svg(
      AppIcons.camera,
      width: size,
      height: size,
      color: color,
    );
  }

  static Widget list({double size = 24, Color? color}) {
    return AppIcons.svg(
      AppIcons.list,
      width: size,
      height: size,
      color: color,
    );
  }
}

