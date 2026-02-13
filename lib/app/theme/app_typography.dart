import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const _fontFamily = 'Pretendard';

  static const headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    color: AppColors.textSecondary,
  );

  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    color: AppColors.textSecondary,
  );
}
