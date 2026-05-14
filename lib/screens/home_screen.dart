import 'dart:async';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/active_order_card.dart';
import '../widgets/keypad.dart';
import '../widgets/stats_strip.dart';
import '../widgets/target_chip.dart';
import 'end_shift_summary.dart';
import 'history_hub_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _tick;
  String _input = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restoreBuffer();
    _startTick();
  }

  Future<void> _restoreBuffer() async {
    _input = await widget.state.readInputBuffer();
    if (mounted) setState(() {});
  }

  void _startTick() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) {
      _startTick();
    } else {
      _tick?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _onChange(String v) async {
    setState(() => _input = v);
    await widget.state.setInputBuffer(v);
  }

  Future<void> _onSubmit(int cases) async {
    setState(() => _input = '');
    await widget.state.submitNext(cases);
  }

  Future<void> _openOverflow() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(child: Wrap(children: [
        ListTile(
          leading: const Icon(Icons.stop_circle_outlined),
          title: const Text('End shift'),
          enabled: widget.state.activeShift != null,
          onTap: () => Navigator.pop(context, 'end')),
        ListTile(
          leading: const Icon(Icons.undo),
          title: const Text('Undo last order'),
          enabled: widget.state.activeOrder != null,
          onTap: () => Navigator.pop(context, 'undo')),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('History'),
          onTap: () => Navigator.pop(context, 'history')),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () => Navigator.pop(context, 'settings')),
      ])));
    if (result == null) return;
    switch (result) {
      case 'end':
        final shiftId = widget.state.activeShift?.id;
        await widget.state.endShift();
        if (!mounted || shiftId == null) break;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 5),
          content: const Text('Shift ended'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              await widget.state.reopenShift(shiftId);
            })));
        final summary = await widget.state.summarizeShift(shiftId);
        if (!mounted || summary == null) break;
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => EndShiftSummary(
            totalCases: summary.totalCases,
            target: summary.target,
            hours: summary.hours,
            minutes: summary.minutes,
            orders: summary.orders,
            shiftRate: summary.shiftRate,
            activeRate: summary.activeRate,
            bestCases: summary.bestCases,
            bestRate: summary.bestRate,
            slowestCases: summary.slowestCases,
            slowestRate: summary.slowestRate,
            outlierCount: summary.outlierCount,
            streak: summary.streak)));
        break;
      case 'undo':
        await widget.state.undoLastOrder();
        if (mounted) setState(() {});
        break;
      case 'history':
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => HistoryHubScreen(state: widget.state)));
        break;
      case 'settings':
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => SettingsScreen(state: widget.state)));
        if (mounted) setState(() {});
        break;
    }
  }

  Future<void> _editTarget() async {
    final ctrl = TextEditingController(text: '${widget.state.target}');
    final v = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Today's target"),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)),
            child: const Text('OK')),
        ]));
    if (v != null && v > 0) {
      if (widget.state.activeShift != null) {
        await widget.state.updateActiveShiftTarget(v);
      } else {
        await widget.state.setDefaultTarget(v);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final settings = state.settings!;
    return AnimatedBuilder(
      animation: state,
      builder: (_, __) {
        final shiftStart = state.activeShift?.startedAt.toLocal();
        final shiftElapsed = shiftStart == null
            ? Duration.zero
            : DateTime.now().difference(shiftStart);
        final shiftRate = (shiftStart == null || shiftElapsed.inSeconds == 0)
            ? 0.0
            : (state.todayTotal / (shiftElapsed.inSeconds / 3600))
                .clamp(0, 9999)
                .toDouble();
        return Container(
          decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: _openOverflow),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: TargetChip(target: state.target, onTap: _editTarget))),
              ],
            ),
            body: SafeArea(child: Column(children: [
              StatsStrip(
                todayTotal: state.todayTotal,
                target: state.target,
                shiftRate: shiftRate,
                shiftElapsed: shiftElapsed),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ActiveOrderCard(
                  cases: state.activeOrder?.cases,
                  startedAt: state.activeOrder?.startedAt,
                  active: state.activeOrder != null)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Next order cases', style: AppTypography.statLabel)),
              const SizedBox(height: 6),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12)),
                child: Text(_input.isEmpty ? '0' : _input,
                  style: AppTypography.bigCount)),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Keypad(
                    value: _input,
                    onChange: _onChange,
                    onSubmit: _onSubmit,
                    softCap: settings.softCapPerOrder,
                    hardCap: settings.hardCapPerOrder))),
            ])),
          ),
        );
      });
  }
}
