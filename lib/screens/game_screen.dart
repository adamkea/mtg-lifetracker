import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../models/player.dart';
import '../widgets/center_menu.dart';
import '../widgets/player_card.dart';

/// Full-screen game tracker. Player panels fill every pixel with no gaps.
/// A small floating orb at the screen centre provides access to all actions.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system UI when leaving the game screen.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = context.watch<GameState>().players;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen player grid ────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) =>
                _buildPlayerGrid(players, constraints),
          ),

          // ── Centre menu button ─────────────────────────────────────────────
          const Center(child: CenterMenuButton()),
        ],
      ),
    );
  }

  Widget _buildPlayerGrid(List<Player> players, BoxConstraints constraints) {
    if (players.length <= 2) {
      // 1–2 players: stacked vertically, filling full height.
      // With 2 players the top card is rotated 180° so the far-end player
      // can read it upright.
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

    // 3–6 players: 2-column grid filling full height.
    // Left column rotates 90° CW, right column 90° CCW so players on each
    // side of a horizontal device can read their card upright.
    final rows = (players.length / 2).ceil();
    final cardAspectRatio =
        (constraints.maxWidth / 2) / (constraints.maxHeight / rows);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: cardAspectRatio,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
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
