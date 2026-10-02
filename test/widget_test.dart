import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merimemory/main.dart';
import 'package:merimemory/models/game.dart';
import 'package:merimemory/widgets/memory_card.dart';
import 'package:merimemory/widgets/board_layout.dart';
import 'package:merimemory/services/records.dart';

void main() {
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
    expect(find.text('Muy fácil · 5 parejas'), findsOneWidget);
    await tester.ensureVisible(find.text('¡A jugar!'));
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
    expect(Records().get(Difficulty.veryEasy)?.moves, 5);
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
}
