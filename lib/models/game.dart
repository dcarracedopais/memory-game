import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'content.dart';
export 'content.dart';

enum Difficulty {
  easy('Fácil', 6),
  normal('Normal', 10),
  hard('Difícil', 15);

  const Difficulty(this.label, this.pairs);
  final String label;
  final int pairs;
}

enum Phase { memorizing, hiding, playing, won }

class MemoryCard {
  MemoryCard(this.face);
  final String face;
  bool revealed = true;
  bool matched = false;
}

class MemoryGame extends ChangeNotifier {
  MemoryGame(
    this.difficulty,
    this.faces, {
    this.mode = ContentMode.letters,
    Random? random,
  }) : random = random ?? Random() {
    restart();
  }
  final Difficulty difficulty;
  final List<String> faces;
  final Random random;
  final ContentMode mode;
  late List<MemoryCard> cards;
  Phase phase = Phase.memorizing;
  int moves = 0, found = 0, countdown = 5;
  bool busy = true;
  int? first;
  final Stopwatch watch = Stopwatch();
  Duration get elapsed => watch.elapsed;
  int get score =>
      max(0, difficulty.pairs * 1000 - moves * 50 - elapsed.inSeconds * 5);
  Timer? _timer;
  int _generation = 0;
  bool _disposed = false;
  void restart() {
    _generation++;
    _timer?.cancel();
    watch
      ..stop()
      ..reset();
    final pool = mode == ContentMode.letters
        ? selectLetters(
            difficulty.pairs,
            random,
          ).map((letter) => 'letter:$letter').toList()
        : (faces.toSet().toList()..shuffle(random));
    if (pool.length < difficulty.pairs) {
      throw StateError('No hay suficientes imágenes para esta dificultad.');
    }
    cards = [
      for (final face in pool.take(difficulty.pairs)) ...[
        MemoryCard(face),
        MemoryCard(face),
      ],
    ]..shuffle(random);
    moves = found = 0;
    countdown = 5;
    first = null;
    busy = true;
    phase = Phase.memorizing;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (phase == Phase.memorizing) {
        countdown--;
        if (countdown == 0) {
          _begin();
        }
      }
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> _begin() async {
    final generation = _generation;
    phase = Phase.hiding;
    for (final card in cards) {
      card.revealed = false;
    }
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!_alive(generation)) return;
    phase = Phase.playing;
    busy = false;
    watch.start();
    notifyListeners();
  }

  bool _alive(int generation) => !_disposed && generation == _generation;
  bool canSelect(int index) =>
      phase == Phase.playing &&
      !busy &&
      index >= 0 &&
      index < cards.length &&
      !cards[index].revealed &&
      !cards[index].matched;
  Future<String?> select(int index) async {
    if (!canSelect(index)) return null;
    final generation = _generation;
    busy = true;
    cards[index].revealed = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!_alive(generation)) return null;
    if (first == null) {
      first = index;
      busy = false;
      notifyListeners();
      return 'flip';
    }
    final previous = first!;
    moves++;
    final match = cards[previous].face == cards[index].face;
    await Future<void>.delayed(Duration(milliseconds: match ? 350 : 800));
    if (!_alive(generation)) return null;
    if (match) {
      cards[previous].matched = cards[index].matched = true;
      found++;
    } else {
      cards[previous].revealed = cards[index].revealed = false;
    }
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!_alive(generation)) return null;
    first = null;
    busy = false;
    if (found == difficulty.pairs) {
      phase = Phase.won;
      watch.stop();
      _timer?.cancel();
    }
    notifyListeners();
    return phase == Phase.won
        ? 'win'
        : match
        ? 'match'
        : 'miss';
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _timer?.cancel();
    watch.stop();
    super.dispose();
  }
}

String formatTime(Duration duration) =>
    '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
