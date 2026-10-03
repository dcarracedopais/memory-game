import 'dart:math';

enum ContentMode {
  letters('Letras'),
  images('Imágenes');

  const ContentMode(this.label);
  final String label;
}

// Names, not raw characters, are passed to the speech engine.
const letterNames = <String, String>{
  'A': 'a',
  'B': 'be',
  'C': 'ce',
  'D': 'de',
  'E': 'e',
  'F': 'efe',
  'G': 'ge',
  'H': 'hache',
  'I': 'i',
  'J': 'jota',
  'K': 'ka',
  'L': 'ele',
  'M': 'eme',
  'N': 'ene',
  'Ñ': 'eñe',
  'O': 'o',
  'P': 'pe',
  'Q': 'cu',
  'R': 'erre',
  'S': 'ese',
  'T': 'te',
  'U': 'u',
  'V': 'uve',
  'W': 'uve doble',
  'X': 'equis',
  'Y': 'ye',
  'Z': 'zeta',
};
const letterAudioFiles = <String, String>{
  'A': 'a.mp3',
  'B': 'b.mp3',
  'C': 'c.mp3',
  'D': 'd.mp3',
  'E': 'e.mp3',
  'F': 'f.mp3',
  'G': 'g.mp3',
  'H': 'h.mp3',
  'I': 'i.mp3',
  'J': 'j.mp3',
  'K': 'k.mp3',
  'L': 'l.mp3',
  'M': 'm.mp3',
  'N': 'n.mp3',
  'Ñ': 'enye.mp3',
  'O': 'o.mp3',
  'P': 'p.mp3',
  'Q': 'q.mp3',
  'R': 'r.mp3',
  'S': 's.mp3',
  'T': 't.mp3',
  'U': 'u.mp3',
  'V': 'v.mp3',
  'W': 'w.mp3',
  'X': 'x.mp3',
  'Y': 'y.mp3',
  'Z': 'z.mp3',
};

List<String> selectLetters(int count, Random random) {
  if (count < 1 || count > letterNames.length) throw ArgumentError.value(count);
  final alphabet = letterNames.keys.toList()..shuffle(random);
  return alphabet.take(count).toList();
}
