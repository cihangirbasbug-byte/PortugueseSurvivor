import 'package:flutter/material.dart';

import '../../design_system/animations.dart';
import '../../design_system/colors.dart';
import '../../design_system/durations.dart';
import '../../design_system/radius.dart';
import '../../design_system/shadows.dart';
import '../../design_system/spacing.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFFFDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.statCard,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.compactCard),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: value.toDouble()),
                  duration: AppDurations.progressSlow,
                  curve: AppAnimations.emphasizeIn,
                  builder: (context, animated, _) {
                    return Text(
                      animated.round().toString(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.cardText,
                          ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
