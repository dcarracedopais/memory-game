import 'package:flutter_test/flutter_test.dart';
import 'package:merimemory/models/game.dart';
import 'package:merimemory/services/browser.dart';
import 'package:merimemory/services/records.dart';

void main() {
  test(
    'Records keep independent minima and survive a new service instance',
    () {
      writeValue('meri.record.hard', '{"time":1000,"moves":30}');
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
    writeValue('meri.record.medium', 'invalid');
    expect(Records().get(Difficulty.medium), isNull);
  });
}
