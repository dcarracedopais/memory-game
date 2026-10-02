import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merimemory/widgets/board_layout.dart';

void main() {
  for (final count in [10, 20, 30, 40]) {
    for (final size in [
      const Size(280, 260),
      const Size(350, 570),
      const Size(730, 740),
      const Size(1050, 640),
      const Size(620, 310),
    ]) {
      test('$count cards fit $size with consistent proportions', () {
        final layout = BoardLayout.calculate(count, size);
        expect(layout.columns * layout.rows, greaterThanOrEqualTo(count));
        expect(layout.width, lessThanOrEqualTo(size.width + .001));
        expect(layout.height, lessThanOrEqualTo(size.height + .001));
        expect(
          layout.cardWidth,
          inInclusiveRange(32, BoardLayout.maxCardWidth),
        );
        expect(layout.cardWidth / layout.cardHeight, closeTo(.88, .001));
      });
    }
  }
  test('Small boards use height, are centered and adapt to rotation', () {
    final portrait = BoardLayout.calculate(10, const Size(350, 570));
    final landscape = BoardLayout.calculate(10, const Size(620, 310));
    expect(portrait.height, greaterThan(570 * .75));
    expect(landscape.width, greaterThan(620 * .75));
    expect(portrait.rows, greaterThan(landscape.rows));
  });
  test('Extremely short windows retain touch targets with scroll fallback', () {
    final layout = BoardLayout.calculate(40, const Size(300, 80));
    expect(layout.cardWidth, greaterThanOrEqualTo(44));
    expect(layout.height, greaterThan(80));
    expect(layout.width, lessThanOrEqualTo(300));
  });
}
