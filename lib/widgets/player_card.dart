import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mtg_color.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import 'color_picker_dialog.dart';
import 'life_control_button.dart';
import 'player_name_dialog.dart';

/// Displays one player's panel: name, life total, and life-change controls.
///
/// The life total is rendered very large so it's readable from across a table.
/// Tapping the player name opens the rename dialog.
/// Tapping the palette icon opens the colour picker.
class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({required this.player, super.key});

  static const _borderRadius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final canRemove = gs.players.length > 1;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        borderRadius: _borderRadius,
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Ink(
          decoration: cardDecoration(player.colors, _borderRadius),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header row: name / colour pips / palette / remove ─────────
                Row(
                  children: [
                    // Player name tap target
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

                    // Colour pips
                    if (player.colors.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      _ColorPips(colors: player.colors),
                      const SizedBox(width: 2),
                    ],

                    // Palette icon — opens colour picker
                    GestureDetector(
                      onTap: () => showColorPickerDialog(context, player),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.palette,
                          size: 18,
                          color: player.colors.isEmpty ? Colors.white38 : Colors.white70,
                        ),
                      ),
                    ),

                    if (canRemove)
                      GestureDetector(
                        onTap: () => context.read<GameState>().removePlayer(player.id),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 18, color: Colors.white38),
                        ),
                      ),
                  ],
                ),

                // ── Life total (large, centred) ──────────────────────────────
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

                // ── Control buttons row ──────────────────────────────────────
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
        ),
      ),
    );
  }
}

/// Row of small coloured pip circles indicating selected MTG colours.
class _ColorPips extends StatelessWidget {
  final List<MtgColor> colors;

  const _ColorPips({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors.map((c) {
        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.pipColor,
            border: Border.all(color: Colors.white24, width: 0.5),
          ),
        );
      }).toList(),
    );
  }
}
