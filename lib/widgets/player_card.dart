import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/mtg_color.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import 'mana_color_picker.dart';
import 'player_name_dialog.dart';

/// Displays one player's panel edge-to-edge.
///
/// Life total dominates the space with a neon glow effect.
/// Low life (≤5) switches to a red danger glow.
/// Tap left half to decrement; right half to increment. Hold to rapid-fire.
/// Long-press anywhere for the player action sheet.
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
          .map((c) => Color.alphaBlend(c.circleColor.withOpacity(0.22), base))
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
    final life = widget.player.lifeTotal;

    final deltaSign = _deltaAccumulator > 0 ? '+' : '';
    final deltaColor =
        _deltaAccumulator >= 0 ? colorScheme.tertiary : colorScheme.error;

    // Neon glow: danger (≤5) = rose, dead (≤0) = dim, normal = purple
    final bool isDanger = life > 0 && life <= 5;
    final bool isDead = life <= 0;
    final lifeGlowColor = isDanger
        ? colorScheme.error
        : isDead
            ? Colors.transparent
            : colorScheme.primary;

    final TextStyle lifeStyle = GoogleFonts.russoOne(
      fontSize: 88,
      letterSpacing: -2,
      color: isDead
          ? colorScheme.onSurface.withOpacity(0.25)
          : isDanger
              ? colorScheme.error
              : colorScheme.onSurface,
      shadows: isDead
          ? null
          : [
              Shadow(
                color: lifeGlowColor.withOpacity(0.75),
                blurRadius: 24,
              ),
              Shadow(
                color: lifeGlowColor.withOpacity(0.35),
                blurRadius: 60,
              ),
            ],
    );

    return GestureDetector(
      onLongPress: () => _showActions(context),
      child: Container(
        decoration: BoxDecoration(
          color: gradient != null ? null : _baseColor(context),
          gradient: gradient,
        ),
        child: Stack(
          children: [
            // ── Gesture halves ────────────────────────────────────────────────
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

            // ── Edge hints ────────────────────────────────────────────────────
            IgnorePointer(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Icon(
                    Icons.remove_rounded,
                    color: colorScheme.error.withOpacity(0.5),
                    size: 30,
                    shadows: [
                      Shadow(
                        color: colorScheme.error.withOpacity(0.4),
                        blurRadius: 12,
                      ),
                    ],
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
                    color: colorScheme.tertiary.withOpacity(0.5),
                    size: 30,
                    shadows: [
                      Shadow(
                        color: colorScheme.tertiary.withOpacity(0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Name + life badge (centre, tap to edit) ───────────────────────
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Fit the badge comfortably inside even the smallest grid cell.
                  final shortest =
                      constraints.biggest.shortestSide.isFinite
                          ? constraints.biggest.shortestSide
                          : 260.0;
                  final double diameter =
                      shortest.clamp(140.0, 260.0).toDouble();
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showActions(context),
                    child: Container(
                      width: diameter,
                      height: diameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.18),
                          width: 1.2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Delta indicator
                            AnimatedOpacity(
                              opacity: _showDelta ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: AnimatedScale(
                                scale: _showDelta ? 1.0 : 0.6,
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  '$deltaSign$_deltaAccumulator',
                                  style: GoogleFonts.chakraPetch(
                                    color: deltaColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    shadows: [
                                      Shadow(
                                        color: deltaColor.withOpacity(0.6),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Player name + mini colour dots
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.player.name,
                                    style: GoogleFonts.chakraPetch(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.5,
                                      color: colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                if (widget.player.colors.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  _MiniColorDots(colors: widget.player.colors),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Life total
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${widget.player.lifeTotal}',
                                style: lifeStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Half-panel gesture area. Tap = one life change + history; hold = rapid-fire.
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
            ? colorScheme.tertiary.withOpacity(0.15)
            : colorScheme.error.withOpacity(0.15))
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

/// Compact row of mana color dots.
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
            boxShadow: [
              BoxShadow(
                color: c.circleColor.withOpacity(0.7),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Bottom sheet with per-player actions.
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
    final sheetBg = Color.lerp(
      colorScheme.surfaceContainerHigh,
      const Color(0xFF13132A),
      0.5,
    )!;

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
              color: colorScheme.primary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Player name header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Text(
                        player.name.toUpperCase(),
                        style: GoogleFonts.chakraPetch(
                          color: colorScheme.primary.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      if (player.colors.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _MiniColorDots(colors: player.colors),
                      ],
                    ],
                  ),
                ),
                Divider(height: 1, color: colorScheme.primary.withOpacity(0.1)),

                _SheetItem(
                  icon: Icons.edit_rounded,
                  label: 'Rename',
                  iconColor: colorScheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    showPlayerNameDialog(context, player);
                  },
                ),
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: colorScheme.primary.withOpacity(0.08),
                ),

                _SheetItem(
                  icon: Icons.palette_rounded,
                  label: 'Deck Colors',
                  iconColor: colorScheme.tertiary,
                  onTap: () {
                    Navigator.pop(context);
                    _showColorPicker(context);
                  },
                ),

                if (canRemove) ...[
                  Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: colorScheme.primary.withOpacity(0.08),
                  ),
                  _SheetItem(
                    icon: Icons.person_remove_rounded,
                    label: 'Remove Player',
                    iconColor: colorScheme.error,
                    textColor: colorScheme.error,
                    onTap: () {
                      context.read<GameState>().removePlayer(player.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.chakraPetch(
                      color: colorScheme.onSurface.withOpacity(0.6),
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
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Color.lerp(
        colorScheme.surfaceContainerHigh,
        const Color(0xFF13132A),
        0.5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ColorPickerSheet(player: player),
    );
  }
}

class _SheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _SheetItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.chakraPetch(
                color: textColor ?? cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.player.name} — Deck Colors',
            style: GoogleFonts.chakraPetch(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: cs.onSurface,
            ),
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
