import 'package:flutter_test/flutter_test.dart';
import 'package:mtg_lifetracker/models/game_state.dart';

void main() {
  late GameState gs;

  setUp(() {
    gs = GameState();
    gs.startGame(playerCount: 2, startingLife: 20);
  });

  group('startGame', () {
    test('creates correct number of players', () {
      gs.startGame(playerCount: 4, startingLife: 40);
      expect(gs.players.length, 4);
    });

    test('sets starting life total', () {
      gs.startGame(playerCount: 3, startingLife: 30);
      for (final p in gs.players) {
        expect(p.lifeTotal, 30);
      }
    });

    test('clears history on new game', () {
      gs.changeLife(gs.players.first.id, -3);
      gs.startGame(playerCount: 2, startingLife: 20);
      expect(gs.canUndo, isFalse);
    });

    test('assigns sequential default names', () {
      gs.startGame(playerCount: 3, startingLife: 20);
      expect(gs.players[0].name, 'Player 1');
      expect(gs.players[1].name, 'Player 2');
      expect(gs.players[2].name, 'Player 3');
    });
  });

  group('changeLife', () {
    test('applies positive delta to the correct player only', () {
      final id = gs.players[0].id;
      gs.changeLife(id, 5);
      expect(gs.players[0].lifeTotal, 25);
      expect(gs.players[1].lifeTotal, 20);
    });

    test('applies negative delta', () {
      final id = gs.players[1].id;
      gs.changeLife(id, -7);
      expect(gs.players[1].lifeTotal, 13);
    });

    test('allows life total to go negative', () {
      final id = gs.players[0].id;
      gs.changeLife(id, -30);
      expect(gs.players[0].lifeTotal, -10);
    });

    test('pushes to history', () {
      expect(gs.canUndo, isFalse);
      gs.changeLife(gs.players[0].id, 1);
      expect(gs.canUndo, isTrue);
    });
  });

  group('changeLifeNoHistory', () {
    test('changes life without pushing history', () {
      gs.changeLifeNoHistory(gs.players[0].id, 3);
      expect(gs.players[0].lifeTotal, 23);
      expect(gs.canUndo, isFalse);
    });
  });

  group('undo', () {
    test('restores previous state', () {
      final id = gs.players[0].id;
      gs.changeLife(id, -5);
      gs.undo();
      expect(gs.players[0].lifeTotal, 20);
    });

    test('undo when history is empty does nothing', () {
      expect(() => gs.undo(), returnsNormally);
      expect(gs.players.length, 2);
    });

    test('undo respects multiple history entries', () {
      final id = gs.players[0].id;
      gs.changeLife(id, -1);
      gs.changeLife(id, -2);
      gs.changeLife(id, -3);
      gs.undo();
      expect(gs.players[0].lifeTotal, 17); // reverts the -3
      gs.undo();
      expect(gs.players[0].lifeTotal, 19); // reverts the -2
    });

    test('canUndo is false after undoing all history', () {
      gs.changeLife(gs.players[0].id, 1);
      gs.undo();
      expect(gs.canUndo, isFalse);
    });
  });

  group('addPlayer', () {
    test('adds a player', () {
      gs.addPlayer();
      expect(gs.players.length, 3);
    });

    test('new player starts at startingLife', () {
      gs.startGame(playerCount: 2, startingLife: 40);
      gs.addPlayer();
      expect(gs.players.last.lifeTotal, 40);
    });

    test('caps at 6 players', () {
      gs.startGame(playerCount: 6, startingLife: 20);
      gs.addPlayer();
      expect(gs.players.length, 6);
    });

    test('addPlayer pushes history', () {
      gs.addPlayer();
      expect(gs.canUndo, isTrue);
    });

    test('undo after addPlayer restores previous count', () {
      gs.addPlayer();
      gs.undo();
      expect(gs.players.length, 2);
    });
  });

  group('removePlayer', () {
    test('removes a player', () {
      final id = gs.players[0].id;
      gs.removePlayer(id);
      expect(gs.players.length, 1);
    });

    test('does not remove last player', () {
      gs.startGame(playerCount: 1, startingLife: 20);
      gs.removePlayer(gs.players[0].id);
      expect(gs.players.length, 1);
    });

    test('removePlayer pushes history', () {
      gs.removePlayer(gs.players[0].id);
      expect(gs.canUndo, isTrue);
    });

    test('undo after removePlayer restores player', () {
      gs.removePlayer(gs.players[0].id);
      gs.undo();
      expect(gs.players.length, 2);
    });
  });

  group('renamePlayer', () {
    test('renames the correct player', () {
      final id = gs.players[0].id;
      gs.renamePlayer(id, 'Alice');
      expect(gs.players[0].name, 'Alice');
    });

    test('trims whitespace from new name', () {
      final id = gs.players[0].id;
      gs.renamePlayer(id, '  Bob  ');
      expect(gs.players[0].name, 'Bob');
    });

    test('ignores empty name', () {
      final id = gs.players[0].id;
      gs.renamePlayer(id, '   ');
      expect(gs.players[0].name, 'Player 1');
    });

    test('does not push history', () {
      gs.renamePlayer(gs.players[0].id, 'Alice');
      expect(gs.canUndo, isFalse);
    });
  });

  group('history stack cap', () {
    test('history does not exceed 50 entries', () {
      final id = gs.players[0].id;
      for (int i = 0; i < 55; i++) {
        gs.changeLife(id, 1);
      }
      // After 55 changes with a cap of 50 we should have at most 50 history entries.
      // We verify this indirectly: undo 50 times should bring us to some bounded state.
      int undoCount = 0;
      while (gs.canUndo) {
        gs.undo();
        undoCount++;
      }
      expect(undoCount, lessThanOrEqualTo(50));
    });
  });
}
