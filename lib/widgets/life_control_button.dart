import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';

/// A button that applies [delta] to a player's life total.
///
/// A single tap applies [delta] once (and pushes one undo snapshot).
/// Holding the button for 500 ms begins rapid-fire changes every 150 ms,
/// but all those ticks collapse to the single snapshot created on initial
/// press — so one undo reverts the entire hold sequence.
class LifeControlButton extends StatefulWidget {
  final String playerId;
  final int delta;

  const LifeControlButton({
    required this.playerId,
    required this.delta,
    super.key,
  });

  @override
  State<LifeControlButton> createState() => _LifeControlButtonState();
}

class _LifeControlButtonState extends State<LifeControlButton> {
  Timer? _holdTimer;

  void _onTapDown(TapDownDetails _) {
    final gs = context.read<GameState>();
    // First press: push history snapshot, apply change.
    gs.changeLife(widget.playerId, widget.delta);

    // After 500 ms, begin rapid-fire changes without additional history pushes.
    _holdTimer = Timer(const Duration(milliseconds: 500), () {
      _holdTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (mounted) {
          context.read<GameState>().changeLifeNoHistory(
                widget.playerId,
                widget.delta,
              );
        }
      });
    });
  }

  void _cancel() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sign = widget.delta > 0 ? '+' : '';
    final label = '$sign${widget.delta}';
    final isPositive = widget.delta > 0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (_) => _cancel(),
      onTapCancel: _cancel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isPositive
              ? const Color(0xFF1B4332) // dark green for +
              : const Color(0xFF3B1A1A), // dark red for -
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPositive ? Colors.greenAccent : Colors.redAccent,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
