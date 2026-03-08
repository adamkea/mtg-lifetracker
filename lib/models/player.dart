import 'mtg_color.dart';

/// Immutable data class representing a single player.
///
/// All mutations return a new [Player] via [copyWith]. This keeps
/// the history stack in [GameState] trivially correct — a snapshot
/// is just a shallow copy of the players list.
class Player {
  final String id;
  final String name;
  final int lifeTotal;
  final MtgColor? color;

  const Player({
    required this.id,
    required this.name,
    required this.lifeTotal,
    this.color,
  });

  Player copyWith({String? name, int? lifeTotal, MtgColor? color, bool clearColor = false}) {
    return Player(
      id: id,
      name: name ?? this.name,
      lifeTotal: lifeTotal ?? this.lifeTotal,
      color: clearColor ? null : (color ?? this.color),
    );
  }

  @override
  bool operator ==(Object other) => other is Player && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
