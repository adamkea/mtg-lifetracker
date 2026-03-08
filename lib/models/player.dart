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
  final List<MtgColor> colors;

  const Player({
    required this.id,
    required this.name,
    required this.lifeTotal,
    this.colors = const [],
  });

  Player copyWith({String? name, int? lifeTotal, List<MtgColor>? colors}) {
    return Player(
      id: id,
      name: name ?? this.name,
      lifeTotal: lifeTotal ?? this.lifeTotal,
      colors: colors ?? this.colors,
    );
  }

  @override
  bool operator ==(Object other) => other is Player && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
