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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainer,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  gs.lastActionDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: gs.canUndo ? gs.undo : null,
                icon: const Icon(Icons.undo, size: 20),
                label: const Text(
                  'UNDO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
