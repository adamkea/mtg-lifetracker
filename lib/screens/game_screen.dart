import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../models/player.dart';
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: const Text(
          'MTG Life Tracker',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        automaticallyImplyLeading: false,
        actions: [
          // Add player (disabled at 6)
          IconButton(
            icon: Icon(
              Icons.person_add,
              color: players.length < 6 ? Colors.white70 : Colors.white24,
            ),
            tooltip: 'Add player',
            onPressed:
                players.length < 6 ? context.read<GameState>().addPlayer : null,
          ),
          // New game — returns to SetupScreen
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
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
