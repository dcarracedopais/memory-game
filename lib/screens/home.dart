import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/assets.dart';
import '../services/browser.dart';
import '../services/records.dart';
import '../widgets/memory_card.dart';
import '../widgets/board_layout.dart';
import '../widgets/game_background.dart';
import '../widgets/cover.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.faceLoader});
  final Future<List<String>> Function()? faceLoader;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final records = Records();
  Difficulty difficulty = Difficulty.easy;
  List<String> faces = [];
  Map<String, String> letterAudio = {};
  ContentMode mode = ContentMode.letters;
  bool speechNoticeShown = false;
  MemoryGame? game;
  bool loading = true;
  bool showingCover = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await (widget.faceLoader ?? loadFaces)();
    final audio = await loadLetterAudio();
    if (mounted) {
      setState(() {
        faces = loaded;
        letterAudio = audio;
        mode = records.preferredMode;
        _ensureModeAvailable();
        loading = false;
      });
    }
  }

  bool get imagesAvailable => faces.toSet().length >= difficulty.pairs;
  void _ensureModeAvailable() {
    if (mode == ContentMode.images && !imagesAvailable) {
      mode = ContentMode.letters;
    }
    records.rememberMode(mode);
  }

  void _start() {
    if (loading || (mode == ContentMode.images && !imagesAvailable)) return;
    stopAudio();
    game?.dispose();
    setState(() {
      showingCover = false;
      game = MemoryGame(difficulty, faces, mode: mode);
    });
  }

  void _menu() {
    stopAudio();
    game?.dispose();
    setState(() {
      game = null;
      showingCover = false;
    });
  }

  @override
  void dispose() {
    stopAudio();
    game?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: showingCover,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) return;
      if (game != null) {
        _menu();
      } else {
        setState(() => showingCover = true);
      }
    },
    child: Scaffold(
      body: GameBackground(
        quiet: game != null,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 500;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: game == null ? 620 : 1100,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 8 : 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (!showingCover && game == null)
                              IconButton(
                                tooltip: 'Volver a la portada',
                                onPressed: () =>
                                    setState(() => showingCover = true),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                            if (!showingCover) ...[
                              const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF7961BC),
                              ),
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
                            ] else
                              const Spacer(),
                            IconButton(
                              tooltip: records.sound
                                  ? 'Desactivar sonido'
                                  : 'Activar sonido',
                              onPressed: () {
                                setState(records.toggleSound);
                                if (!records.sound) stopAudio();
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
                        SizedBox(height: compact ? 4 : 12),
                        Expanded(
                          child: game == null
                              ? showingCover
                                    ? _centeredContent(
                                        GameCover(
                                          onPlay: () => setState(
                                            () => showingCover = false,
                                          ),
                                        ),
                                      )
                                    : _menuBody()
                              : ListenableBuilder(
                                  listenable: game!,
                                  builder: (_, _) => _gameBody(game!),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  Widget _centeredContent(Widget child, {double verticalPadding = 16}) =>
      LayoutBuilder(
        builder: (_, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                child: child,
              ),
            ),
          ),
        ),
      );
  Widget _menuBody() => _centeredContent(
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Elige tu reto',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text(
            'Una nueva aventura en cada partida.',
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
                onTap: () => setState(() {
                  difficulty = level;
                  _ensureModeAvailable();
                }),
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
        _contentOptions(),
        const SizedBox(height: 12),
        Text(
          '${difficulty.label} · ${difficulty.pairs} parejas · ${mode.label}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: loading || (mode == ContentMode.images && !imagesAvailable)
              ? null
              : _start,
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
  Widget _contentOptions() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '¿Con qué jugamos?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final option in ContentMode.values) ...[
                if (option == ContentMode.images) const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    selected: mode == option,
                    child: OutlinedButton.icon(
                      key: ValueKey('mode-${option.name}'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: mode == option
                            ? const Color(0xFFECE3FA)
                            : null,
                      ),
                      onPressed:
                          loading ||
                              (option == ContentMode.images && !imagesAvailable)
                          ? null
                          : () => setState(() {
                              mode = option;
                              records.rememberMode(mode);
                            }),
                      icon: Icon(
                        option == ContentMode.letters
                            ? Icons.abc_rounded
                            : Icons.image_outlined,
                      ),
                      label: Text(option.label),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            loading
                ? 'Preparando las opciones…'
                : faces.isEmpty
                ? 'Jugamos con letras. Las imágenes aún no están disponibles.'
                : !imagesAvailable
                ? 'Jugamos con letras: hay ${faces.length} imágenes y este reto necesita ${difficulty.pairs}.'
                : 'Elige letras o imágenes para este reto.',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    ),
  );

  String _recordText(Difficulty level) {
    final r = records.get(level, mode);
    return r == null
        ? 'Tu primer récord te espera'
        : 'Récords: ${formatTime(Duration(milliseconds: r.milliseconds))} · ${r.moves} movimientos';
  }

  Widget _gameBody(MemoryGame g) {
    if (g.phase == Phase.won) {
      return _centeredContent(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: _victory(g),
        ),
      );
    }
    return LayoutBuilder(
      builder: (_, constraints) {
        final landscape =
            constraints.maxWidth >= 650 && constraints.maxHeight < 440;
        final stats = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .75),
            borderRadius: BorderRadius.circular(20),
          ),
          child: landscape
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _railStat(
                      Icons.timer_outlined,
                      formatTime(g.elapsed),
                      'Tiempo',
                    ),
                    _railStat(
                      Icons.touch_app_outlined,
                      '${g.moves}',
                      'Movimientos',
                    ),
                    _railStat(
                      Icons.favorite_border,
                      '${g.found}/${g.difficulty.pairs}',
                      'Parejas',
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _stat(
                        Icons.timer_outlined,
                        formatTime(g.elapsed),
                        'Tiempo',
                      ),
                    ),
                    Expanded(
                      child: _stat(
                        Icons.touch_app_outlined,
                        '${g.moves}',
                        'Movimientos',
                      ),
                    ),
                    Expanded(
                      child: _stat(
                        Icons.favorite_border,
                        '${g.found}/${g.difficulty.pairs}',
                        'Parejas',
                      ),
                    ),
                  ],
                ),
        );
        final status = Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              g.phase == Phase.memorizing
                  ? '¡Memoriza! ${g.countdown} segundos'
                  : g.phase == Phase.hiding
                  ? 'Preparados…'
                  : g.busy
                  ? 'Mira las cartas…'
                  : 'Encuentra las parejas',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF605076),
              ),
              semanticsLabel: g.phase == Phase.memorizing
                  ? 'Memoriza durante cinco segundos'
                  : null,
            ),
          ),
        );
        final menu = OutlinedButton.icon(
          onPressed: _menu,
          icon: const Icon(Icons.home_outlined),
          label: const Text('Menú'),
        );
        final restart = FilledButton.icon(
          onPressed: () {
            stopAudio();
            g.restart();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reiniciar'),
        );
        final board = ResponsiveBoard(
          count: g.cards.length,
          itemBuilder: (_, index) => CardTile(
            key: ValueKey('card-$index'),
            card: g.cards[index],
            index: index,
            enabled: !g.busy && g.phase == Phase.playing,
            onTap: () => _select(g, index),
          ),
        );
        if (landscape) {
          return Row(
            children: [
              SizedBox(
                width: 184,
                child: _centeredContent(
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      stats,
                      status,
                      menu,
                      const SizedBox(height: 8),
                      restart,
                    ],
                  ),
                  verticalPadding: 0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: board),
            ],
          );
        }
        return Column(
          children: [
            stats,
            status,
            Expanded(child: board),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: menu),
                const SizedBox(width: 12),
                Expanded(child: restart),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _select(MemoryGame g, int index) async {
    if (!g.canSelect(index)) return;
    // Start in the user gesture; ignore rejected selections and preview cards.
    if (records.sound) {
      if (g.mode == ContentMode.letters) {
        final letter = g.cards[index].face.substring(7);
        final accepted = pronounceLetter(
          letterNames[letter]!,
          letterAudio[letter],
        );
        if (!accepted && !speechNoticeShown) {
          speechNoticeShown = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Este navegador no tiene una voz española disponible. Puedes seguir jugando.',
              ),
            ),
          );
        }
      } else {
        playSound('flip');
      }
    }
    final result = await g.select(index);
    if (!mounted || game != g || result == null) return;
    if (result == 'win') {
      records.save(g);
      setState(() {});
    }
    if (records.sound && result != 'flip') playSound(result);
  }

  Widget _railStat(IconData icon, String value, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF7961BC)),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
  Widget _stat(IconData icon, String value, String label) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
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
      ),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    ],
  );
  Widget _victory(MemoryGame g) => Column(
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
        '${g.difficulty.label} · ${g.mode.label} · ${g.difficulty.pairs} parejas',
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
      OutlinedButton(onPressed: _menu, child: const Text('Elegir dificultad')),
    ],
  );
}
