import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mama_pill/core/presentation/widgets/custom_button.dart';
import 'package:mama_pill/core/presentation/widgets/svg_image.dart';
import 'package:mama_pill/core/resources/assets.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/routes.dart';
import 'package:mama_pill/core/resources/strings.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'dart:math' as math;

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  AnimationController? _borderController;
  AnimationController? _particleController;

  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _borderRotation;
  Animation<double>? _particleOpacity;

  final List<Particle> _particles = [];
  final int _particleCount = 20;

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _borderController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.elasticOut),
    );

    _borderRotation = Tween<double>(begin: 0.0, end: math.pi * 2).animate(
      CurvedAnimation(parent: _borderController!, curve: Curves.linear),
    );

    _particleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController!, curve: Curves.easeInOut),
    );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _borderController?.dispose();
    _particleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_animationController == null ||
        _borderController == null ||
        _particleController == null ||
        _fadeAnimation == null ||
        _slideAnimation == null ||
        _scaleAnimation == null ||
        _borderRotation == null ||
        _particleOpacity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.3),
              AppColors.backgroundSecondary,
            ],
            stops: const [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: 36, horizontal: 14).w,
          child: FadeTransition(
            opacity: _fadeAnimation!,
            child: SlideTransition(
              position: _slideAnimation!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation!,
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
                                      AppColors.primary.withOpacity(0.9),
                                      AppColors.accent.withOpacity(0.9),
                                      AppColors.primary.withOpacity(0.9),
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
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 40,
                                spreadRadius: 15,
                              ),
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.3),
                                blurRadius: 50,
                                spreadRadius: -5,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Container(
                              color: AppColors.white.withOpacity(0.98),
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
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          AppStrings.welcomeTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: AppColors.primary.withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppHeight.h8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          AppStrings.welcomeDescription,
                          textAlign: TextAlign.center,
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 17.sp,
                            height: 1.4,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    child: _authButtonRow(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _authButtonRow(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(30.r),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.15),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: CustomButton(
            label: 'Create Account',
            onTap: () => context.pushNamed(AppRoutes.register.name),
            backgroundColor: AppColors.primary,
            textColor: AppColors.white,
            margin: EdgeInsets.zero,
          ),
        ),
        Expanded(
          child: CustomButton(
            label: AppStrings.login,
            onTap: () => context.pushNamed(AppRoutes.login.name),
            backgroundColor: AppColors.white,
            textColor: AppColors.primary,
            margin: EdgeInsets.zero,
          ),
        ),
      ],
    ),
  );
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

  ParticlePainter({required this.particles, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.primary.withOpacity(0.3 * opacity)
          ..style = PaintingStyle.fill;

    for (var particle in particles) {
      canvas.drawCircle(
        Offset(size.width / 2 + particle.x, size.height / 2 + particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
