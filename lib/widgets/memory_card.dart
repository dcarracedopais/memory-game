import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game.dart';

class CardTile extends StatelessWidget {
  const CardTile({
    super.key,
    required this.card,
    required this.index,
    required this.enabled,
    required this.onTap,
  });
  final MemoryCard card;
  final int index;
  final bool enabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !enabled || card.matched,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: card.matched ? 0 : 1,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: card.matched ? .5 : 1,
        child: Semantics(
          button: true,
          label: card.matched
              ? 'Pareja encontrada'
              : card.revealed
              ? 'Carta ${card.face.split(':').last}'
              : 'Carta ${index + 1} oculta',
          child: GestureDetector(
            onTap: onTap,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: card.revealed ? 1 : 0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, _) {
                final front = value >= .5;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, .001)
                    ..rotateY((front ? value - 1 : value) * pi),
                  child: Container(
                    decoration: BoxDecoration(
                      color: front ? Colors.white : const Color(0xFF8972C1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: front
                            ? const Color(0xFFE4D9F4)
                            : const Color(0xFFB7A3DC),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x147961BC),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: front
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: card.face.startsWith('letter:')
                                ? _letter(card.face.substring(7))
                                : Image.asset(
                                    card.face,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: Color(0xFF7961BC),
                                      ),
                                    ),
                                  ),
                          )
                        : LayoutBuilder(
                            builder: (_, constraints) => Center(
                              child: Icon(
                                Icons.auto_awesome,
                                color: const Color(0xFFFFE9A9),
                                size: (constraints.biggest.shortestSide * .35)
                                    .clamp(20, 56),
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  Widget _letter(String letter) => Center(
    child: FractionallySizedBox(
      widthFactor: .7,
      heightFactor: .7,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            color: Color(0xFF7961BC),
          ),
        ),
      ),
    ),
  );
}
