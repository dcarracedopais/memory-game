import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merimemory/main.dart';
import 'package:merimemory/models/game.dart';
import 'package:merimemory/widgets/memory_card.dart';
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
    expect(find.text('Muy fácil · 5 parejas'), findsOneWidget);
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
    expect(tester.takeException(), isNull);
  });
  for (final size in [
    const Size(320, 568),
    const Size(768, 1024),
    const Size(1440, 900),
  ]) {
    testWidgets('Hard board fits $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MeriMemory());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Difícil · 20 parejas'));
      await tester.tap(find.text('Difícil · 20 parejas'));
      await tester.pump();
      await tester.ensureVisible(find.text('¡A jugar!'));
      await tester.tap(find.text('¡A jugar!'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Menú'));
      await tester.pumpAndSettle();
    });
  }
}
