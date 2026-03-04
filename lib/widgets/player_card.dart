import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/player.dart';
import '../models/game_state.dart';
import 'life_control_button.dart';
import 'player_name_dialog.dart';

/// Displays one player's panel: name, life total, and life-change controls.
///
/// The life total is rendered very large so it's readable from across a table.
/// Double-tapping the player name opens the rename dialog.
class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({required this.player, super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final canRemove = gs.players.length > 1;

    return Card(
      margin: const EdgeInsets.all(4),
      color: const Color(0xFF16213E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header row: player name + remove button ───────────────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => showPlayerNameDialog(context, player),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              player.name,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, size: 14, color: Colors.white38),
                        ],
                      ),
                    ),
                  ),
                ),
                if (canRemove)
                  GestureDetector(
                    onTap: () =>
                        context.read<GameState>().removePlayer(player.id),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 18, color: Colors.white38),
                    ),
                  ),
              ],
            ),

            // ── Life total (large, centred) ────────────────────────────────
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${player.lifeTotal}',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
            ),

            // ── Control buttons row ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                LifeControlButton(playerId: player.id, delta: -5),
                LifeControlButton(playerId: player.id, delta: -1),
                LifeControlButton(playerId: player.id, delta: 1),
                LifeControlButton(playerId: player.id, delta: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
