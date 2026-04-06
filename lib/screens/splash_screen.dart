import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mtg_color.dart';
import 'setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _glowController;
  late final AnimationController _exitController;

  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleUp;
  late final Animation<double> _glowPulse;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = CurvedAnimation(parent: _entranceController, curve: Curves.easeIn);

    _scaleUp = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );

    _glowPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeOut),
    );

    _exitController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SetupScreen()),
        );
      }
    });

    _entranceController.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) _exitController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07070F) : const Color(0xFFF0F0F8),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _entranceController,
          _glowController,
          _exitController,
        ]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOut.value,
            child: Opacity(
              opacity: _fadeIn.value,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scaleUp,
                      child: _buildLogoOrb(colorScheme, isDark),
                    ),
                    const SizedBox(height: 36),
                    _buildManaRow(),
                    const SizedBox(height: 36),
                    // "MAGIC: THE GATHERING" label
                    Text(
                      'MAGIC: THE GATHERING',
                      style: GoogleFonts.chakraPetch(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 5,
                        color: colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Main title
                    Text(
                      'LIFE TRACKER',
                      style: GoogleFonts.russoOne(
                        fontSize: 32,
                        letterSpacing: 4,
                        color: colorScheme.onSurface,
                        shadows: isDark
                            ? [
                                Shadow(
                                  color: colorScheme.primary
                                      .withOpacity(0.8 * _glowPulse.value),
                                  blurRadius: 20,
                                ),
                                Shadow(
                                  color: colorScheme.primary
                                      .withOpacity(0.4 * _glowPulse.value),
                                  blurRadius: 50,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoOrb(ColorScheme colorScheme, bool isDark) {
    return AnimatedBuilder(
      animation: _glowPulse,
      builder: (context, child) {
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFA78BFA), Color(0xFF5B21B6), Color(0xFF2D1060)],
              stops: [0.0, 0.55, 1.0],
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: const Color(0xFF7C3AED)
                          .withOpacity(0.6 * _glowPulse.value),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: const Color(0xFF7C3AED)
                          .withOpacity(0.25 * _glowPulse.value),
                      blurRadius: 80,
                      spreadRadius: 16,
                    ),
                    BoxShadow(
                      color: const Color(0xFFA78BFA)
                          .withOpacity(0.15 * _glowPulse.value),
                      blurRadius: 120,
                      spreadRadius: 24,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF533483).withOpacity(0.4),
                      blurRadius: 36,
                      spreadRadius: 6,
                    ),
                  ],
          ),
          child: child,
        );
      },
      child: Center(
        child: Text(
          '♦',
          style: TextStyle(
            fontSize: 64,
            color: Colors.white,
            shadows: [
              const Shadow(color: Colors.white70, blurRadius: 8),
              Shadow(
                color: const Color(0xFFA78BFA).withOpacity(0.9),
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManaRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: MtgColor.values.map((color) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.circleColor,
              boxShadow: [
                BoxShadow(
                  color: color.circleColor.withOpacity(0.65),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                color.assetPath,
                colorFilter: ColorFilter.mode(color.iconColor, BlendMode.srcIn),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
