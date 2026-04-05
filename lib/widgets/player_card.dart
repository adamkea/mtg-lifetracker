import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mtg_color.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import 'mana_color_picker.dart';
import 'player_name_dialog.dart';

/// Displays one player's panel edge-to-edge with no gaps or borders.
///
/// The life total dominates the space. A long-press anywhere on the card
/// reveals a contextual action sheet (rename, colors, remove).
/// Tapping left half decrements life; right half increments it.
/// Hold either half to rapid-fire changes.
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

  Color _baseColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = colorScheme.surfaceContainer;
    if (widget.player.colors.isEmpty) return base;
    var result = base;
    for (final c in widget.player.colors) {
      result = Color.alphaBlend(c.cardTint, result);
    }
    return result;
  }

  Gradient? _gradient(BuildContext context) {
    final colors = widget.player.colors;
    if (colors.length < 2) return null;
    final base = Theme.of(context).colorScheme.surfaceContainer;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors
          .map((c) => Color.alphaBlend(c.circleColor.withOpacity(0.3), base))
          .toList(),
    );
  }

  void _showActions(BuildContext context) {
    final gs = context.read<GameState>();
    final canRemove = gs.players.length > 1;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PlayerActionsSheet(
        player: widget.player,
        canRemove: canRemove,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradient = _gradient(context);

    final deltaSign = _deltaAccumulator > 0 ? '+' : '';
    final deltaColor =
        _deltaAccumulator >= 0 ? colorScheme.tertiary : colorScheme.error;

    return GestureDetector(
      onLongPress: () => _showActions(context),
      child: Container(
        decoration: BoxDecoration(
          color: gradient != null ? null : _baseColor(context),
          gradient: gradient,
        ),
        child: Stack(
          children: [
            // ── Gesture halves (left=minus, right=plus) ──────────────────────
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

            // ── Subtle edge hints ─────────────────────────────────────────────
            IgnorePointer(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Icon(
                    Icons.remove_rounded,
                    color: colorScheme.error.withOpacity(0.45),
                    size: 28,
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(
                    Icons.add_rounded,
                    color: colorScheme.tertiary.withOpacity(0.45),
                    size: 28,
                  ),
                ),
              ),
            ),

            // ── Player name (top centre) ──────────────────────────────────────
            IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.player.name,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.player.colors.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _MiniColorDots(colors: widget.player.colors),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── Life total + delta (centre) ───────────────────────────────────
            IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Delta
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
                            fontSize: 20,
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

            // ── Long-press hint (bottom centre) ──────────────────────────────
            IgnorePointer(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Half-panel gesture area. Tap = one life change; hold = rapid-fire.
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
    context.read<GameState>().changeLife(widget.playerId, widget.delta);
    widget.onDeltaChanged(widget.delta);

    _holdTimer = Timer(const Duration(milliseconds: 500), () {
      _holdTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (mounted) {
          context
              .read<GameState>()
              .changeLifeNoHistory(widget.playerId, widget.delta);
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
            ? colorScheme.tertiary.withOpacity(0.18)
            : colorScheme.error.withOpacity(0.18))
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

/// Compact inline row of mana color dots.
class _MiniColorDots extends StatelessWidget {
  final List<MtgColor> colors;

  const _MiniColorDots({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors.map((c) {
        return Container(
          margin: const EdgeInsets.only(left: 3),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.circleColor,
          ),
        );
      }).toList(),
    );
  }
}

/// Bottom sheet with per-player actions: rename, colors, remove.
class _PlayerActionsSheet extends StatelessWidget {
  final Player player;
  final bool canRemove;

  const _PlayerActionsSheet({
    required this.player,
    required this.canRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(bottom: 12, top: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Player name header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        player.name,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (player.colors.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _MiniColorDots(colors: player.colors),
                      ],
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: colorScheme.onSurface.withOpacity(0.08),
                ),

                // Rename
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    showPlayerNameDialog(context, player);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded,
                            color: colorScheme.primary, size: 20),
                        const SizedBox(width: 16),
                        Text(
                          'Rename',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: colorScheme.onSurface.withOpacity(0.08),
                ),

                // Deck colors
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _showColorPicker(context);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.palette_rounded,
                            color: colorScheme.tertiary, size: 20),
                        const SizedBox(width: 16),
                        Text(
                          'Deck Colors',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (canRemove) ...[
                  Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: colorScheme.onSurface.withOpacity(0.08),
                  ),
                  // Remove player
                  InkWell(
                    onTap: () {
                      context.read<GameState>().removePlayer(player.id);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.person_remove_rounded,
                              color: colorScheme.error, size: 20),
                          const SizedBox(width: 16),
                          Text(
                            'Remove Player',
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ColorPickerSheet(player: player),
    );
  }
}

/// Color picker bottom sheet for a player's deck colors.
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
            '${widget.player.name} — Deck Colors',
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
