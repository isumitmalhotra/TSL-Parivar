import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/design_system.dart';

/// Premium splash screen with TSL brand identity
///
/// Features:
/// - White and green gradient background
/// - TSL logo (green logo with black text) animated from top
/// - Tagline image in center
/// - Smooth shimmer particles
/// - Elegant transition to onboarding
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.onComplete,
    this.duration = const Duration(milliseconds: 4500),
  });

  /// Callback when splash animation completes
  final VoidCallback? onComplete;

  /// Duration to show splash (default 4.5 seconds)
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _textController;
  late AnimationController _shimmerController;
  late AnimationController _glowController;

  // Logo animations (comes from top)
  late Animation<double> _logoSlideY;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;

  // Tagline image animations (fade + scale in center)
  late Animation<double> _taglineOpacity;
  late Animation<double> _taglineScale;

  // Bottom indicator animations
  late Animation<double> _textOpacity;

  // Glow pulse
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
        const AssetImage('assets/images/tsl_logo_new.png'), context);
    precacheImage(
        const AssetImage('assets/images/tsl_tagline.png'), context);
  }

  void _setupAnimations() {
    // Logo controller - slides in from top
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Tagline image controller
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Bottom indicator controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Shimmer particles
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    // Glow pulse
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    // --- Logo: slide down from top + fade + scale ---
    _logoSlideY = Tween<double>(begin: -1.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    // --- Tagline image: fade + subtle scale ---
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _taglineController,
        curve: Curves.easeIn,
      ),
    );

    _taglineScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _taglineController,
        curve: Curves.easeOutCubic,
      ),
    );

    // --- Bottom indicator: fade in ---
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );
    // --- Glow pulse ---
    _glowPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _startAnimationSequence() async {
    // Immersive mode
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive));

    // Step 1: Logo slides in from top
    await Future<void>.delayed(const Duration(milliseconds: 300));
    unawaited(_logoController.forward());

    // Step 2: Tagline image fades in
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    unawaited(_taglineController.forward());

    // Step 3: Bottom indicator appears
    await Future<void>.delayed(const Duration(milliseconds: 700));
    unawaited(_textController.forward());

    // Wait for remaining duration then transition
    await Future<void>.delayed(
        widget.duration - const Duration(milliseconds: 2000));

    // Restore system UI
    unawaited(SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    ));

    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // White
              Color(0xFFF0FFF0), // Very light green
              Color(0xFFE8F5E9), // Light green
              Color(0xFFC8E6C9), // Soft green
              Color(0xFFA5D6A7), // Medium green
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Shimmer particles
            _buildShimmerParticles(),

            // Subtle radial glow
            _buildRadialGlow(),

            // Main content
            SafeArea(
              child: SizedBox.expand(
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo at the top, coming in with animation
                    _buildAnimatedLogo(),

                    const Spacer(),

                    // Tagline image in the center
                    _buildTaglineImage(),


                    const Spacer(),

                    // Bottom loading indicator
                    _buildBottomIndicator(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS
  // ============================================

  Widget _buildShimmerParticles() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return CustomPaint(
          painter: _GreenShimmerPainter(progress: _shimmerController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildRadialGlow() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 0.7 + _glowPulse.value * 0.1,
                colors: [
                  const Color(0xFF4CAF50)
                      .withValues(alpha: 0.05 + _glowPulse.value * 0.03),
                  const Color(0xFF4CAF50).withValues(alpha: 0.02),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _glowController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _logoSlideY.value * 100),
          child: Transform.scale(
            scale: _logoScale.value,
            child: Opacity(
              opacity: _logoOpacity.value,
              child: _buildLogoWidget(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoWidget() {
    return Image.asset(
      'assets/images/tsl_logo_new.png',
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackLogo();
      },
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'TSL',
            style: AppTypography.h1.copyWith(
              color: const Color(0xFF2E7D32),
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
            ),
          ),
          Container(
            width: 70,
            height: 2,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
          ),
          Text(
            'STEEL',
            style: AppTypography.caption.copyWith(
              color: const Color(0xFF1B5E20),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaglineImage() {
    return AnimatedBuilder(
      animation: _taglineController,
      builder: (context, child) {
        return Transform.scale(
          scale: _taglineScale.value,
          child: Opacity(
            opacity: _taglineOpacity.value,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Image.asset(
                'assets/images/tsl_tagline.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'TSL',
                    style: AppTypography.h1.copyWith(
                      color: const Color(0xFF2E7D32),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildBottomIndicator() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value * 0.7,
          child: Column(
            children: [
              _LoadingDots(controller: _shimmerController),
              const SizedBox(height: 12),
              Text(
                'Building the Future of Steel',
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================
// GREEN SHIMMER PAINTER
// ============================================

/// Subtle green-toned shimmer/sparkle particle painter
class _GreenShimmerPainter extends CustomPainter {
  _GreenShimmerPainter({required this.progress})
      : particles = List.generate(
          25,
          (index) => _Particle(
            x: (index * 41.0 % 100) / 100,
            y: (index * 67.0 % 100) / 100,
            size: 0.8 + (index % 4) * 0.5,
            speed: 0.12 + (index % 6) * 0.04,
            opacity: 0.04 + (index % 5) * 0.03,
          ),
        );

  final double progress;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final x = (particle.x * size.width +
              progress * particle.speed * size.width) %
          size.width;
      final y = (particle.y * size.height -
              progress * particle.speed * size.height * 0.3) %
          size.height;

      final twinkle =
          (math.sin(progress * math.pi * 2 + particle.x * 10) + 1) / 2;

      // Use green-tinted sparkles
      paint.color = const Color(0xFF4CAF50)
          .withValues(alpha: particle.opacity * twinkle);
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GreenShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
}

/// Animated loading dots with green theme
class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue = (controller.value + delay) % 1.0;
            final pulse = 0.4 + (math.sin(animValue * math.pi) * 0.6);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4CAF50)
                    .withValues(alpha: pulse * 0.6),
              ),
            );
          }),
        );
      },
    );
  }
}

