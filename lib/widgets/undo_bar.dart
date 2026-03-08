import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';

/// A slim bar pinned at the bottom of the game screen that shows the most
/// recent action description and an UNDO button.
class UndoBar extends StatelessWidget {
  const UndoBar({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black87 : const Color(0xFFE2E2EF);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: 52,
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              gs.lastActionDescription,
              style: TextStyle(
                color: onSurface.withOpacity(0.54),
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            onPressed: gs.canUndo ? gs.undo : null,
            icon: Icon(
              Icons.undo,
              color: gs.canUndo
                  ? onSurface
                  : onSurface.withOpacity(0.3),
              size: 20,
            ),
            label: Text(
              'UNDO',
              style: TextStyle(
                color: gs.canUndo
                    ? onSurface
                    : onSurface.withOpacity(0.3),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
