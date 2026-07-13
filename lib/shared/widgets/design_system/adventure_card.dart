import 'package:flutter/material.dart';

import '../../design_system/animations.dart';
import '../../design_system/colors.dart';
import '../../design_system/durations.dart';
import '../../design_system/radius.dart';
import '../../design_system/shadows.dart';
import '../../design_system/spacing.dart';
import 'primary_button.dart';
import 'reward_chip.dart';

class AdventureCard extends StatelessWidget {
  const AdventureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.progress,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final int xp;
  final double progress;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F8C4D), Color(0xFF4DBA77)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.heroCard(const Color(0xFF0F8C4D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              RewardChip(
                label: '+$xp XP',
                icon: Icons.auto_awesome_rounded,
                backgroundColor: AppColors.surface.withValues(alpha: 0.23),
                foregroundColor: AppColors.surface,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.surface.withValues(alpha: 0.92),
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.headerPadding),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: safeProgress),
              duration: AppDurations.progressMedium,
              curve: AppAnimations.emphasizeIn,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 9,
                  backgroundColor: AppColors.surface.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.surface,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              label: 'Basla',
              onPressed: onPressed,
              icon: Icons.rocket_launch_rounded,
              expand: false,
              invertColors: true,
            ),
          ),
        ],
      ),
    );
  }
}
