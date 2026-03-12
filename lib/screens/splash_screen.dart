import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  late final AnimationController _exitController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleUp;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _scaleUp = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
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

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _exitController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_entranceController, _exitController]),
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
                      child: _buildLogoOrb(),
                    ),
                    const SizedBox(height: 32),
                    _buildManaRow(),
                    const SizedBox(height: 32),
                    Text(
                      'MTG Life Tracker',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'LIFE TRACKER',
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 6,
                        color: colorScheme.onSurface.withOpacity(0.45),
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

  Widget _buildLogoOrb() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF9B72D8), Color(0xFF533483)],
          stops: [0.2, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF533483).withOpacity(0.55),
            blurRadius: 36,
            spreadRadius: 6,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '♦',
          style: TextStyle(
            fontSize: 52,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.white38,
                blurRadius: 12,
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
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.circleColor,
              boxShadow: [
                BoxShadow(
                  color: color.circleColor.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: SvgPicture.asset(
                color.assetPath,
                colorFilter: ColorFilter.mode(
                  color.iconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
