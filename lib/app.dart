import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/resume_prompt.dart';
import 'state/app_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';

class PickTrackerApp extends StatefulWidget {
  const PickTrackerApp({super.key});
  @override
  State<PickTrackerApp> createState() => _PickTrackerAppState();
}

class _PickTrackerAppState extends State<PickTrackerApp> {
  final AppState _state = AppState();
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _state.init().then((_) async {
      await _state.autoCloseStaleShifts();
      if (!mounted) return;
      setState(() => _ready = true);
      _maybeShowResumePrompt();
    });
  }

  void _maybeShowResumePrompt() {
    final shift = _state.activeShift;
    final order = _state.activeOrder;
    if (shift == null || order == null) return;
    final last = order.startedAt.toLocal();
    final mins = DateTime.now().difference(last).inMinutes;
    final threshold = _state.settings!.shiftGapMinutes;
    if (mins <= 10 || mins >= threshold) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _navKey.currentContext;
      if (ctx == null) return;
      showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) => ResumePrompt(
          lastActivity: last,
          onContinue: () => Navigator.pop(ctx),
          onEnd: () async {
            Navigator.pop(ctx);
            await _state.endShift();
          }));
    });
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    return MaterialApp(
      title: 'Pick Tracker',
      navigatorKey: _navKey,
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: AppColors.surfaceBottom,
        colorScheme: base.colorScheme.copyWith(
          primary: AppColors.accent,
          secondary: AppColors.accentLight,
          surface: AppColors.cardBg,
          error: AppColors.danger),
        textTheme: base.textTheme.copyWith(bodyMedium: AppTypography.body)),
      home: _ready
          ? HomeScreen(state: _state)
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
