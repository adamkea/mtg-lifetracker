import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/mtg_color.dart';

/// A row of 5 tappable mana-symbol buttons for selecting commander colors.
///
/// Multiple colors can be selected simultaneously. Tapping a selected color
/// deselects it; tapping an unselected color adds it to the selection.
class ManaColorPicker extends StatelessWidget {
  final List<MtgColor> selected;
  final ValueChanged<List<MtgColor>> onChanged;

  const ManaColorPicker({
    required this.onChanged,
    this.selected = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MtgColor.values.map((color) {
        final isSelected = selected.contains(color);
        return GestureDetector(
          onTap: () {
            final updated = List<MtgColor>.from(selected);
            if (isSelected) {
              updated.remove(color);
            } else {
              updated.add(color);
            }
            onChanged(updated);
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
