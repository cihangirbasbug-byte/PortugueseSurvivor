import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 86,
    this.color = const Color(0xFF0E8A4B),
  });

  final double progress;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safeValue = progress.clamp(0.0, 1.0);
    final percent = (safeValue * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: 8,
            color: Colors.white.withValues(alpha: 0.65),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: safeValue),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                color: color,
              );
            },
          ),
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E3442),
                ),
          ),
        ],
      ),
    );
  }
}
