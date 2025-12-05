import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class AppTextStyles {
  const AppTextStyles._();

  static const String primaryFontFamily = 'SF Pro';

  static TextStyle _base({
    required double size,
    required double height,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textBlack,
    FontStyle style = FontStyle.normal,
  }) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      color: color,
      fontStyle: style,
    );
  }

  // Titles
  static final TextStyle title1 = _base(size: 28, height: 34, weight: FontWeight.w700);
  static final TextStyle title2 = _base(size: 22, height: 28, weight: FontWeight.w700);
  static final TextStyle title3 = _base(size: 20, height: 25, weight: FontWeight.w600);

  // Body
  static final TextStyle body = _base(size: 17, height: 22, weight: FontWeight.w400, color: AppColors.textBlack80);
  static final TextStyle bodyEmphasis = _base(size: 17, height: 22, weight: FontWeight.w600);

  // Callout/Subheadline/Footnote/Caption
  static final TextStyle callout = _base(size: 16, height: 21, weight: FontWeight.w400, color: AppColors.textBlack80);
  static final TextStyle subheadline = _base(size: 15, height: 20, weight: FontWeight.w400, color: AppColors.textBlack80);
  static final TextStyle footnote = _base(size: 13, height: 18, weight: FontWeight.w400, color: AppColors.textBlack80);
  static final TextStyle captionEmphasis = _base(size: 12, height: 16, weight: FontWeight.w500);
}







