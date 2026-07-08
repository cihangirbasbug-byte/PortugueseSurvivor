import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'progress_section.dart';

class LessonCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final int xp;
  final String difficulty;
  final double progress;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;

  const LessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.xp,
    this.difficulty = 'Beginner',
    this.progress = 0.0,
    this.icon = Icons.language_rounded,
    this.accentColor = AppColors.primary,
    this.onTap,
    this.isLocked = false,
    this.isCompleted = false,
    this.isCurrent = false,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLocked ? null : widget.onTap,
          onHighlightChanged: (isHighlighted) {
            if (widget.isLocked) {
              return;
            }
            setState(() {
              _isPressed = isHighlighted;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isCurrent ? AppColors.primary.withValues(alpha: 0.35) : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (widget.isLocked ? Colors.grey : widget.accentColor).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.isLocked
                        ? Icons.lock_rounded
                        : (widget.isCompleted ? Icons.check_circle_rounded : widget.icon),
                    color: widget.isLocked
                        ? Colors.grey.shade700
                        : (widget.isCompleted ? AppColors.success : widget.accentColor),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.isLocked ? Colors.grey.shade500 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ProgressSection(
                        label: '',
                        value: widget.progress,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              widget.isLocked
                                  ? 'Kilitli'
                                  : (widget.isCompleted
                                      ? 'Tamamlandı'
                                      : (widget.isCurrent ? 'Aktif' : widget.difficulty)),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: widget.isLocked ? Colors.grey.shade700 : AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '+${widget.xp} XP',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (widget.isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Şimdi',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}