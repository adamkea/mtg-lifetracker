import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'models/game_state.dart';
import 'models/theme_notifier.dart';
import 'screens/splash_screen.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kNeonPurple = Color(0xFF7C3AED);
const _kNeonPurpleLight = Color(0xFFA78BFA);
const _kNeonRose = Color(0xFFF43F5E);
const _kNeonGreen = Color(0xFF10B981);

const _kBgOled = Color(0xFF07070F);
const _kBgSurface = Color(0xFF0D0D1C);
const _kBgCard = Color(0xFF111122);
const _kBgCardHigh = Color(0xFF161628);
const _kBgCardHighest = Color(0xFF1C1C35);
const _kOutline = Color(0xFF252540);
const _kOutlineVariant = Color(0xFF181830);

const _kTextPrimary = Color(0xFFE2E8F0);
const _kTextMuted = Color(0xFF64748B);

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const MtgLifeTrackerApp(),
    ),
  );
}

class MtgLifeTrackerApp extends StatelessWidget {
  const MtgLifeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeNotifier>().mode;
    return MaterialApp(
      title: 'MTG Life Tracker',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ColorScheme.fromSeed(
      seedColor: _kNeonPurple,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _kNeonPurple,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF3B1F7A),
      onPrimaryContainer: _kNeonPurpleLight,
      secondary: _kNeonPurpleLight,
      onSecondary: const Color(0xFF1A0A3D),
      secondaryContainer: const Color(0xFF1E1835),
      onSecondaryContainer: _kNeonPurpleLight,
      tertiary: _kNeonGreen,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFF0A2B1E),
      onTertiaryContainer: const Color(0xFF34D399),
      error: _kNeonRose,
      onError: Colors.white,
      errorContainer: const Color(0xFF2B0D14),
      onErrorContainer: const Color(0xFFFF6B81),
      surface: _kBgSurface,
      onSurface: _kTextPrimary,
      surfaceContainerLowest: _kBgOled,
      surfaceContainerLow: _kBgCard,
      surfaceContainer: _kBgCard,
      surfaceContainerHigh: _kBgCardHigh,
      surfaceContainerHighest: _kBgCardHighest,
      outline: _kOutline,
      outlineVariant: _kOutlineVariant,
    );

    return ThemeData(
      colorScheme: base,
      scaffoldBackgroundColor: _kBgOled,
      useMaterial3: true,
      textTheme: _buildTextTheme(base),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.chakraPetch(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _kBgCardHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kNeonPurple, width: 2),
        ),
        labelStyle: GoogleFonts.chakraPetch(color: _kTextMuted, fontSize: 14),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    const seedColor = Color(0xFF533483);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF0F0F8),
      useMaterial3: true,
      textTheme: _buildLightTextTheme(colorScheme),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.chakraPetch(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  TextTheme _buildTextTheme(ColorScheme cs) {
    // Life total: giant Russo One with neon purple glow
    final lifeStyle = GoogleFonts.russoOne(
      fontSize: 88,
      letterSpacing: -2,
      color: _kTextPrimary,
      shadows: [
        Shadow(color: _kNeonPurple.withOpacity(0.75), blurRadius: 24),
        Shadow(color: _kNeonPurple.withOpacity(0.35), blurRadius: 60),
      ],
    );

    return TextTheme(
      displayLarge: lifeStyle,
      headlineLarge: GoogleFonts.russoOne(
        fontSize: 30,
        letterSpacing: 1.5,
        color: _kTextPrimary,
      ),
      headlineMedium: GoogleFonts.russoOne(
        fontSize: 22,
        letterSpacing: 0.8,
        color: _kTextPrimary,
      ),
      titleLarge: GoogleFonts.chakraPetch(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _kTextPrimary,
      ),
      titleMedium: GoogleFonts.chakraPetch(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _kTextPrimary,
      ),
      titleSmall: GoogleFonts.chakraPetch(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: _kTextMuted,
      ),
      bodyLarge: GoogleFonts.chakraPetch(fontSize: 16, color: _kTextPrimary),
      bodyMedium: GoogleFonts.chakraPetch(fontSize: 14, color: _kTextMuted),
      labelLarge: GoogleFonts.chakraPetch(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: _kTextPrimary,
      ),
      labelMedium: GoogleFonts.chakraPetch(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: _kTextMuted,
      ),
    );
  }

  TextTheme _buildLightTextTheme(ColorScheme cs) {
    return TextTheme(
      displayLarge: GoogleFonts.russoOne(
        fontSize: 88,
        letterSpacing: -2,
        color: cs.onSurface,
      ),
      headlineLarge: GoogleFonts.russoOne(fontSize: 30, letterSpacing: 1),
      headlineMedium: GoogleFonts.russoOne(fontSize: 22, letterSpacing: 0.5),
      titleLarge: GoogleFonts.chakraPetch(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.chakraPetch(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      titleSmall: GoogleFonts.chakraPetch(fontSize: 13, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.chakraPetch(fontSize: 16),
      bodyMedium: GoogleFonts.chakraPetch(fontSize: 14),
      labelLarge: GoogleFonts.chakraPetch(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}
