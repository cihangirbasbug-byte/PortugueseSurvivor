import 'package:flutter/material.dart';

import '../../core/theme/app_shadows.dart';

class PicoAvatar extends StatelessWidget {
  const PicoAvatar({
    super.key,
    this.size = 100,
    this.animate = false,
  });

  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: AppShadows.soft,
      ),
      child: const Center(
        child: Text('🦜', style: TextStyle(fontSize: 50)),
      ),
    );

    if (!animate) {
      return avatar;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeInOut,
      builder: (context, progress, child) {
        final flyInX = (1 - progress) * -72;
        final lookAround = progress > 0.45 ? (progress - 0.45) * 0.09 : 0.0;
        final smileScale = progress > 0.62 ? 1 + ((progress - 0.62) * 0.08) : 1.0;
        final waveY = progress > 0.72 ? ((progress - 0.72) * 9) : 0.0;
        final flap = progress > 0.82 ? ((progress - 0.82) * 0.20) : 0.0;

        return Transform.translate(
          offset: Offset(flyInX, waveY),
          child: Transform.scale(
            scale: smileScale,
            child: Transform.rotate(
              angle: lookAround + flap,
              child: child,
            ),
          ),
        );
      },
      child: avatar,
    );
  }
}
