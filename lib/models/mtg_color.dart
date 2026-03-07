import 'package:flutter/material.dart';

/// The five colours of Magic: The Gathering mana.
enum MtgColor {
  white,
  blue,
  black,
  red,
  green;

  /// Traditional single-letter abbreviation shown on the pip.
  String get symbol {
    switch (this) {
      case white: return 'W';
      case blue:  return 'U';
      case black: return 'B';
      case red:   return 'R';
      case green: return 'G';
    }
  }

  String get label {
    switch (this) {
      case white: return 'White';
      case blue:  return 'Blue';
      case black: return 'Black';
      case red:   return 'Red';
      case green: return 'Green';
    }
  }

  /// Bright colour used for the pip circle indicator.
  Color get pipColor {
    switch (this) {
      case white: return const Color(0xFFF0E6C0);
      case blue:  return const Color(0xFF4A90D9);
      case black: return const Color(0xFF5A5A5A);
      case red:   return const Color(0xFFD9382A);
      case green: return const Color(0xFF2E9E4F);
    }
  }

  /// Text/icon colour drawn on top of the pip.
  Color get pipTextColor {
    switch (this) {
      case white: return const Color(0xFF2A2418);
      case blue:  return Colors.white;
      case black: return Colors.white;
      case red:   return Colors.white;
      case green: return Colors.white;
    }
  }

  /// Dark background tint applied to the card surface.
  Color get cardBackground {
    switch (this) {
      case white: return const Color(0xFF38321E);
      case blue:  return const Color(0xFF0B2640);
      case black: return const Color(0xFF1A1A1A);
      case red:   return const Color(0xFF3A0E0E);
      case green: return const Color(0xFF0B2C18);
    }
  }
}

/// Derives a card background [BoxDecoration] from a list of selected colours.
/// Falls back to a neutral grey when [colors] is empty.
BoxDecoration cardDecoration(List<MtgColor> colors, BorderRadius borderRadius) {
  const grey = Color(0xFF2A2A2A);

  if (colors.isEmpty) {
    return BoxDecoration(color: grey, borderRadius: borderRadius);
  }
  if (colors.length == 1) {
    return BoxDecoration(color: colors.first.cardBackground, borderRadius: borderRadius);
  }

  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors.map((c) => c.cardBackground).toList(),
    ),
    borderRadius: borderRadius,
  );
}
