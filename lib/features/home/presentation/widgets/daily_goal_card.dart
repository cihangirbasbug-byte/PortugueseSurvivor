import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'progress_section.dart';

class DailyGoalCard extends StatelessWidget {
  final double progress;
  final int completed;
  final int target;

  const DailyGoalCard({
    super.key,
    required this.progress,
    required this.completed,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günün Hedefi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bugün 25 dersten 18 tanesini tamamladın.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProgressSection(
            label: 'Progress',
            value: progress,
            trailing: '$completed/$target',
          ),
          const SizedBox(height: 12),
          Text(
            '$completed / $target derse ulaştın.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
