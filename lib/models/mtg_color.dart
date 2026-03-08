import 'package:flutter/material.dart';

enum MtgColor {
  white,
  blue,
  black,
  red,
  green;

  String get assetPath => 'assets/icons/mana/${_svgFilename}.svg';

  String get _svgFilename {
    switch (this) {
      case MtgColor.white:
        return 'w';
      case MtgColor.blue:
        return 'u';
      case MtgColor.black:
        return 'b';
      case MtgColor.red:
        return 'r';
      case MtgColor.green:
        return 'g';
    }
  }

  /// Background circle color matching the standard MTG mana symbol palette.
  Color get circleColor {
    switch (this) {
      case MtgColor.white:
        return const Color(0xFFF9FAF4);
      case MtgColor.blue:
        return const Color(0xFF0E68AB);
      case MtgColor.black:
        return const Color(0xFF2D2D2D);
      case MtgColor.red:
        return const Color(0xFFD3202A);
      case MtgColor.green:
        return const Color(0xFF00733E);
    }
  }

  /// Icon tint: dark for light backgrounds (white), white for dark backgrounds.
  Color get iconColor {
    switch (this) {
      case MtgColor.white:
        return const Color(0xFF5C4A1E);
      default:
        return Colors.white;
    }
  }

  /// Subtle card tint used on PlayerCard backgrounds.
  Color get cardTint {
    return circleColor.withOpacity(0.12);
  }

  String get label {
    switch (this) {
      case MtgColor.white:
        return 'White';
      case MtgColor.blue:
        return 'Blue';
      case MtgColor.black:
        return 'Black';
      case MtgColor.red:
        return 'Red';
      case MtgColor.green:
        return 'Green';
    }
  }

  static MtgColor? fromString(String? value) {
    if (value == null) return null;
    return MtgColor.values.where((c) => c.name == value).firstOrNull;
  }
}
