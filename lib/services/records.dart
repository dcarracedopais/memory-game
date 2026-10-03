import 'dart:convert';
import '../models/game.dart';
import 'browser.dart';

class Record {
  const Record(this.milliseconds, this.moves);
  final int milliseconds, moves;
}

class Records {
  bool sound = readValue('meri.sound') != 'off';
  bool available = true;
  Record? get(Difficulty difficulty, [ContentMode mode = ContentMode.letters]) {
    try {
      final value = jsonDecode(
        readValue('meri.record.v3.${mode.name}.${difficulty.pairs}') ?? 'null',
      );
      if (value is Map && value['time'] is int && value['moves'] is int) {
        return Record(value['time'] as int, value['moves'] as int);
      }
    } catch (_) {
      /* Ignore invalid old data. */
    }
    return null;
  }

  void save(MemoryGame game) {
    final old = get(game.difficulty, game.mode);
    available = writeValue(
      'meri.record.v3.${game.mode.name}.${game.difficulty.pairs}',
      jsonEncode({
        'time': old == null
            ? game.elapsed.inMilliseconds
            : old.milliseconds < game.elapsed.inMilliseconds
            ? old.milliseconds
            : game.elapsed.inMilliseconds,
        'moves': old == null
            ? game.moves
            : old.moves < game.moves
            ? old.moves
            : game.moves,
      }),
    );
  }

  ContentMode get preferredMode => readValue('meri.mode') == 'images'
      ? ContentMode.images
      : ContentMode.letters;
  void rememberMode(ContentMode mode) {
    writeValue('meri.mode', mode.name);
  }

  void toggleSound() {
    sound = !sound;
    available = writeValue('meri.sound', sound ? 'on' : 'off');
  }
}
