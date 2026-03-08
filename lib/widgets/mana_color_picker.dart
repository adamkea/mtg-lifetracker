import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/mtg_color.dart';

/// A row of 5 tappable mana-symbol buttons for selecting MTG colors.
///
/// Supports multi-selection: tap to toggle each color on/off.
/// Pass [selected] as the set of currently chosen colors and [onChanged]
/// to receive the updated set after each tap.
class ManaColorPicker extends StatelessWidget {
  final Set<MtgColor> selected;
  final ValueChanged<Set<MtgColor>> onChanged;

  const ManaColorPicker({
    required this.onChanged,
    Set<MtgColor>? selected,
    super.key,
  }) : selected = selected ?? const {};

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MtgColor.values.map((color) {
        final isSelected = selected.contains(color);
        return GestureDetector(
          onTap: () {
            final next = Set<MtgColor>.from(selected);
            if (isSelected) {
              next.remove(color);
            } else {
              next.add(color);
            }
            onChanged(next);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.circleColor,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2.5)
                  : Border.all(color: Colors.white24, width: 1),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.circleColor.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
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
