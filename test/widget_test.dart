import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merimemory/main.dart';
import 'package:merimemory/models/game.dart';
import 'package:merimemory/widgets/memory_card.dart';
import 'package:merimemory/widgets/board_layout.dart';
import 'package:merimemory/services/records.dart';
import 'package:merimemory/services/browser.dart';
import 'package:merimemory/screens/home.dart';

void main() {
  setUp(() {
    writeValue('meri.mode', 'letters');
    writeValue('meri.sound', 'off');
  });
  testWidgets('Full mobile flow saves records and starts another game', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MeriMemory());
    await tester.pumpAndSettle();
    expect(find.text('Jugar'), findsOneWidget);
    await tester.tap(find.text('Jugar'));
    await tester.pumpAndSettle();
    expect(find.text('Fácil · 6 parejas'), findsOneWidget);
    await tester.ensureVisible(find.text('¡A jugar!'));
    await tester.tap(find.text('¡A jugar!'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 400));
    final tiles = tester.widgetList<CardTile>(find.byType(CardTile)).toList();
    for (final face in tiles.map((t) => t.card.face).toSet()) {
      final pair = tiles.where((t) => t.card.face == face).toList();
      for (final tile in pair) {
        final finder = find.byKey(ValueKey('card-${tile.index}'));
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pump(const Duration(milliseconds: 320));
      }
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 320));
      await tester.pump();
    }
    expect(find.text('¡Lo has conseguido!'), findsOneWidget);
    expect(Records().get(Difficulty.easy)?.moves, 6);
    await tester.ensureVisible(find.text('Jugar otra vez'));
    await tester.tap(find.text('Jugar otra vez'));
    await tester.pump();
    expect(find.text('¡Memoriza! 5 segundos'), findsOneWidget);
    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();
    expect(find.text('¡A jugar!'), findsOneWidget);
    await tester.tap(find.byTooltip('Volver a la portada'));
    await tester.pumpAndSettle();
    expect(find.text('Jugar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(768, 1024),
    const Size(1440, 900),
    const Size(844, 390),
  ]) {
    for (final difficulty in Difficulty.values) {
      testWidgets('${difficulty.label} board fits $size and remains centered', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const MeriMemory());
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Jugar'));
        await tester.tap(find.text('Jugar'));
        await tester.pumpAndSettle();
        final option = find.text(
          '${difficulty.label} · ${difficulty.pairs} parejas',
        );
        await tester.ensureVisible(option);
        await tester.tap(option);
        await tester.pump();
        await tester.ensureVisible(find.text('¡A jugar!'));
        await tester.ensureVisible(find.text('¡A jugar!'));
        await tester.tap(find.text('¡A jugar!'));
        await tester.pump();
        expect(find.byType(CardTile), findsNWidgets(difficulty.pairs * 2));
        final area = tester.getRect(find.byType(ResponsiveBoard));
        final board = tester.getRect(find.byKey(const ValueKey('board')));
        expect(board.center.dx, closeTo(area.center.dx, 1));
        expect(board.center.dy, closeTo(area.center.dy, 1));
        expect(board.left, greaterThanOrEqualTo(area.left));
        expect(board.right, lessThanOrEqualTo(area.right + .01));
        expect(board.top, greaterThanOrEqualTo(area.top));
        expect(board.bottom, lessThanOrEqualTo(area.bottom + .01));
        final restart = tester.getRect(
          find.widgetWithText(FilledButton, 'Reiniciar'),
        );
        expect(restart.bottom, lessThanOrEqualTo(size.height));
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Menú'));
        await tester.pumpAndSettle();
      });
    }
  }
  testWidgets('Rotation preserves the current game and card slots', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MeriMemory());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jugar'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('¡A jugar!'));
    await tester.tap(find.text('¡A jugar!'));
    await tester.pump();
    final before = tester
        .widgetList<CardTile>(find.byType(CardTile))
        .map((t) => t.card)
        .toList();
    tester.view.physicalSize = const Size(844, 390);
    await tester.pump();
    final after = tester
        .widgetList<CardTile>(find.byType(CardTile))
        .map((t) => t.card)
        .toList();
    expect(after, orderedEquals(before));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();
  });
  testWidgets(
    'Without images, only letters are selectable and stored images reset',
    (tester) async {
      writeValue('meri.mode', 'images');
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(faceLoader: () async => [])),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jugar'));
      await tester.pumpAndSettle();
      final images = tester.widget<OutlinedButton>(
        find.byKey(const ValueKey('mode-images')),
      );
      expect(images.onPressed, isNull);
      expect(
        find.text('Jugamos con letras. Las imágenes aún no están disponibles.'),
        findsOneWidget,
      );
      expect(Records().preferredMode, ContentMode.letters);
      await tester.ensureVisible(find.text('¡A jugar!'));
      await tester.tap(find.text('¡A jugar!'));
      await tester.pump();
      expect(
        tester
            .widgetList<CardTile>(find.byType(CardTile))
            .every((c) => c.card.face.startsWith('letter:')),
        isTrue,
      );
      await tester.tap(find.text('Menú'));
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'Six images enable Easy, disabling larger levels resets to letters',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            faceLoader: () async =>
                List.generate(6, (i) => 'assets/cards/photo$i.png'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jugar'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Imágenes'));
      await tester.tap(find.text('Imágenes'));
      await tester.pump();
      expect(Records().preferredMode, ContentMode.images);
      await tester.ensureVisible(find.text('¡A jugar!'));
      await tester.tap(find.text('¡A jugar!'));
      await tester.pump();
      expect(
        tester
            .widgetList<CardTile>(find.byType(CardTile))
            .every((c) => !c.card.face.startsWith('letter:')),
        isTrue,
      );
      await tester.tap(find.text('Reiniciar'));
      await tester.pump();
      expect(find.byType(CardTile), findsNWidgets(12));
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 400));
      final cards = tester.widgetList<CardTile>(find.byType(CardTile)).toList();
      for (final face in cards.map((c) => c.card.face).toSet()) {
        for (final card in cards.where((c) => c.card.face == face)) {
          await tester.tap(find.byKey(ValueKey('card-${card.index}')));
          await tester.pump(const Duration(milliseconds: 320));
        }
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump(const Duration(milliseconds: 320));
        await tester.pump();
      }
      expect(find.text('¡Lo has conseguido!'), findsOneWidget);
      expect(Records().get(Difficulty.easy, ContentMode.images)?.moves, 6);
      await tester.ensureVisible(find.text('Jugar otra vez'));
      await tester.tap(find.text('Jugar otra vez'));
      await tester.pump();
      expect(
        tester
            .widgetList<CardTile>(find.byType(CardTile))
            .every((c) => !c.card.face.startsWith('letter:')),
        isTrue,
      );
      await tester.tap(find.text('Menú'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Difícil · 15 parejas'));
      await tester.tap(find.text('Difícil · 15 parejas'));
      await tester.pump();
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('mode-images')))
            .onPressed,
        isNull,
      );
      expect(Records().preferredMode, ContentMode.letters);
      expect(
        find.text(
          'Jugamos con letras: hay 6 imágenes y este reto necesita 15.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
