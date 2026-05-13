import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static const TextStyle hero = TextStyle(
    fontSize: 80, fontWeight: FontWeight.w300, letterSpacing: -2,
    color: AppColors.textPrimary, fontFeatures: tabular, height: 1.0);
  static const TextStyle bigCount = TextStyle(
    fontSize: 48, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, fontFeatures: tabular);
  static const TextStyle statLabel = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, letterSpacing: 0.5);
  static const TextStyle statValue = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary, fontFeatures: tabular);
  static const TextStyle body = TextStyle(
    fontSize: 16, height: 1.5, color: AppColors.textPrimary);
  static const TextStyle keypadDigit = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary, fontFeatures: tabular);
}
