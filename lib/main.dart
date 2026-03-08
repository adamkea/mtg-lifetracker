import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/game_state.dart';
import 'models/theme_notifier.dart';
import 'screens/setup_screen.dart';

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
      home: const SetupScreen(),
    );
  }

  ThemeData _buildDarkTheme() {
    const seedColor = Color(0xFF533483);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      cardColor: const Color(0xFF16213E),
      useMaterial3: true,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 80,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -2,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          color: Colors.white70,
          letterSpacing: 0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E2A4A),
        selectedColor: seedColor,
        labelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E2A4A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: seedColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white60),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    const seedColor = Color(0xFF533483);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F0F8),
      cardColor: const Color(0xFFFFFFFF),
      useMaterial3: true,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 80,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
          letterSpacing: -2,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          color: Color(0xFF44445A),
          letterSpacing: 0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE8EAF6),
        selectedColor: seedColor,
        labelStyle: const TextStyle(color: Color(0xFF1A1A2E)),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8EAF6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: seedColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF44445A)),
        hintStyle: const TextStyle(color: Color(0xFF888899)),
      ),
    );
  }
}
