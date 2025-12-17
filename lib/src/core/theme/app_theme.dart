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
        // Header styles
        displayLarge: AppTextStyles.header1Bold,
        headlineLarge: AppTextStyles.header1Bold,
        headlineMedium: AppTextStyles.header2Semi,
        headlineSmall: AppTextStyles.header1Bold,
        // Body styles
        bodyLarge: AppTextStyles.body1Semi,
        bodyMedium: AppTextStyles.body2Regular,
        bodySmall: AppTextStyles.body3Regular,
        titleMedium: AppTextStyles.body1Semi,
        titleSmall: AppTextStyles.captionBold,
        // Legacy mappings for backward compatibility
        labelLarge: AppTextStyles.body2Regular,
        labelMedium: AppTextStyles.body3Regular,
        labelSmall: AppTextStyles.captionRegular,
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
