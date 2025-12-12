import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.textBlack,
      ),
      scaffoldBackgroundColor: AppColors.surface,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTextStyles.title1,
        headlineLarge: AppTextStyles.title1,
        headlineMedium: AppTextStyles.title2,
        headlineSmall: AppTextStyles.title3,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.callout,
        bodySmall: AppTextStyles.subheadline,
        titleMedium: AppTextStyles.bodyEmphasis,
        titleSmall: AppTextStyles.captionEmphasis,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textBlack,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}








