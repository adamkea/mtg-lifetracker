import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/player.dart';
import '../models/game_state.dart';

/// Shows a dialog allowing the user to rename [player].
Future<void> showPlayerNameDialog(
  BuildContext context,
  Player player,
) async {
  final controller = TextEditingController(text: player.name);
  final newName = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      title: const Text(
        'Rename Player',
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(color: Colors.white),
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
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (newName != null && newName.trim().isNotEmpty && context.mounted) {
    context.read<GameState>().renamePlayer(player.id, newName);
  }
}
