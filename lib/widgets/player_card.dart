import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/mtg_color.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import 'mana_color_picker.dart';
import 'player_name_dialog.dart';

/// Displays one player's panel: name, life total, and life-change controls.
///
/// The life total is rendered very large so it's readable from across a table.
/// Tapping the player name opens the rename dialog.
/// The left half of the card decrements life; the right half increments it.
/// Small minus/plus icons at the edges indicate the tap zones.
/// Pressing and holding either half begins rapid-fire changes after 500 ms.
class PlayerCard extends StatefulWidget {
  final Player player;

  const PlayerCard({required this.player, super.key});

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  int _deltaAccumulator = 0;
  bool _showDelta = false;
  Timer? _deltaHideTimer;

  void _onLifeChanged(int delta) {
    setState(() {
      _deltaAccumulator += delta;
      _showDelta = true;
    });
    _deltaHideTimer?.cancel();
    _deltaHideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showDelta = false;
          _deltaAccumulator = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _deltaHideTimer?.cancel();
    super.dispose();
  }

  Color _cardColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainer;
    if (widget.player.colors.isEmpty) return baseColor;
    var result = baseColor;
    for (final c in widget.player.colors) {
      result = Color.alphaBlend(c.cardTint, result);
    }
    return result;
  }

  Gradient? _cardGradient(BuildContext context) {
    final colors = widget.player.colors;
    if (colors.length < 2) return null;
    final base = Theme.of(context).colorScheme.surfaceContainer;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors
          .map((c) => Color.alphaBlend(c.circleColor.withOpacity(0.25), base))
          .toList(),
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return _ColorPickerSheet(player: widget.player);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final canRemove = gs.players.length > 1;
    final colorScheme = Theme.of(context).colorScheme;

    final deltaSign = _deltaAccumulator > 0 ? '+' : '';
    final deltaColor = _deltaAccumulator >= 0
        ? colorScheme.tertiary
        : colorScheme.error;

    final gradient = _cardGradient(context);

    return Card(
      margin: const EdgeInsets.all(4),
      color: gradient != null ? Colors.transparent : _cardColor(context),
      surfaceTintColor: gradient != null ? Colors.transparent : null,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration:
            gradient != null ? BoxDecoration(gradient: gradient) : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header row: player name + icons ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => showPlayerNameDialog(context, widget.player),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                widget.player.name,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit,
                              size: 14,
                              color: colorScheme.onSurface.withOpacity(0.38),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Color picker button
                  IconButton(
                    onPressed: () => _showColorPicker(context),
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    icon: widget.player.colors.isEmpty
                        ? Icon(
                            Icons.palette_outlined,
                            color: colorScheme.onSurface.withOpacity(0.38),
                          )
                        : _MiniColorIcons(colors: widget.player.colors),
                  ),
                  if (canRemove)
                    IconButton(
                      onPressed: () => context
                          .read<GameState>()
                          .removePlayer(widget.player.id),
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface.withOpacity(0.38),
                      ),
                    ),
                ],
              ),
            ),

            // ── Main area: left half = minus, right half = plus ────────────
            //
            // A Stack layered as:
            //   1. Two _HalfTapArea gesture zones (left=minus, right=plus)
            //   2. Small minus/plus icons at the left/right edges (visual hints)
            //   3. Life total + delta indicator centred on top
            Expanded(
              child: Stack(
                children: [
                  // Layer 1 – gesture halves
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _HalfTapArea(
                          playerId: widget.player.id,
                          delta: -1,
                          onDeltaChanged: _onLifeChanged,
                        ),
                      ),
                      Expanded(
                        child: _HalfTapArea(
                          playerId: widget.player.id,
                          delta: 1,
                          onDeltaChanged: _onLifeChanged,
                        ),
                      ),
                    ],
                  ),

                  // Layer 2 – minus icon hint (left edge)
                  IgnorePointer(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.remove_circle_outline,
                          color: colorScheme.error,
                          size: 36,
                        ),
                      ),
                    ),
                  ),

                  // Layer 2 – plus icon hint (right edge)
                  IgnorePointer(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: colorScheme.tertiary,
                          size: 36,
                        ),
                      ),
                    ),
                  ),

                  // Layer 3 – life total + delta indicator (centre)
                  IgnorePointer(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Delta indicator — fades and scales in/out above the life counter
                          AnimatedOpacity(
                            opacity: _showDelta ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: AnimatedScale(
                              scale: _showDelta ? 1.0 : 0.6,
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                '$deltaSign$_deltaAccumulator',
                                style: TextStyle(
                                  color: deltaColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Life total
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${widget.player.lifeTotal}',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Full-height, expandable gesture area for one half of the player card.
///
/// Tapping applies [delta] once (with one undo snapshot).
/// Holding for 500 ms begins rapid-fire changes every 150 ms that all
/// collapse to the same undo snapshot.
class _HalfTapArea extends StatefulWidget {
  final String playerId;
  final int delta;
  final ValueChanged<int> onDeltaChanged;

  const _HalfTapArea({
    required this.playerId,
    required this.delta,
    required this.onDeltaChanged,
  });

  @override
  State<_HalfTapArea> createState() => _HalfTapAreaState();
}

class _HalfTapAreaState extends State<_HalfTapArea> {
  Timer? _holdTimer;
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
    final gs = context.read<GameState>();
    gs.changeLife(widget.playerId, widget.delta);
    widget.onDeltaChanged(widget.delta);

    _holdTimer = Timer(const Duration(milliseconds: 500), () {
      _holdTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (mounted) {
          context.read<GameState>().changeLifeNoHistory(
                widget.playerId,
                widget.delta,
              );
          widget.onDeltaChanged(widget.delta);
        }
      });
    });
  }

  void _cancel() {
    if (mounted) setState(() => _pressed = false);
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPlus = widget.delta > 0;
    final highlightColor = _pressed
        ? (isPlus
            ? colorScheme.tertiary.withOpacity(0.25)
            : colorScheme.error.withOpacity(0.25))
        : Colors.transparent;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (_) => _cancel(),
      onTapCancel: _cancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        color: highlightColor,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.player.name} — Commander Colors',
            style: Theme.of(context).textTheme.titleMedium,
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
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
