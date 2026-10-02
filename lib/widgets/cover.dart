import 'package:flutter/material.dart';

class GameCover extends StatelessWidget {
  const GameCover({super.key, required this.onPlay});
  final VoidCallback onPlay;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TweenAnimationBuilder<double>(
        tween: Tween(begin: .94, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (_, value, child) =>
            Transform.scale(scale: value, child: child),
        child: const SizedBox(
          height: 160,
          width: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 30,
                top: 20,
                child: _CoverCard(
                  angle: -.18,
                  color: Color(0xFF8972C1),
                  icon: Icons.auto_awesome_rounded,
                ),
              ),
              Positioned(
                right: 30,
                top: 12,
                child: _CoverCard(
                  angle: .15,
                  color: Colors.white,
                  icon: Icons.favorite_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'MeriMemory',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
            color: Color(0xFF67509F),
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Pequeños momentos, grandes recuerdos.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, height: 1.5, color: Color(0xFF60576E)),
      ),
      const SizedBox(height: 36),
      SizedBox(
        width: 300,
        child: FilledButton.icon(
          key: const ValueKey('cover-play'),
          onPressed: onPlay,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Jugar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Mira · Recuerda · Encuentra',
        style: TextStyle(fontSize: 14, color: Color(0xFF736A80)),
      ),
    ],
  );
}

class _CoverCard extends StatelessWidget {
  const _CoverCard({
    required this.angle,
    required this.color,
    required this.icon,
  });
  final double angle;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: Container(
      width: 100,
      height: 130,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3D8EF), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x227961BC),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 46,
        color: color == Colors.white
            ? const Color(0xFFE99794)
            : const Color(0xFFFFE9A9),
      ),
    ),
  );
}
