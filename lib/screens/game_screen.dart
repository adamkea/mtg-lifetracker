import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../models/player.dart';
import '../models/theme_notifier.dart';
import '../widgets/player_card.dart';
import '../widgets/undo_bar.dart';

/// The main game screen. Displays all player cards in an adaptive grid
/// and provides AppBar actions for adding players and starting a new game.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final players = gs.players;
    final isDark = context.watch<ThemeNotifier>().isDark;
    final appBarColor = Theme.of(context).scaffoldBackgroundColor;
    final iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    final iconDisabledColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.25);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'MTG Life Tracker',
          style: TextStyle(color: iconColor, fontSize: 16),
        ),
        automaticallyImplyLeading: false,
        actions: [
          // Light/dark mode toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: iconColor,
            ),
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: context.read<ThemeNotifier>().toggle,
          ),
          // Add player (disabled at 6)
          IconButton(
            icon: Icon(
              Icons.person_add,
              color: players.length < 6 ? iconColor : iconDisabledColor,
            ),
            tooltip: 'Add player',
            onPressed:
                players.length < 6 ? context.read<GameState>().addPlayer : null,
          ),
          // New game — returns to SetupScreen
          IconButton(
            icon: Icon(Icons.refresh, color: iconColor),
            tooltip: 'New game',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _buildPlayerGrid(players, constraints),
            ),
          ),
          const UndoBar(),
        ],
      ),
    );
  }

  Widget _buildPlayerGrid(
    List<Player> players,
    BoxConstraints constraints,
  ) {
    if (players.length <= 2) {
      // 1–2 players: each card fills its half of the screen height.
      return Column(
        children: players
            .map((p) => Expanded(child: PlayerCard(player: p)))
            .toList(),
      );
    }

    // 3–6 players: 2-column grid. Compute aspect ratio so cards fill height.
    final rows = (players.length / 2).ceil();
    final cardAspectRatio =
        (constraints.maxWidth / 2) / (constraints.maxHeight / rows);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: cardAspectRatio,
      ),
      itemCount: players.length,
      itemBuilder: (_, i) => PlayerCard(player: players[i]),
    );
  }
}
