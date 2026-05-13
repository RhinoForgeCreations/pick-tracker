import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';

class PickTrackerApp extends StatelessWidget {
  const PickTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    return MaterialApp(
      title: 'Pick Tracker',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: AppColors.surfaceBottom,
        colorScheme: base.colorScheme.copyWith(
          primary: AppColors.accent, secondary: AppColors.accentLight,
          surface: AppColors.cardBg, error: AppColors.danger),
        textTheme: base.textTheme.copyWith(bodyMedium: AppTypography.body),
      ),
      home: const Scaffold(body: Center(child: Text('pick_tracker'))),
    );
  }
}
