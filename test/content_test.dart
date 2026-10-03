import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:merimemory/models/game.dart';

class NoSwapsRandom implements Random {
  @override
  int nextInt(int max) => max - 1;
  @override
  bool nextBool() => true;
  @override
  double nextDouble() => .5;
}

class MoveLastRandom extends NoSwapsRandom {
  @override
  int nextInt(int max) => 0;
}

void main() {
  test('Exactly three levels: 6, 10, 15 pairs', () {
    expect(Difficulty.values.map((d) => d.pairs), orderedEquals([6, 10, 15]));
    expect(
      Difficulty.values.map((d) => d.label),
      orderedEquals(['Fácil', 'Normal', 'Difícil']),
    );
  });
  test('Spanish alphabet includes Ñ once, with explicit correct names', () {
    expect(letterNames.keys.join(), 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ');
    expect(letterNames.length, 27);
    expect(letterNames['H'], 'hache');
    expect(letterNames['J'], 'jota');
    expect(letterNames['Ñ'], 'eñe');
    expect(letterNames['R'], 'erre');
    expect(letterNames['W'], 'uve doble');
    expect(letterNames['Y'], 'ye');
    expect(letterAudioFiles.keys, orderedEquals(letterNames.keys));
    expect(letterAudioFiles['Ñ'], 'enye.mp3');
  });
  test(
    'Letter sampling is unique, injectable and not a fixed A.. sequence',
    () {
      for (final level in Difficulty.values) {
        final letters = selectLetters(level.pairs, MoveLastRandom());
        expect(letters.length, level.pairs);
        expect(letters.toSet().length, level.pairs);
        expect(letters.every(letterNames.containsKey), isTrue);
        expect(letters.first, 'B'); // Deterministic shuffle moves A to the end.
        expect(letters, isNot(selectLetters(level.pairs, NoSwapsRandom())));
      }
      expect(selectLetters(15, NoSwapsRandom()), contains('Ñ'));
    },
  );
  test('Letter deck always has exactly two cards per selected letter', () {
    final game = MemoryGame(Difficulty.hard, [], random: NoSwapsRandom());
    expect(game.cards.length, 30);
    final faces = game.cards.map((c) => c.face).toSet();
    expect(faces, contains('letter:Ñ'));
    expect(faces.length, 15);
    for (final face in faces) {
      expect(game.cards.where((c) => c.face == face).length, 2);
    }
    game.dispose();
  });
  test(
    'Images never use letters, require enough distinct images and support restart',
    () {
      for (final images in [
        <String>[],
        ['one'],
        List.filled(20, 'same'),
      ]) {
        expect(
          () => MemoryGame(Difficulty.easy, images, mode: ContentMode.images),
          throwsStateError,
        );
      }
      final images = List.generate(6, (i) => 'photo-$i.png');
      final game = MemoryGame(
        Difficulty.easy,
        images,
        mode: ContentMode.images,
        random: Random(4),
      );
      expect(game.cards.length, 12);
      expect(game.cards.every((c) => images.contains(c.face)), isTrue);
      game.restart();
      expect(game.mode, ContentMode.images);
      expect(game.moves, 0);
      expect(
        () => MemoryGame(Difficulty.hard, images, mode: ContentMode.images),
        throwsStateError,
      );
      game.dispose();
    },
  );
  test('Same random seed reproduces a deck, subsequent games sample again', () {
    final game = MemoryGame(Difficulty.easy, [], random: Random(25));
    final twin = MemoryGame(Difficulty.easy, [], random: Random(25));
    final original = game.cards.map((c) => c.face).toList();
    expect(twin.cards.map((c) => c.face), orderedEquals(original));
    game.restart();
    // Fixed seed gives a reproducible different result, no probabilistic test.
    expect(game.cards.map((c) => c.face).toList(), isNot(original));
    game.dispose();
    twin.dispose();
  });
}
