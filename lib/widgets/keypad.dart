import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Keypad extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChange;
  final ValueChanged<int> onSubmit;
  final int softCap;
  final int hardCap;

  const Keypad({
    super.key, required this.value, required this.onChange,
    required this.onSubmit, required this.softCap, required this.hardCap,
  });

  @override
  State<Keypad> createState() => _KeypadState();
}

class _KeypadState extends State<Keypad> {
  DateTime _lastSubmit = DateTime.fromMillisecondsSinceEpoch(0);

  void _appendDigit(String d) {
    final next = (widget.value == '0' ? '' : widget.value) + d;
    final asInt = int.tryParse(next) ?? 0;
    if (asInt > widget.hardCap) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.selectionClick();
    widget.onChange(next);
  }

  void _backspace() {
    if (widget.value.isEmpty) return;
    HapticFeedback.selectionClick();
    widget.onChange(widget.value.substring(0, widget.value.length - 1));
  }

  Future<void> _next() async {
    final asInt = int.tryParse(widget.value) ?? 0;
    if (asInt <= 0) { HapticFeedback.heavyImpact(); return; }
    final now = DateTime.now();
    if (now.difference(_lastSubmit).inMilliseconds < 300) return;
    _lastSubmit = now;
    if (asInt > widget.softCap) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirm large order'),
          content: Text('$asInt cases — is that right?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm')),
          ]));
      if (ok != true) return;
    }
    HapticFeedback.mediumImpact();
    widget.onSubmit(asInt);
  }

  @override
  Widget build(BuildContext context) {
    final asInt = int.tryParse(widget.value) ?? 0;
    final canSubmit = asInt > 0;
    Widget digit(String d) => _KBtn(
      label: d, semantic: 'Digit $d', onTap: () => _appendDigit(d));
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [digit('7'), digit('8'), digit('9')]),
      Row(children: [digit('4'), digit('5'), digit('6')]),
      Row(children: [digit('1'), digit('2'), digit('3')]),
      Row(children: [
        _KBtn(label: '⌫', semantic: 'Backspace', onTap: _backspace),
        digit('0'),
        _KBtn(label: 'NEXT', semantic: 'Submit order',
          onTap: canSubmit ? _next : null, filled: canSubmit),
      ]),
    ].animate(interval: 40.ms).fadeIn(duration: 250.ms).slideY(begin: 0.2, curve: Curves.easeOut));
  }
}

class _KBtn extends StatelessWidget {
  final String label;
  final String semantic;
  final VoidCallback? onTap;
  final bool filled;
  const _KBtn({
    required this.label, required this.semantic,
    this.onTap, this.filled = false});
  @override
  Widget build(BuildContext context) {
    final bg = filled ? AppColors.accent : AppColors.cardBg;
    final fg = filled ? Colors.black : AppColors.textPrimary;
    return Expanded(child: AspectRatio(
      aspectRatio: 1.6,
      child: Padding(padding: const EdgeInsets.all(4),
        child: Material(color: bg, borderRadius: BorderRadius.circular(14),
          child: Semantics(label: semantic, button: true, enabled: onTap != null,
            child: InkWell(
              borderRadius: BorderRadius.circular(14), onTap: onTap,
              child: Center(child: Text(label,
                style: AppTypography.keypadDigit.copyWith(color: fg)))))),
      ),
    ));
  }
}
