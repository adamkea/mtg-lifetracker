import 'package:flutter/foundation.dart';
import 'mtg_color.dart';
import 'player.dart';

/// All game logic and state lives here.
///
/// The undo stack stores complete snapshots of the players list before
/// each change. Because [Player] is immutable, a shallow list copy is
/// sufficient and cheap.
class GameState extends ChangeNotifier {
  List<Player> _players = [];
  final List<List<Player>> _history = [];
  int _startingLife = 20;
  String _lastActionDescription = '';

  // ── Getters ────────────────────────────────────────────────────────────────

  List<Player> get players => List.unmodifiable(_players);
  bool get canUndo => _history.isNotEmpty;
  int get startingLife => _startingLife;
  String get lastActionDescription => _lastActionDescription;

  // ── Setup ──────────────────────────────────────────────────────────────────

  /// Resets the game with [playerCount] players each starting at [startingLife].
  void startGame({required int playerCount, required int startingLife}) {
    _startingLife = startingLife;
    _history.clear();
    _players = List.generate(
      playerCount,
      (i) => Player(
        id: 'p$i',
        name: 'Player ${i + 1}',
        lifeTotal: startingLife,
      ),
    );
    _lastActionDescription = '';
    notifyListeners();
  }

  // ── Player Management ──────────────────────────────────────────────────────

  /// Adds a new player (max 6). No-op if already at capacity.
  void addPlayer() {
    if (_players.length >= 6) return;
    _pushHistory();
    final id = 'p${DateTime.now().millisecondsSinceEpoch}';
    final name = 'Player ${_players.length + 1}';
    _players = [
      ..._players,
      Player(id: id, name: name, lifeTotal: _startingLife),
    ];
    _lastActionDescription = '$name added';
    notifyListeners();
  }

  /// Removes the player with [playerId]. No-op if only 1 player remains.
  void removePlayer(String playerId) {
    if (_players.length <= 1) return;
    _pushHistory();
    final removed = _players.firstWhere((p) => p.id == playerId);
    _players = _players.where((p) => p.id != playerId).toList();
    _lastActionDescription = '${removed.name} removed';
    notifyListeners();
  }

  /// Sets the MTG colours for a player's tile. Does not push history.
  void setPlayerColors(String playerId, List<MtgColor> colors) {
    _players = _players
        .map((p) => p.id == playerId ? p.copyWith(colors: List.unmodifiable(colors)) : p)
        .toList();
    notifyListeners();
  }

  /// Renames a player. Does not push history (non-consequential to game).
  void renamePlayer(String playerId, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    _players = _players
        .map((p) => p.id == playerId ? p.copyWith(name: trimmed) : p)
        .toList();
    _lastActionDescription = 'Renamed to $trimmed';
    notifyListeners();
  }

  // ── Life Changes ───────────────────────────────────────────────────────────

  /// Changes life for [playerId] by [delta], pushing a history snapshot first.
  /// Call this once per gesture (tap or start of hold).
  void changeLife(String playerId, int delta) {
    _pushHistory();
    _applyLifeChange(playerId, delta);
  }

  /// Changes life for [playerId] by [delta] without pushing history.
  /// Used for subsequent ticks during a hold gesture so the entire hold
  /// sequence collapses to a single undo step.
  void changeLifeNoHistory(String playerId, int delta) {
    _applyLifeChange(playerId, delta);
  }

  // ── Undo ───────────────────────────────────────────────────────────────────

  /// Restores the most recent snapshot. No-op if history is empty.
  void undo() {
    if (_history.isEmpty) return;
    _players = _history.removeLast();
    _lastActionDescription = 'Undone';
    notifyListeners();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _pushHistory() {
    _history.add(List.of(_players));
    if (_history.length > 50) _history.removeAt(0);
  }

  void _applyLifeChange(String playerId, int delta) {
    _players = _players
        .map((p) => p.id == playerId ? p.copyWith(lifeTotal: p.lifeTotal + delta) : p)
        .toList();
    final p = _players.firstWhere((p) => p.id == playerId);
    final sign = delta > 0 ? '+' : '';
    _lastActionDescription = '${p.name}: $sign$delta';
    notifyListeners();
  }
}
