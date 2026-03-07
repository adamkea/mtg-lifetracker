import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mtg_color.dart';
import '../models/player.dart';
import '../models/game_state.dart';

/// Opens a dialog where the player can select any subset of the five MTG colours.
Future<void> showColorPickerDialog(BuildContext context, Player player) async {
  final result = await showDialog<List<MtgColor>>(
    context: context,
    builder: (_) => _ColorPickerDialog(initial: player.colors),
  );

  if (result != null && context.mounted) {
    context.read<GameState>().setPlayerColors(player.id, result);
  }
}

class _ColorPickerDialog extends StatefulWidget {
  final List<MtgColor> initial;

  const _ColorPickerDialog({required this.initial});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late final Set<MtgColor> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.of(widget.initial);
  }

  void _toggle(MtgColor color) {
    setState(() {
      if (_selected.contains(color)) {
        _selected.remove(color);
      } else {
        _selected.add(color);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2E),
      title: const Text('Choose Colors', style: TextStyle(color: Colors.white)),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: MtgColor.values.map((color) {
          final selected = _selected.contains(color);
          return GestureDetector(
            onTap: () => _toggle(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.pipColor,
                border: Border.all(
                  color: selected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: color.pipColor.withValues(alpha: 0.6), blurRadius: 8)]
                    : null,
              ),
              child: Center(
                child: selected
                    ? Icon(Icons.check, color: color.pipTextColor, size: 22)
                    : Text(
                        color.symbol,
                        style: TextStyle(
                          color: color.pipTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selected.toList()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
