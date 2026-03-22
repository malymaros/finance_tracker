import 'dart:math' show Random, pi, sin;

import 'package:flutter/services.dart';

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
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  // 3D perspective strength — keep small for a subtle, realistic effect.
  static const _perspective = 0.0012;
  // Maximum upward lift in logical pixels at the arc peak.
  static const _maxLift = 28.0;
  // Glow colors matching AppColors.income / AppColors.expense.
  static const _glowSuccess = Color(0xFF059669);
  static const _glowFailure = Color(0xFFDC2626);

  bool? _tossResult;   // null = no active result
  bool _glowActive = false;

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

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    // Linear — phase curves are computed manually in the builder so
    // each vapor layer can be shaped independently.
    _glowAnim = CurvedAnimation(
      parent: _glowController,
      curve: Curves.linear,
    );

    // When the flip animation completes, fire the glow.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _glowActive = true);
        _glowController.forward(from: 0.0).then((_) {
          if (mounted) {
            setState(() {
              _glowActive = false;
              _tossResult = null;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ── Vapor phase helpers ───────────────────────────────────────────────────

  // Returns a 0→1→0 envelope for the spread size.
  // Expansion uses easeOut (fast initial spread that slows to a creep);
  // recession uses easeIn (lingers, then gradually pulls away).
  static double _vaporPhase(double t) {
    if (t < 0.45) {
      final p = t / 0.45;
      return p * (2 - p); // easeOut
    } else if (t < 0.55) {
      return 1.0; // peak plateau
    } else {
      final p = (t - 0.55) / 0.45;
      return 1.0 - (p * p); // easeIn recede
    }
  }

  // Returns a 0→1→0 envelope for opacity, rising slightly faster than
  // spread so the color blooms with the expansion and fades last.
  static double _vaporAlpha(double t) {
    if (t < 0.35) {
      return t / 0.35;
    } else if (t < 0.60) {
      return 1.0;
    } else {
      return 1.0 - (t - 0.60) / 0.40;
    }
  }

  // Called by both tap (below) and swipe (from _WelcomeScreenState).
  void _toss() {
    if (_controller.isAnimating) return;
    _tossResult = Random().nextBool();
    _glowController.reset();
    setState(() => _glowActive = false);
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = (_tossResult == true) ? _glowSuccess : _glowFailure;

    return GestureDetector(
      onTap: _toss,
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // VAPOR LAYER — three concentric shadow rings, each slightly
            // time-lagged so the mist feels like it drifts outward organically.
            if (_glowActive)
              AnimatedBuilder(
                animation: _glowAnim,
                builder: (context, _) {
                  final t = _glowAnim.value;
                  // Each outer ring trails by ~0.07 s (scaled to 0–1 range).
                  final t2 = (t - 0.07).clamp(0.0, 1.0);
                  final t3 = (t - 0.14).clamp(0.0, 1.0);

                  // Phase and alpha for each ring.
                  final ph1 = _vaporPhase(t);
                  final ph2 = _vaporPhase(t2);
                  final ph3 = _vaporPhase(t3);
                  final al1 = _vaporAlpha(t);
                  final al2 = _vaporAlpha(t2);
                  final al3 = _vaporAlpha(t3);

                  return Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        // Inner core — tightest, most opaque.
                        BoxShadow(
                          color: glowColor
                              .withAlpha((al1 * 0.40 * 255).round()),
                          blurRadius: ph1 * 30,
                          spreadRadius: ph1 * 4,
                        ),
                        // Mid vapor — wider, translucent.
                        BoxShadow(
                          color: glowColor
                              .withAlpha((al2 * 0.25 * 255).round()),
                          blurRadius: ph2 * 64,
                          spreadRadius: ph2 * 10,
                        ),
                        // Outer wisp — barely visible, very diffuse.
                        BoxShadow(
                          color: glowColor
                              .withAlpha((al3 * 0.14 * 255).round()),
                          blurRadius: ph3 * 100,
                          spreadRadius: ph3 * 18,
                        ),
                      ],
                    ),
                  );
                },
              ),

            // COIN — the existing flip animation, unchanged.
            AnimatedBuilder(
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
                    child: Transform.scale(scale: scale, child: child),
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
          ],
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

class _GetStartedButtonState extends State<_GetStartedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Press-down is near-instant so even the quickest tap shows a clear snap.
      duration: const Duration(milliseconds: 40),
      // Release animates back smoothly, giving the spring-back feel.
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.75).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    _controller.value = 1.0; // instant snap — no animation needed on press-down
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse(); // animated spring-back
    Future.delayed(const Duration(milliseconds: 160), widget.onPressed);
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: Opacity(opacity: _opacity.value, child: child),
        ),
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
    );
  }
}
