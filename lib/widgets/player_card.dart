import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/mtg_color.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import 'life_control_button.dart';
import 'mana_color_picker.dart';
import 'player_name_dialog.dart';

/// Displays one player's panel: name, life total, and life-change controls.
///
/// The life total is rendered very large so it's readable from across a table.
/// Tapping the player name opens the rename dialog.
/// Tapping the palette icon opens a color picker to edit commander colors mid-game.
class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({required this.player, super.key});

  void _showColorPicker(BuildContext context) {
    final gs = context.read<GameState>();
    List<MtgColor> current = List.from(player.colors);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2A4A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${player.name} — Commander Colors',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  ManaColorPicker(
                    selected: current,
                    onChanged: (colors) {
                      gs.setPlayerColors(player.id, colors);
                      setSheetState(() => current = colors);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final canRemove = gs.players.length > 1;

    const baseColor = Color(0xFF16213E);
    Color cardColor = baseColor;
    for (final c in player.colors) {
      cardColor = Color.alphaBlend(c.cardTint, cardColor);
    }

    return Card(
      margin: const EdgeInsets.all(4),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header row: player name + color dots + icons ──────────────
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
                // Small mana symbol dots
                if (player.colors.isNotEmpty) ...[
                  ...player.colors.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.circleColor,
                            border: Border.all(color: Colors.white30, width: 0.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: SvgPicture.asset(
                              c.assetPath,
                              colorFilter: ColorFilter.mode(
                                  c.iconColor, BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                // Palette button to edit colors
                GestureDetector(
                  onTap: () => _showColorPicker(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.palette, size: 18, color: Colors.white38),
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
