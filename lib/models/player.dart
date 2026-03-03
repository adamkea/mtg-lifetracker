/// Immutable data class representing a single player.
///
/// All mutations return a new [Player] via [copyWith]. This keeps
/// the history stack in [GameState] trivially correct — a snapshot
/// is just a shallow copy of the players list.
class Player {
  final String id;
  final String name;
  final int lifeTotal;

  const Player({
    required this.id,
    required this.name,
    required this.lifeTotal,
  });

  Player copyWith({String? name, int? lifeTotal}) {
    return Player(
      id: id,
      name: name ?? this.name,
      lifeTotal: lifeTotal ?? this.lifeTotal,
    );
  }

  @override
  bool operator ==(Object other) => other is Player && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
