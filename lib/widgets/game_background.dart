import 'package:flutter/material.dart';

/// Lightweight decoration: no image downloads, pointer events or semantics.
class GameBackground extends StatelessWidget {
  const GameBackground({super.key, required this.quiet, required this.child});
  final bool quiet;
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: quiet
            ? const [Color(0xFFF5F0FB), Color(0xFFFFFAF2), Color(0xFFEFF7F3)]
            : const [Color(0xFFEDE3F8), Color(0xFFFFF7EC), Color(0xFFE3F3ED)],
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: CustomPaint(painter: _Shapes(quiet)),
            ),
          ),
        ),
        child,
      ],
    ),
  );
}

class _Shapes extends CustomPainter {
  _Shapes(this.quiet);
  final bool quiet;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final scale = size.shortestSide;
    paint.color = const Color(0xFFBCA7DE).withValues(alpha: quiet ? .07 : .15);
    canvas.drawCircle(
      Offset(size.width * .04, size.height * .16),
      scale * .32,
      paint,
    );
    paint.color = const Color(0xFFF2BD9D).withValues(alpha: quiet ? .06 : .17);
    canvas.drawCircle(
      Offset(size.width * .98, size.height * .68),
      scale * .36,
      paint,
    );
    paint.color = const Color(0xFFB1DCC8).withValues(alpha: quiet ? .08 : .23);
    canvas.drawCircle(
      Offset(size.width * .16, size.height * 1.03),
      scale * .30,
      paint,
    );
    if (!quiet) {
      paint.color = const Color(0xFF7961BC).withValues(alpha: .12);
      for (final point in [
        Offset(size.width * .87, size.height * .18),
        Offset(size.width * .12, size.height * .65),
        Offset(size.width * .76, size.height * .86),
      ]) {
        canvas.drawCircle(point, 5, paint);
        canvas.drawLine(
          point + const Offset(-12, 0),
          point + const Offset(12, 0),
          paint..strokeWidth = 2,
        );
        canvas.drawLine(
          point + const Offset(0, -12),
          point + const Offset(0, 12),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_Shapes oldDelegate) => quiet != oldDelegate.quiet;
}
