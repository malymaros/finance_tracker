import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';

// ── WelcomeScreen ─────────────────────────────────────────────────────────────

class WelcomeScreen extends StatefulWidget {
  final Widget Function() mainScreenBuilder;

  const WelcomeScreen({super.key, required this.mainScreenBuilder});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _coinKey = GlobalKey<_TossableCoinState>();

  // Minimum upward velocity (dp/s) to trigger the toss.
  // Negative = upward in Flutter's coordinate system.
  static const _swipeVelocityThreshold = 400.0;

  void _onGetStarted(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.mainScreenBuilder()),
    );
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -_swipeVelocityThreshold) {
      _coinKey.currentState?._toss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // translucent: drag events are detected but child taps still work.
        behavior: HitTestBehavior.translucent,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.4,
              colors: [
                Color(0xFF0D1B4B),
                Color(0xFF080D24),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _TossableCoin(key: _coinKey),
                  const SizedBox(height: 20),
                  const Text(
                    'Finance Tracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Take control of your money',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withAlpha(140),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(flex: 3),
                  _GetStartedButton(onPressed: () => _onGetStarted(context)),
                  const SizedBox(height: 20),
                  const Text(
                    'Version 0.1.0',
                    style: TextStyle(
                      color: Color(0xFF3D5480),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tossable coin icon ────────────────────────────────────────────────────────

class _TossableCoin extends StatefulWidget {
  const _TossableCoin({super.key});

  @override
  State<_TossableCoin> createState() => _TossableCoinState();
}

class _TossableCoinState extends State<_TossableCoin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  // 3D perspective strength — keep small for a subtle, realistic effect.
  static const _perspective = 0.0012;
  // Maximum upward lift in logical pixels at the arc peak.
  static const _maxLift = 28.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _anim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Called by both tap (below) and swipe (from _WelcomeScreenState).
  void _toss() {
    if (_controller.isAnimating) return;
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toss,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final t = _anim.value; // 0.0 → 1.0

          // Two full X-axis rotations (0 → 4π).
          // Ends exactly at 0 mod 2π so the coin lands in its original
          // orientation with no visual jump.
          final angle = 4 * pi * t;

          // Smooth vertical arc: 0 at start, peaks at t = 0.5, 0 at end.
          final lift = -_maxLift * sin(t * pi);

          // Subtle scale swell — the coin feels closer at the apex.
          final scale = 1.0 + 0.05 * sin(t * pi);

          return Transform.translate(
            offset: Offset(0, lift),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(angle),
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            ),
          );
        },
        // child is built once and reused across every animation frame.
        child: Image.asset(
          'assets/icons/app_icon.png',
          width: 180,
          height: 180,
        ),
      ),
    );
  }
}

// ── Pressable button with scale + opacity feedback ────────────────────────────

class _GetStartedButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _GetStartedButton({required this.onPressed});

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.82 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(27),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Get Started',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
