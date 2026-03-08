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
/// Double-tapping the player name opens the rename dialog.
class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({required this.player, super.key});

  Color _cardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF16213E)
        : const Color(0xFFFFFFFF);
    if (player.colors.isEmpty) return baseColor;
    // Blend each color's tint on top of the base sequentially.
    var result = baseColor;
    for (final c in player.colors) {
      result = Color.alphaBlend(c.cardTint, result);
    }
    return result;
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return _ColorPickerSheet(player: player);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final canRemove = gs.players.length > 1;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final subtleColor = onSurface.withOpacity(0.38);

    return Card(
      margin: const EdgeInsets.all(4),
      color: _cardColor(context),
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
                          Icon(Icons.edit, size: 14, color: subtleColor),
                        ],
                      ),
                    ),
                  ),
                ),
                // Color picker button
                GestureDetector(
                  onTap: () => _showColorPicker(context),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: player.colors.isEmpty
                        ? Icon(Icons.palette_outlined, size: 18, color: subtleColor)
                        : _MiniColorIcons(colors: player.colors),
                  ),
                ),
                if (canRemove)
                  GestureDetector(
                    onTap: () =>
                        context.read<GameState>().removePlayer(player.id),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 18, color: subtleColor),
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

/// Small inline row of mana symbol icons showing current color selection.
class _MiniColorIcons extends StatelessWidget {
  final List<MtgColor> colors;

  const _MiniColorIcons({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors.map((c) {
        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.circleColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.5),
              child: SvgPicture.asset(
                c.assetPath,
                colorFilter: ColorFilter.mode(c.iconColor, BlendMode.srcIn),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Bottom sheet that lets the user update a player's mana colors during a game.
class _ColorPickerSheet extends StatefulWidget {
  final Player player;

  const _ColorPickerSheet({required this.player});

  @override
  State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  late Set<MtgColor> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.player.colors.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.player.name} — Commander Colors',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ManaColorPicker(
            selected: _selected,
            onChanged: (colors) {
              setState(() => _selected = colors);
              context
                  .read<GameState>()
                  .setPlayerColors(widget.player.id, colors.toList());
            },
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
