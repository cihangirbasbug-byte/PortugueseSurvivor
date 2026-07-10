import 'package:flutter/material.dart';

import '../../../../core/animation/pico_animation_controller.dart';
import '../widgets/lesson_complete_card.dart';

class MissionCompleteScene extends StatelessWidget {
  const MissionCompleteScene({
    super.key,
    required this.xp,
    required this.courage,
    required this.badge,
    required this.title,
    required this.message,
    required this.picoAnimationController,
    this.showChapterSummary = false,
    this.chapterId,
    required this.onPressed,
  });

  final int xp;
  final int courage;
  final String badge;
  final String title;
  final String message;
  final PicoAnimationController picoAnimationController;
  final bool showChapterSummary;
  final String? chapterId;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LessonCompleteCard(
      xp: xp,
      courage: courage,
      badge: badge,
      title: title,
      message: message,
      picoAnimationController: picoAnimationController,
      showChapterSummary: showChapterSummary,
      chapterId: chapterId,
      onPressed: onPressed,
    );
  }
}
