import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../models/theme_notifier.dart';

/// The pulsing neon orb at the intersection of all player panels.
/// Tapping opens the [GameMenu] bottom sheet.
class CenterMenuButton extends StatefulWidget {
  const CenterMenuButton({super.key});

  @override
  State<CenterMenuButton> createState() => _CenterMenuButtonState();
}

class _CenterMenuButtonState extends State<CenterMenuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _glowOpacity = Tween<double>(begin: 0.45, end: 0.9).animate(
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
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: GestureDetector(
            onTap: _open,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF1C1C40), Color(0xFF0D0D22)],
                ),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.7),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary
                        .withOpacity(0.5 * _glowOpacity.value),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: colorScheme.primary
                        .withOpacity(0.2 * _glowOpacity.value),
                    blurRadius: 40,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                Icons.menu_rounded,
                size: 24,
                color: colorScheme.primary,
                shadows: [
                  Shadow(
                    color: colorScheme.primary.withOpacity(0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Full-featured game menu shown as a bottom sheet.
class GameMenu extends StatelessWidget {
  const GameMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final themeNotifier = context.watch<ThemeNotifier>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeNotifier.isDark;

    final sheetBg = isDark
        ? const Color(0xFF0E0E22)
        : colorScheme.surfaceContainerHigh;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle with neon glow
          Container(
            margin: const EdgeInsets.only(bottom: 14, top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),

          // Menu card
          Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(
                      color: colorScheme.primary.withOpacity(0.18),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  subtitle: gs.canUndo
                      ? gs.lastActionDescription
                      : 'Nothing to undo',
                  enabled: gs.canUndo,
                  iconColor: colorScheme.primary,
                  isDark: isDark,
                  onTap: () {
                    gs.undo();
                    Navigator.pop(context);
                  },
                ),
                _MenuDivider(isDark: isDark),

                _MenuItem(
                  icon: Icons.person_add_rounded,
                  label: 'Add Player',
                  enabled: gs.players.length < 6,
                  iconColor: colorScheme.tertiary,
                  isDark: isDark,
                  onTap: () {
                    gs.addPlayer();
                    Navigator.pop(context);
                  },
                ),
                _MenuDivider(isDark: isDark),

                _MenuItem(
                  icon: Icons.refresh_rounded,
                  label: 'New Game',
                  subtitle: 'Return to setup',
                  iconColor: colorScheme.secondary,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pop();
                  },
                ),
                _MenuDivider(isDark: isDark),

                _MenuItem(
                  icon: themeNotifier.isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  label: themeNotifier.isDark ? 'Light Mode' : 'Dark Mode',
                  iconColor: colorScheme.onSurface.withOpacity(0.6),
                  isDark: isDark,
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
              color: sheetBg,
              borderRadius: BorderRadius.circular(16),
              border: isDark
                  ? Border.all(
                      color: colorScheme.primary.withOpacity(0.12),
                      width: 1,
                    )
                  : null,
            ),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Close',
                    style: GoogleFonts.chakraPetch(
                      color: colorScheme.onSurface.withOpacity(0.55),
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
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool enabled;
  final Color? iconColor;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.subtitle,
    this.enabled = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveIconColor = enabled
        ? (iconColor ?? colorScheme.onSurface)
        : colorScheme.onSurface.withOpacity(0.25);
    final textColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withOpacity(0.25);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Icon with optional neon glow
            Icon(
              icon,
              color: effectiveIconColor,
              size: 22,
              shadows: enabled && isDark
                  ? [
                      Shadow(
                        color: effectiveIconColor.withOpacity(0.6),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.chakraPetch(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.chakraPetch(
                        color: textColor.withOpacity(0.5),
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

class _MenuDivider extends StatelessWidget {
  final bool isDark;
  const _MenuDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: isDark
          ? cs.primary.withOpacity(0.1)
          : cs.onSurface.withOpacity(0.08),
    );
  }
}
