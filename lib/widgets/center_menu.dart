import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../models/theme_notifier.dart';

/// The pulsing orb button rendered at the intersection of all player panels.
/// Tapping it opens the [GameMenu] bottom sheet.
class CenterMenuButton extends StatefulWidget {
  const CenterMenuButton({super.key});

  @override
  State<CenterMenuButton> createState() => _CenterMenuButtonState();
}

class _CenterMenuButtonState extends State<CenterMenuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _open() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const GameMenu(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _open,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surface.withOpacity(0.85),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.menu_rounded,
            size: 22,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Full-featured game menu shown as a bottom sheet.
/// Contains: undo, add player, new game, and theme toggle.
class GameMenu extends StatelessWidget {
  const GameMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final themeNotifier = context.watch<ThemeNotifier>();
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

          // Menu card
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Undo
                _MenuItem(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  subtitle: gs.canUndo ? gs.lastActionDescription : 'Nothing to undo',
                  enabled: gs.canUndo,
                  iconColor: colorScheme.primary,
                  onTap: () {
                    gs.undo();
                    Navigator.pop(context);
                  },
                ),
                _Divider(),

                // Add player
                _MenuItem(
                  icon: Icons.person_add_rounded,
                  label: 'Add Player',
                  enabled: gs.players.length < 6,
                  iconColor: colorScheme.tertiary,
                  onTap: () {
                    gs.addPlayer();
                    Navigator.pop(context);
                  },
                ),
                _Divider(),

                // New game
                _MenuItem(
                  icon: Icons.refresh_rounded,
                  label: 'New Game',
                  subtitle: 'Return to setup',
                  iconColor: colorScheme.secondary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pop();
                  },
                ),
                _Divider(),

                // Theme toggle
                _MenuItem(
                  icon: themeNotifier.isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  label: themeNotifier.isDark ? 'Light Mode' : 'Dark Mode',
                  iconColor: colorScheme.onSurface.withOpacity(0.7),
                  onTap: () {
                    themeNotifier.toggle();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Close button
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _MenuItem(
              icon: Icons.close_rounded,
              label: 'Close',
              centered: true,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool enabled;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool centered;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.enabled = true,
    this.iconColor,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = enabled
        ? (iconColor ?? colorScheme.onSurface)
        : colorScheme.onSurface.withOpacity(0.3);
    final textColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withOpacity(0.3);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: centered
            ? Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : Row(
                children: [
                  Icon(icon, color: effectiveColor, size: 22),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: textColor.withOpacity(0.6),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
    );
  }
}
