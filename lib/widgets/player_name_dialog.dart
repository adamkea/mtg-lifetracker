import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/player.dart';
import '../models/game_state.dart';

/// Shows a dialog allowing the user to rename [player].
Future<void> showPlayerNameDialog(
  BuildContext context,
  Player player,
) async {
  final gameState = context.read<GameState>();
  final controller = TextEditingController(text: player.name);
  final newName = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Rename Player'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          hintText: 'Player name',
        ),
        onSubmitted: (v) => Navigator.pop(dialogContext, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (newName != null && newName.trim().isNotEmpty) {
    gameState.renamePlayer(player.id, newName);
  }
}
