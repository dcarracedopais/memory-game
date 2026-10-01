import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/assets.dart';
import '../services/browser.dart';
import '../services/records.dart';
import '../widgets/memory_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final records = Records();
  Difficulty difficulty = Difficulty.veryEasy;
  List<String> faces = [];
  MemoryGame? game;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await loadFaces();
    if (mounted) {
      setState(() {
        faces = loaded;
        loading = false;
      });
    }
  }

  void _start() {
    game?.dispose();
    setState(() {
      game = MemoryGame(difficulty, faces);
    });
  }

  void _menu() {
    game?.dispose();
    setState(() {
      game = null;
    });
  }

  @override
  void dispose() {
    game?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF7961BC)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'MeriMemory',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 23,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: records.sound
                          ? 'Desactivar sonido'
                          : 'Activar sonido',
                      onPressed: () {
                        setState(records.toggleSound);
                        if (records.sound) playSound('flip');
                      },
                      icon: Icon(
                        records.sound
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: game == null
                      ? _menuBody()
                      : ListenableBuilder(
                          listenable: game!,
                          builder: (_, _) => _gameBody(game!),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Widget _menuBody() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 30),
        const Icon(Icons.favorite_rounded, size: 64, color: Color(0xFFE99794)),
        const SizedBox(height: 16),
        const Text(
          'Un ratito para jugar',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text(
            'Mira, recuerda y encuentra las parejas.\n¡Cada partida es una nueva aventura!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
        for (final level in Difficulty.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              color: difficulty == level
                  ? const Color(0xFFECE3FA)
                  : Colors.white,
              child: ListTile(
                minVerticalPadding: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onTap: () => setState(() => difficulty = level),
                leading: Icon(
                  difficulty == level
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: const Color(0xFF7961BC),
                ),
                title: Text(
                  '${level.label} · ${level.pairs} parejas',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_recordText(level)),
              ),
            ),
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: loading ? null : _start,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(loading ? 'Preparando cartas…' : '¡A jugar!'),
        ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Tendrás 5 segundos para memorizar las cartas.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
  String _recordText(Difficulty level) {
    final r = records.get(level);
    return r == null
        ? 'Tu primer récord te espera'
        : 'Récords: ${formatTime(Duration(milliseconds: r.milliseconds))} · ${r.moves} movimientos';
  }

  Widget _gameBody(MemoryGame g) {
    if (g.phase == Phase.won) return _victory(g);
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 8,
          children: [
            _stat(Icons.timer_outlined, formatTime(g.elapsed), 'Tiempo'),
            _stat(Icons.touch_app_outlined, '${g.moves}', 'Movimientos'),
            _stat(
              Icons.favorite_border,
              '${g.found}/${g.difficulty.pairs}',
              'Parejas',
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            g.phase == Phase.memorizing
                ? '¡Memoriza! ${g.countdown} segundos'
                : g.phase == Phase.hiding
                ? 'Preparados…'
                : g.busy
                ? 'Mira las cartas…'
                : 'Encuentra las parejas',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            semanticsLabel: g.phase == Phase.memorizing
                ? 'Memoriza durante cinco segundos'
                : null,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 380
                  ? 4
                  : constraints.maxWidth < 600
                  ? 5
                  : 8;
              return GridView.builder(
                key: const ValueKey('board'),
                itemCount: g.cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: .88,
                ),
                itemBuilder: (_, index) => CardTile(
                  key: ValueKey('card-$index'),
                  card: g.cards[index],
                  index: index,
                  enabled: !g.busy && g.phase == Phase.playing,
                  onTap: () => _select(g, index),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _menu,
                icon: const Icon(Icons.home_outlined),
                label: const Text('Menú'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: g.restart,
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _select(MemoryGame g, int index) async {
    // Audio starts in the user gesture so mobile browsers can unlock it.
    if (records.sound) playSound('flip');
    final result = await g.select(index);
    if (!mounted || game != g || result == null) return;
    if (result == 'win') {
      records.save(g);
      setState(() {});
    }
    if (records.sound && result != 'flip') playSound(result);
  }

  Widget _stat(IconData icon, String value, String label) => Column(
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF7961BC)),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
  Widget _victory(MemoryGame g) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: .3, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.elasticOut,
          builder: (_, value, child) =>
              Transform.scale(scale: value, child: child),
          child: const Text(
            '✨ 🏆 ✨',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 64),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          '¡Lo has conseguido!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'Todas las parejas de ${g.difficulty.label.toLowerCase()}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '${g.score} puntos',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7961BC),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tiempo: ${formatTime(g.elapsed)}\nMovimientos: ${g.moves}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, height: 1.7),
                ),
                const SizedBox(height: 16),
                Text(
                  records.available
                      ? _recordText(g.difficulty)
                      : 'El navegador no permite guardar récords en este momento.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.replay),
          label: const Text('Jugar otra vez'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _menu,
          child: const Text('Elegir dificultad'),
        ),
      ],
    ),
  );
}
