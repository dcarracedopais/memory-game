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
  Record? get(Difficulty difficulty) {
    try {
      final value = jsonDecode(
        readValue('meri.record.${difficulty.name}') ?? 'null',
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
    final old = get(game.difficulty);
    available = writeValue(
      'meri.record.${game.difficulty.name}',
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

  void toggleSound() {
    sound = !sound;
    available = writeValue('meri.sound', sound ? 'on' : 'off');
  }
}
