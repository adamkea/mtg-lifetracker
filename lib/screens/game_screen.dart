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

    return Scaffold(
      appBar: AppBar(
        title: const Text('MTG Life Tracker'),
        automaticallyImplyLeading: false,
        actions: [
          // Light/dark mode toggle
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: context.read<ThemeNotifier>().toggle,
          ),
          // Add player (disabled at 6)
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add player',
            onPressed:
                players.length < 6 ? context.read<GameState>().addPlayer : null,
          ),
          // New game — returns to SetupScreen
          IconButton(
            icon: const Icon(Icons.refresh),
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
      // With 2 players the top card is rotated 180° so the player sitting at
      // the far end of the device can read it right-side up.
      return Column(
        children: players.asMap().entries.map((e) {
          final card = PlayerCard(player: e.value);
          final rotate = players.length == 2 && e.key == 0;
          return Expanded(
            child: rotate ? RotatedBox(quarterTurns: 2, child: card) : card,
          );
        }).toList(),
      );
    }

    // 3–6 players: 2-column grid. Compute aspect ratio so cards fill height.
    // Left column (even indices) rotates 90° clockwise so players on the left
    // side of a horizontal phone can read their card. Right column (odd indices)
    // rotates 90° counter-clockwise for players on the right side.
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
      itemBuilder: (_, i) {
        final card = PlayerCard(player: players[i]);
        final turns = i.isEven ? 1 : 3;
        return RotatedBox(quarterTurns: turns, child: card);
      },
    );
  }
}
