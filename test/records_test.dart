import 'package:flutter_test/flutter_test.dart';
import 'package:merimemory/models/game.dart';
import 'package:merimemory/services/browser.dart';
import 'package:merimemory/services/records.dart';

void main() {
  test(
    'Records keep independent minima and survive a new service instance',
    () {
      writeValue('meri.record.v3.letters.15', '{"time":1000,"moves":30}');
      final game = MemoryGame(Difficulty.hard, []);
      game.moves = 40;
      Records().save(game);
      expect(Records().get(Difficulty.hard)?.moves, 30);
      expect(Records().get(Difficulty.hard)?.milliseconds, 0);
      game.moves = 20;
      Records().save(game);
      expect(Records().get(Difficulty.hard)?.moves, 20);
      game.dispose();
    },
  );
  test('Sound preference persists; invalid records are ignored', () {
    writeValue('meri.sound', 'on');
    final records = Records();
    records.toggleSound();
    expect(Records().sound, isFalse);
    writeValue('meri.record.v3.letters.10', 'invalid');
    expect(Records().get(Difficulty.normal), isNull);
  });
  test('Records are separated by mode and old configurations ignored', () {
    writeValue('meri.record.easy', '{"time":1,"moves":1}');
    writeValue('meri.record.v3.letters.6', 'null');
    writeValue('meri.record.v3.images.6', 'null');
    expect(Records().get(Difficulty.easy), isNull);
    final game = MemoryGame(
      Difficulty.easy,
      List.generate(6, (i) => 'image$i'),
      mode: ContentMode.images,
    );
    game.moves = 9;
    Records().save(game);
    expect(Records().get(Difficulty.easy, ContentMode.images)?.moves, 9);
    expect(Records().get(Difficulty.easy, ContentMode.letters), isNull);
    Records().rememberMode(ContentMode.images);
    expect(Records().preferredMode, ContentMode.images);
    game.dispose();
  });
}
