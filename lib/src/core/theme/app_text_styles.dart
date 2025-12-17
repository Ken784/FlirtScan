import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class AppTextStyles {
  const AppTextStyles._();

  static const String primaryFontFamily = 'SF Pro';
  static const double defaultLetterSpacing = -0.4;

  static TextStyle _base({
    required double size,
    required double height,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textBlack,
    FontStyle style = FontStyle.normal,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      color: color,
      fontStyle: style,
      letterSpacing: letterSpacing ?? defaultLetterSpacing,
    );
  }

  // Header styles
  static final TextStyle header1Bold = _base(
    size: 18,
    height: 24,
    weight: FontWeight.w700,
  );

  static final TextStyle header2Semi = _base(
    size: 18,
    height: 24,
    weight: FontWeight.w500,
  );

  // Body 1 styles
  static final TextStyle body1Bold = _base(
    size: 18,
    height: 24,
    weight: FontWeight.w700,
  );

  static final TextStyle body1Semi = _base(
    size: 18,
    height: 24,
    weight: FontWeight.w500,
  );

  // Body 2 styles
  static final TextStyle body2Bold = _base(
    size: 16,
    height: 24,
    weight: FontWeight.w700,
  );

  static final TextStyle body2Semi = _base(
    size: 16,
    height: 24,
    weight: FontWeight.w500,
  );

  static final TextStyle body2Regular = _base(
    size: 16,
    height: 24,
    weight: FontWeight.w400,
    letterSpacing: 0,
  );

  // Body 3 styles
  static final TextStyle body3Bold = _base(
    size: 14,
    height: 20,
    weight: FontWeight.w700,
  );

  static final TextStyle body3Semi = _base(
    size: 14,
    height: 20,
    weight: FontWeight.w500,
  );

  static final TextStyle body3Regular = _base(
    size: 14,
    height: 20,
    weight: FontWeight.w400,
  );

  // Caption styles
  static final TextStyle captionBold = _base(
    size: 12,
    height: 18,
    weight: FontWeight.w700,
  );

  static final TextStyle captionRegular = _base(
    size: 12,
    height: 18,
    weight: FontWeight.w400,
  );
}
