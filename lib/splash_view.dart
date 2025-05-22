import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mama_pill/core/presentation/widgets/svg_image.dart';
import 'package:mama_pill/core/resources/assets.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/routes.dart';
import 'package:mama_pill/core/resources/strings.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'dart:math' as math;

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  AnimationController? _logoController;
  AnimationController? _buttonController;
  AnimationController? _backgroundController;
  AnimationController? _borderController;
  AnimationController? _particleController;

  Animation<double>? _logoScale;
  Animation<double>? _logoOpacity;
  Animation<double>? _logoRotation;
  Animation<double>? _buttonScale;
  Animation<double>? _buttonOpacity;
  Animation<double>? _backgroundOpacity;
  Animation<double>? _borderRotation;
  Animation<double>? _particleOpacity;

  final List<Particle> _particles = [];
  final int _particleCount = 10; // Reduced from 20 for better performance

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _initializeAnimations();
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble() * 400 - 200,
          y: random.nextDouble() * 400 - 200,
          size: random.nextDouble() * 4 + 2,
          speed: random.nextDouble() * 2 + 1,
          angle: random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  void _initializeAnimations() {
    // Initialize controllers with shorter durations for faster animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800), // Reduced from 2500ms
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500), // Reduced from 1500ms
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 800), // Reduced from 2500ms
      vsync: this,
    );

    _borderController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Reduced from 4000ms
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Reduced from 4000ms
      vsync: this,
    )..repeat();

    // Initialize animations with faster curves
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController!,
        // Replace elasticOut with faster fastOutSlowIn
        curve: Curves.fastOutSlowIn,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController!,
        // Faster opacity transition
        curve: const Interval(0.0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController!,
        // Replace elasticOut with faster easeOut
        curve: Curves.easeOut,
      ),
    );

    _buttonScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController!,
        // Replace elasticOut with faster fastOutSlowIn
        curve: Curves.fastOutSlowIn,
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController!,
        // Faster opacity transition
        curve: const Interval(0.0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );

    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController!,
        // Faster background transition
        curve: Curves.fastLinearToSlowEaseIn,
      ),
    );

    _borderRotation = Tween<double>(begin: 0.0, end: math.pi * 2).animate(
      CurvedAnimation(
        parent: _borderController!,
        // Keep linear for smooth rotation but the duration is already reduced
        curve: Curves.linear,
      ),
    );

    _particleOpacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _particleController!,
        // Faster opacity transition
        curve: Curves.fastOutSlowIn,
      ),
    );

    // Start animations in sequence
    _backgroundController!.forward();
    _logoController!.forward().then((_) {
      _buttonController!.forward();
    });
  }

  @override
  void dispose() {
    _logoController?.dispose();
    _buttonController?.dispose();
    _backgroundController?.dispose();
    _borderController?.dispose();
    _particleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_logoController == null ||
        _buttonController == null ||
        _backgroundController == null ||
        _borderController == null ||
        _particleController == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: AnimatedBuilder(
        animation: _backgroundController!,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary
                      .withOpacity(0.35 * _backgroundOpacity!.value),
                  AppColors.backgroundSecondary,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Welcome SVG with enhanced animations
                    AnimatedBuilder(
                      animation: _logoController!,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale!.value,
                          child: Transform.rotate(
                            angle: _logoRotation!.value,
                            child: Opacity(
                              opacity: _logoOpacity!.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Animated border
                                  AnimatedBuilder(
                                    animation: _borderController!,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _borderRotation!.value,
                                        child: Container(
                                          width: 340.w,
                                          height: 340.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: SweepGradient(
                                              colors: [
                                                AppColors.primary
                                                    .withOpacity(0.9),
                                                AppColors.accent
                                                    .withOpacity(0.9),
                                                AppColors.primary
                                                    .withOpacity(0.9),
                                              ],
                                              stops: const [0.0, 0.5, 1.0],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Particles
                                  AnimatedBuilder(
                                    animation: _particleController!,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        size: Size(340.w, 340.w),
                                        painter: ParticlePainter(
                                          particles: _particles,
                                          opacity: _particleOpacity!.value,
                                        ),
                                      );
                                    },
                                  ),
                                  // Main container
                                  Container(
                                    width: 320.w,
                                    height: 320.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withOpacity(0.98),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.4),
                                          blurRadius: 40,
                                          spreadRadius: 15,
                                        ),
                                        BoxShadow(
                                          color:
                                              AppColors.accent.withOpacity(0.3),
                                          blurRadius: 50,
                                          spreadRadius: -5,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Container(
                                        color:
                                            AppColors.white.withOpacity(0.98),
                                        child: SvgImage(
                                          assetName: AppAssets.welcome,
                                          width: 320.w,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 80.h),
                    // Enhanced animated start button
                    _getStartedButton(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getStartedButton(BuildContext context) {
    return ScaleTransition(
      scale: _buttonScale!,
      child: FadeTransition(
        opacity: _buttonOpacity!,
        child: GestureDetector(
          onTapDown: (_) {
            _buttonController?.forward();
          },
          onTapUp: (_) {
            _buttonController?.reverse();
          },
          onTapCancel: () {
            _buttonController?.reverse();
          },
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 1.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30.r),
                      onTap: () {
                        Future.delayed(const Duration(milliseconds: 150), () {
                          context.goNamed(AppRoutes.welcome.name);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppWidth.w32.w,
                          vertical: AppHeight.h16.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.getStarted,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.white,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double angle;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double opacity;

  ParticlePainter({
    required this.particles,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.3 * opacity)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      canvas.drawCircle(
        Offset(
          size.width / 2 + particle.x,
          size.height / 2 + particle.y,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
