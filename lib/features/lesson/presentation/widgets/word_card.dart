import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class WordCard extends StatelessWidget {
  final String portugueseWord;
  final String turkishMeaning;
  final String hint;

  const WordCard({
    super.key,
    required this.portugueseWord,
    required this.turkishMeaning,
    required this.hint,
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
        children: [
          Text(
            hint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            portugueseWord,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            turkishMeaning,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
