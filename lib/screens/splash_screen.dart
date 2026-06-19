import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/logo_mark.dart';

/// Cinematic cold-start splash in the RhinoForgeCreations house style
/// (matches the MacroSync intro): glow bloom, logo slam, shockwaves,
/// letter-by-letter wordmark, and a shimmering progress bar.
///
/// Purely visual. Calls [onComplete] once when the sequence finishes (or
/// immediately if the user taps to skip). Tap anywhere to skip.
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowBloomCtrl;
  late final Animation<double> _glowBloomRadius;
  late final Animation<double> _glowBloomOpacity;

  late final AnimationController _glowBreatheCtrl;
  late final Animation<double> _glowBreatheScale;

  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  late final AnimationController _shockCtrl;
  late final Animation<double> _shockScale;
  late final Animation<double> _shockOpacity;

  late final AnimationController _shock2Ctrl;
  late final Animation<double> _shock2Scale;
  late final Animation<double> _shock2Opacity;

  late final AnimationController _haloCtrl;
  late final Animation<double> _haloOpacity;

  late final AnimationController _lettersCtrl;
  late final AnimationController _subtitleCtrl;
  late final AnimationController _progressCtrl;
  late final Animation<double> _progress;

  static const _word = 'PICK TRACKER';
  bool _done = false;

  @override
  void initState() {
    super.initState();

    _glowBloomCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _glowBloomRadius = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 80.0, end: 480.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 480.0, end: 300.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _glowBloomCtrl, curve: Curves.easeOut));
    _glowBloomOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.22), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.22, end: 0.10), weight: 70),
    ]).animate(CurvedAnimation(parent: _glowBloomCtrl, curve: Curves.easeOut));

    _glowBreatheCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    _glowBreatheScale = Tween<double>(begin: 0.88, end: 1.12).animate(
        CurvedAnimation(parent: _glowBreatheCtrl, curve: Curves.easeInOut));

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.18)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 70),
      TweenSequenceItem(
          tween: Tween(begin: 1.18, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 30),
    ]).animate(_logoCtrl);
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut)));

    _shockCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _shockScale = Tween<double>(begin: 1.0, end: 3.8)
        .animate(CurvedAnimation(parent: _shockCtrl, curve: Curves.easeOut));
    _shockOpacity = Tween<double>(begin: 0.9, end: 0.0)
        .animate(CurvedAnimation(parent: _shockCtrl, curve: Curves.easeIn));

    _shock2Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _shock2Scale = Tween<double>(begin: 1.0, end: 2.8)
        .animate(CurvedAnimation(parent: _shock2Ctrl, curve: Curves.easeOut));
    _shock2Opacity = Tween<double>(begin: 0.6, end: 0.0)
        .animate(CurvedAnimation(parent: _shock2Ctrl, curve: Curves.easeIn));

    _haloCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _haloOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _haloCtrl, curve: Curves.easeOut));

    _lettersCtrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 70 * _word.length + 300));

    _subtitleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _progress = CurvedAnimation(
        parent: _progressCtrl, curve: Curves.easeInOutCubic);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _glowBloomCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _shockCtrl.forward();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _shock2Ctrl.forward();
    });
    _haloCtrl.forward();
    _glowBloomCtrl.stop();
    _glowBreatheCtrl.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _lettersCtrl.forward();
    _progressCtrl.forward();

    await Future.delayed(Duration(milliseconds: 70 * _word.length + 100));
    if (!mounted) return;
    _subtitleCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    _finish();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _glowBloomCtrl.dispose();
    _glowBreatheCtrl.dispose();
    _logoCtrl.dispose();
    _shockCtrl.dispose();
    _shock2Ctrl.dispose();
    _haloCtrl.dispose();
    _lettersCtrl.dispose();
    _subtitleCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _finish,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.surfaceBottom,
        body: Stack(
          children: [
            // Background glow
            AnimatedBuilder(
              animation:
                  Listenable.merge([_glowBloomCtrl, _glowBreatheCtrl]),
              builder: (context, _) {
                final bloomed = !_glowBloomCtrl.isAnimating &&
                    _glowBloomCtrl.value > 0;
                final radius = bloomed
                    ? _glowBloomRadius.value * _glowBreatheScale.value
                    : _glowBloomRadius.value;
                final opacity = bloomed
                    ? 0.10 * _glowBreatheScale.value
                    : _glowBloomOpacity.value;
                return Center(
                  child: Container(
                    width: radius,
                    height: radius,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppColors.accent.withValues(alpha: opacity),
                        AppColors.accent.withValues(alpha: opacity * 0.3),
                        Colors.transparent,
                      ], stops: const [0.0, 0.5, 1.0]),
                    ),
                  ),
                );
              },
            ),

            ...List.generate(10, (i) => _FloatingParticle(index: i)),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_logoCtrl, _shockCtrl, _shock2Ctrl, _haloCtrl]),
                    builder: (context, _) {
                      final logoAlpha = _logoOpacity.value;
                      return Transform.scale(
                        scale: _logoCtrl.value == 0 ? 0 : _logoScale.value,
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.scale(
                                scale: _shockScale.value,
                                child: Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.accent.withValues(
                                            alpha: _shockOpacity.value),
                                        width: 2),
                                  ),
                                ),
                              ),
                              Transform.scale(
                                scale: _shock2Scale.value,
                                child: Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.accentLight
                                            .withValues(
                                                alpha: _shock2Opacity.value),
                                        width: 1.5),
                                  ),
                                ),
                              ),
                              Container(
                                width: 108,
                                height: 108,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: AppColors.accent.withValues(
                                            alpha: 0.45 * _haloOpacity.value),
                                        blurRadius: 40,
                                        spreadRadius: 12),
                                  ],
                                ),
                              ),
                              // Amber tile + dark glyph (matches app icon)
                              Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.accentLight
                                          .withValues(alpha: logoAlpha),
                                      AppColors.accent
                                          .withValues(alpha: logoAlpha),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                        color: AppColors.accent.withValues(
                                            alpha: 0.5 * logoAlpha),
                                        blurRadius: 48,
                                        offset: const Offset(0, 10)),
                                  ],
                                ),
                                child: Opacity(
                                  opacity: logoAlpha,
                                  child: LogoMark(
                                      size: 104,
                                      color: AppColors.surfaceBottom),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Letter-by-letter wordmark
                  AnimatedBuilder(
                    animation: _lettersCtrl,
                    builder: (context, _) {
                      final total = _lettersCtrl.duration!.inMilliseconds;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_word.length, (i) {
                          final start = (i * 70) / total;
                          final end = start + 300 / total;
                          final t = ((_lettersCtrl.value - start) /
                                  (end - start))
                              .clamp(0.0, 1.0);
                          final curved = Curves.easeOutCubic.transform(t);
                          return Transform.translate(
                            offset: Offset(0, 16 * (1 - curved)),
                            child: Opacity(
                              opacity: curved,
                              child: Text(
                                _word[i],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                  fontSize: 26,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  FadeTransition(
                    opacity: _subtitleCtrl,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.5), end: Offset.zero)
                          .animate(CurvedAnimation(
                              parent: _subtitleCtrl,
                              curve: Curves.easeOutCubic)),
                      child: Text(
                        'by RhinoForgeCreations',
                        style: AppTypography.statLabel
                            .copyWith(letterSpacing: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 56),

                  _GlowProgressBar(progress: _progress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingParticle extends StatefulWidget {
  final int index;
  const _FloatingParticle({required this.index});
  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final double _x, _y, _radius, _maxOpacity;
  late final Color _color;

  @override
  void initState() {
    super.initState();
    final rng = Random(widget.index * 137 + 42);
    _x = -120 + rng.nextDouble() * 240;
    _y = -100 + rng.nextDouble() * 160;
    _radius = 1.5 + rng.nextDouble() * 3.5;
    _color = widget.index % 4 == 0 ? AppColors.accentLight : AppColors.accent;
    _maxOpacity = 0.2 + rng.nextDouble() * 0.4;
    _ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 2800 + rng.nextInt(1800)));
    Future.delayed(
        Duration(milliseconds: widget.index * 280 + rng.nextInt(300)), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cx = size.width / 2;
    final cy = size.height / 2;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final dy = -60.0 * t;
        double opacity;
        if (t < 0.15) {
          opacity = (t / 0.15) * _maxOpacity;
        } else if (t > 0.65) {
          opacity = ((1.0 - t) / 0.35) * _maxOpacity;
        } else {
          opacity = _maxOpacity;
        }
        return Positioned(
          left: cx + _x - _radius,
          top: cy + _y + dy - _radius,
          child: Container(
            width: _radius * 2,
            height: _radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _color.withValues(alpha: opacity),
              boxShadow: [
                BoxShadow(
                    color: _color.withValues(alpha: opacity * 0.6),
                    blurRadius: _radius * 3),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlowProgressBar extends StatefulWidget {
  final Animation<double> progress;
  const _GlowProgressBar({required this.progress});
  @override
  State<_GlowProgressBar> createState() => _GlowProgressBarState();
}

class _GlowProgressBarState extends State<_GlowProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.progress, _shimmerCtrl]),
      builder: (context, _) => SizedBox(
        width: 180,
        height: 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Stack(
            children: [
              Container(color: AppColors.cardBg),
              FractionallySizedBox(
                widthFactor: widget.progress.value,
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    final s = -0.3 + _shimmerCtrl.value * 1.6;
                    return LinearGradient(
                      colors: [
                        AppColors.accent,
                        AppColors.accent,
                        AppColors.accentLight,
                        AppColors.accent,
                        AppColors.accent,
                      ],
                      stops: [
                        0.0,
                        (s - 0.08).clamp(0.0, 1.0),
                        s.clamp(0.0, 1.0),
                        (s + 0.08).clamp(0.0, 1.0),
                        1.0,
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: 500.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
