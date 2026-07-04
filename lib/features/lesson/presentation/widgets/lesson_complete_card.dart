import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class LessonCompleteCard extends StatelessWidget {
  final int xp;
  final VoidCallback onPressed;

  const LessonCompleteCard({
    super.key,
    required this.xp,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.celebration_rounded,
            size: 56,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Ders Tamamlandı',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tebrikler!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Kazandın: +$xp XP',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('Sonraki Ders'),
          ),
        ],
      ),
    );
  }
}
