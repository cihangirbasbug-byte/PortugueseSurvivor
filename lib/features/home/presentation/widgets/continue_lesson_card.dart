import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import 'progress_section.dart';

class ContinueLessonCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final double progress;
  final int xp;
  final String missionId;
  final VoidCallback? onMissionCompleted;

  const ContinueLessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.xp,
    required this.missionId,
    this.onMissionCompleted,
  });

  @override
  State<ContinueLessonCard> createState() => _ContinueLessonCardState();
}

class _ContinueLessonCardState extends State<ContinueLessonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 430;

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: isCompact
              ? _buildCompactLayout(context)
              : _buildRegularLayout(context),
        );
      },
    );
  }

  Widget _buildRegularLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStartIcon(),
        const SizedBox(width: 14),
        Expanded(child: _buildMainContent(context)),
        const SizedBox(width: 12),
        _buildActions(context),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStartIcon(),
            const SizedBox(width: 14),
            Expanded(child: _buildMainContent(context)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildXpPill(context), _buildContinueButton(context)],
        ),
      ],
    );
  }

  Widget _buildStartIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.play_circle_fill_rounded,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 14),
        ProgressSection(
          label: 'Sonraki görev',
          value: widget.progress,
          trailing: '${(widget.progress * 100).round()}%',
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _buildXpPill(context),
        const SizedBox(height: 10),
        _buildContinueButton(context),
      ],
    );
  }

  Widget _buildXpPill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '+${widget.xp} XP',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final t = _pulseController.value;
        final pulseWindow = ((t - 0.88) / 0.12).clamp(0.0, 1.0);
        final scale = 1 + (math.sin(pulseWindow * math.pi) * 0.02);
        return Transform.scale(scale: scale, child: child);
      },
      child: FilledButton(
        onPressed: () async {
          final result = await context.push<bool>(
            AppRouter.missionLocation(widget.missionId),
          );
          if (result == true) {
            widget.onMissionCompleted?.call();
          }
        },
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(96, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: const Text('Devam'),
      ),
    );
  }
}
