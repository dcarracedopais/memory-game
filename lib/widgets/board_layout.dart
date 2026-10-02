import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Fits a stable board to both dimensions; matching cards keep their slots.
class BoardLayout {
  const BoardLayout(this.columns, this.rows, this.cardWidth, this.gap);
  final int columns, rows;
  final double cardWidth, gap;
  static const aspectRatio = .88;
  static const maxCardWidth = 190.0;
  double get cardHeight => cardWidth / aspectRatio;
  double get width => columns * cardWidth + (columns - 1) * gap;
  double get height => rows * cardHeight + (rows - 1) * gap;

  static BoardLayout calculate(int count, Size available) {
    assert(count > 0 && available.width > 0 && available.height > 0);
    final gap = available.shortestSide < 350 ? 6.0 : 12.0;
    BoardLayout? best;
    double bestScore = -1;
    for (var columns = 1; columns <= count; columns++) {
      final rows = (count / columns).ceil();
      final width = math.min(
        maxCardWidth,
        math.min(
          (available.width - (columns - 1) * gap) / columns,
          (available.height - (rows - 1) * gap) / rows * aspectRatio,
        ),
      );
      if (width <= 0) continue;
      // Prefer large cards, with a small penalty for incomplete last rows.
      final score = width * width * count / (columns * rows);
      if (score > bestScore) {
        bestScore = score;
        best = BoardLayout(columns, rows, width, gap);
      }
    }
    if (best != null && best.cardWidth >= 32) return best;
    // Only unusually tiny windows need scrolling; retain usable card targets.
    final columns = math.max(
      1,
      math.min(count, ((available.width + gap) / (44 + gap)).floor()),
    );
    final width = math.min(
      maxCardWidth,
      math.max(1.0, (available.width - (columns - 1) * gap) / columns),
    );
    return BoardLayout(columns, (count / columns).ceil(), width, gap);
  }
}

class ResponsiveBoard extends StatelessWidget {
  const ResponsiveBoard({
    super.key,
    required this.count,
    required this.itemBuilder,
  });
  final int count;
  final IndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Insets leave room for the existing card shadows and match animation.
      final space = Size(
        math.max(1, constraints.maxWidth - 8),
        math.max(1, constraints.maxHeight - 8),
      );
      final layout = BoardLayout.calculate(count, space);
      final board = SizedBox(
        key: const ValueKey('board'),
        width: layout.width,
        height: layout.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var row = 0; row < layout.rows; row++) ...[
              if (row > 0) SizedBox(height: layout.gap),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (
                    var column = 0;
                    column < layout.columns &&
                        row * layout.columns + column < count;
                    column++
                  ) ...[
                    if (column > 0) SizedBox(width: layout.gap),
                    SizedBox(
                      width: layout.cardWidth,
                      height: layout.cardHeight,
                      child: itemBuilder(
                        context,
                        row * layout.columns + column,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      );
      return Padding(
        padding: const EdgeInsets.all(4),
        child: layout.height <= space.height + .01
            ? Center(child: board)
            : SingleChildScrollView(child: Center(child: board)),
      );
    },
  );
}
