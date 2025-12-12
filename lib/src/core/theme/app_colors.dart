import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFFF02D2D);

  // Text
  static const Color textBlack = Color(0xFF000000);
  static const Color textBlack80 = Color.fromRGBO(0, 0, 0, 0.8);

  // Backgrounds
  static const Color bgGradientTop = Color(0xFFFFEEFE);
  static const Color bgGradientBottom = Color(0xFFE8F2FF);
  static const Color bgPageAlt = Color(0xFFFFFAFB);
  static const Color surface = Colors.white;
  static const Color overlay = Color.fromRGBO(0, 0, 0, 0.5);

  // Secondary surfaces
  static const Color secondaryYellow = Color(0xFFFFFEC0); // opponent
  static const Color secondaryBlue = Color(0xFFD9F4FF); // me

  // State
  static const Color success = Color(0xFF27CC1C);
}










