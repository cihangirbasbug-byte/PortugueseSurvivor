import 'package:flutter/material.dart';

import '../../design_system/animations.dart';
import '../../design_system/colors.dart';
import '../../design_system/durations.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 86,
    this.color = AppColors.primary,
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
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          CircularProgressIndicator(
            value: 1,
            strokeWidth: 8,
            color: AppColors.surface.withValues(alpha: 0.65),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: safeValue),
            duration: AppDurations.progress,
            curve: AppAnimations.emphasizeIn,
            builder: (context, value, _) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                color: color,
              );
            },
          ),
          Container(
            width: size - 24,
            height: size - 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withValues(alpha: 0.82),
            ),
          ),
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.speechText,
            ),
          ),
        ],
      ),
    );
  }
}
