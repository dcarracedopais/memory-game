import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:merimemory/models/game.dart';

void main() {
  Future<void> ready(WidgetTester tester, MemoryGame game) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 320));
  }

  Future<void> choose(WidgetTester tester, MemoryGame game, int index) async {
    game.select(index);
    await tester.pump(const Duration(milliseconds: 320));
  }

  Future<void> resolve(WidgetTester tester, {bool match = true}) async {
    await tester.pump(Duration(milliseconds: match ? 350 : 800));
    await tester.pump(const Duration(milliseconds: 320));
  }

  test('Every difficulty generates exactly two cards per unique face', () {
    for (final difficulty in Difficulty.values) {
      final game = MemoryGame(
        difficulty,
        List.generate(27, (i) => 'image$i'),
        random: Random(4),
      );
      expect(game.cards.length, difficulty.pairs * 2);
      final counts = <String, int>{};
      for (final card in game.cards) {
        counts.update(card.face, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts.length, difficulty.pairs);
      expect(counts.values.every((n) => n == 2), isTrue);
      game.dispose();
    }
  });
  testWidgets(
    'Memory preview, animation locks, same card rejection and mismatch',
    (tester) async {
      final game = MemoryGame(Difficulty.veryEasy, []);
      expect(await game.select(0), isNull);
      expect(game.moves, 0);
      await ready(tester, game);
      expect(game.phase, Phase.playing);
      expect(game.cards.every((c) => !c.revealed), isTrue);
      game.select(0);
      expect(await game.select(1), isNull);
      await tester.pump(const Duration(milliseconds: 320));
      expect(await game.select(0), isNull);
      final different = game.cards.indexWhere(
        (c) => c.face != game.cards[0].face,
      );
      await choose(tester, game, different);
      expect(game.moves, 1);
      expect(await game.select(2), isNull);
      await resolve(tester, match: false);
      expect(game.cards[0].revealed, isFalse);
      expect(game.busy, isFalse);
      expect(game.found, 0);
      game.dispose();
    },
  );
  testWidgets(
    'Matches disappear, victory stops play, restart resets everything',
    (tester) async {
      final game = MemoryGame(Difficulty.veryEasy, []);
      await ready(tester, game);
      for (final face in game.cards.map((c) => c.face).toSet()) {
        final indices = [
          for (var i = 0; i < game.cards.length; i++)
            if (game.cards[i].face == face) i,
        ];
        await choose(tester, game, indices[0]);
        await choose(tester, game, indices[1]);
        await resolve(tester);
        expect(game.cards[indices[0]].matched, isTrue);
      }
      expect(game.phase, Phase.won);
      expect(game.moves, 5);
      expect(game.found, 5);
      expect(await game.select(0), isNull);
      game.restart();
      expect(game.phase, Phase.memorizing);
      expect(game.moves, 0);
      expect(game.found, 0);
      expect(game.elapsed, Duration.zero);
      expect(game.cards.every((c) => !c.matched), isTrue);
      game.dispose();
    },
  );
  testWidgets('Restart cancels pending comparisons', (tester) async {
    final game = MemoryGame(Difficulty.veryEasy, []);
    await ready(tester, game);
    await choose(tester, game, 0);
    final pair = game.cards.indexWhere(
      (c) => c != game.cards[0] && c.face == game.cards[0].face,
    );
    await choose(tester, game, pair);
    game.restart();
    await tester.pump(const Duration(milliseconds: 900));
    expect(game.found, 0);
    expect(game.moves, 0);
    expect(game.phase, Phase.memorizing);
    game.dispose();
  });
}
