import 'package:flutter/material.dart';

import '../../../../../core/animation/pico_animation_controller.dart';
import '../../../../../core/services/progress_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../features/lesson/data/repositories/mission_repository.dart';
import '../../../../../shared/widgets/character/pico_character.dart';
import '../../../../../shared/widgets/celebration_card.dart';

class LessonCompleteCard extends StatelessWidget {
  const LessonCompleteCard({
    super.key,
    required this.xp,
    required this.courage,
    required this.badge,
    required this.title,
    required this.message,
    this.picoAnimationController,
    this.showChapterSummary = false,
    this.chapterId,
    required this.onPressed,
  });

  final int xp;
  final int courage;
  final String badge;
  final String title;
  final String message;
  final PicoAnimationController? picoAnimationController;
  final bool showChapterSummary;
  final String? chapterId;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CelebrationCard(
          xp: xp,
          courage: courage,
          badge: badge,
          title: title,
          message: message,
          onPressed: onPressed,
          buttonLabel: 'Devam Et',
          showCountUp: false,
        ),
        if (showChapterSummary && chapterId != null) ...[
          const SizedBox(height: 12),
          _ChapterSummaryCard(chapterId: chapterId!),
        ],
        if (picoAnimationController != null) ...[
          const SizedBox(height: 12),
          PicoCharacter(
            size: PicoCharacterSize.small,
            customSize: 68,
            state: PicoCharacterState.talking,
            emotion: PicoEmotion.encourage,
            controller: picoAnimationController,
          ),
        ],
      ],
    );
  }
}

class _ChapterSummaryCard extends StatelessWidget {
  const _ChapterSummaryCard({required this.chapterId});

  final String chapterId;

  Future<_ChapterSummaryViewModel> _loadSummary() async {
    final repository = MissionRepository();
    final progressService = ProgressService(repository: repository);
    final summary = await progressService.summarizeChapter(chapterId);
    final chapters = await repository.loadAvailableChapters();
    return _ChapterSummaryViewModel(
      totalXp: summary.totalXp,
      totalCourage: summary.totalCourage,
      completionPercent: summary.completionPercent,
      badges: summary.badges,
      hasChapter2: chapters.contains('chapter_02'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ChapterSummaryViewModel>(
      future: _loadSummary(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chapter 1 Complete',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SummaryRow(
                label: 'Total XP',
                value: data == null ? '...' : '${data.totalXp}',
              ),
              _SummaryRow(
                label: 'Total Courage',
                value: data == null ? '...' : '${data.totalCourage}',
              ),
              _SummaryRow(
                label: 'Completion',
                value: data == null
                    ? '...'
                    : '${(data.completionPercent * 100).round()}%',
              ),
              _SummaryRow(
                label: 'Badges',
                value: data == null || data.badges.isEmpty
                    ? '...'
                    : data.badges.join(', '),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                data == null
                    ? 'Yeni maceralar seni bekliyor!'
                    : (data.hasChapter2
                          ? 'Chapter 2 unlocked. Yeni maceralar seni bekliyor!'
                          : 'Chapter 2 yakında. Yeni maceralar seni bekliyor!'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterSummaryViewModel {
  const _ChapterSummaryViewModel({
    required this.totalXp,
    required this.totalCourage,
    required this.completionPercent,
    required this.badges,
    required this.hasChapter2,
  });

  final int totalXp;
  final int totalCourage;
  final double completionPercent;
  final List<String> badges;
  final bool hasChapter2;
}
