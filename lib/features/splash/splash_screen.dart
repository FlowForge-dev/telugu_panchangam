import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../core/theme/app_spacing.dart';

/// Brand splash. Runs [AppState.bootstrap] while showing a calm,
/// centred emblem, then hands off to onboarding or the home shell.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween(begin: 0.92, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final appState = context.read<AppState>();
    final started = DateTime.now();
    await appState.bootstrap();
    final elapsed = DateTime.now().difference(started);
    const minSplash = Duration(milliseconds: 1100);
    if (elapsed < minSplash) {
      await Future.delayed(minSplash - elapsed);
    }
    if (!mounted) return;
    if (appState.hasSeenOnboarding) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _EmblemMark(),
                const SizedBox(height: AppSpacing.xl),
                Text('పంచాంగం', style: theme.textTheme.displayMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Telugu Panchangam & Jatakam',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A restrained geometric emblem (concentric rings + a centred dot,
/// echoing temple-kalasha geometry) instead of clip-art iconography.
class _EmblemMark extends StatelessWidget {
  const _EmblemMark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 88,
      height: 88,
      child: CustomPaint(
        painter: _EmblemPainter(primary: scheme.primary, secondary: scheme.secondary),
      ),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  _EmblemPainter({required this.primary, required this.secondary});
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final innerPaint = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    canvas.drawCircle(center, size.width / 2 - 4, outerPaint);
    canvas.drawCircle(center, size.width / 2 - 16, innerPaint);
    canvas.drawCircle(center, 5, Paint()..color = primary);

    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2;
      final start = Offset(
        center.dx + (size.width / 2 - 4) * math.cos(angle),
        center.dy + (size.width / 2 - 4) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (size.width / 2 + 4) * math.cos(angle),
        center.dy + (size.width / 2 + 4) * math.sin(angle),
      );
      canvas.drawLine(start, end, Paint()..color = primary.withValues(alpha: 0.5)..strokeWidth = 1.4);
    }
  }

  @override
  bool shouldRepaint(covariant _EmblemPainter oldDelegate) => false;
}
