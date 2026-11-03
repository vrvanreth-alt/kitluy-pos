import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension ThemeContextExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceColor => isDark ? AppColors.darkSurface : AppColors.surface;
  Color get surfaceMutedColor => isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;
  Color get backgroundColor => isDark ? AppColors.darkBackground : AppColors.background;
  Color get borderColor => isDark ? AppColors.darkCardBorder : AppColors.cardBorder;
  Color get textPrimaryColor => isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get textSecondaryColor => isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get textMutedColor => isDark ? AppColors.darkTextMuted : AppColors.textMuted;
  Color get primaryAccent => isDark ? AppColors.primaryLight : AppColors.primary;
}
