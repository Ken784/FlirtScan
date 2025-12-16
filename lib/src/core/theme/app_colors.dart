import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors._();

  // Brand / Theme
  static const Color primary = Color(0xFF6E2DF0);
  static const Color star = Color(0xFFF02D2D);
  static const Color green = Color(0xFF27CC1C);

  // Text
  static const Color textBlack = Color(0xFF000000);
  static const Color textBlack80 = Color(0xFF333333); // grey/80
  static const Color textGrey40 = Color(0xFF999999); // grey/40

  // Backgrounds
  static const Color bgGradientTop = Color(0xFFFFEEFE);
  static const Color bgGradientBottom = Color(0xFFE8F2FF);
  static const Color bgPageAlt = Color(0xFFFFFAFB);
  static const Color surface = Colors.white;
  static const Color overlay = Color.fromRGBO(0, 0, 0, 0.5);

  // Secondary surfaces (bubble colors)
  static const Color secondaryYellow = Color(0xFFFFFEC0); // bubble-1, opponent
  static const Color secondaryBlue = Color(0xFFD9F4FF); // bubble-2, me

  // Grey scale
  static const Color grey10 = Color(0xFFE5E5E5); // disabled
  static const Color grey40 = Color(0xFF999999);
  static const Color grey80 = Color(0xFF333333);

  // Basic colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // State (legacy - use green instead)
  @Deprecated('Use AppColors.green instead')
  static const Color success = green;
}












