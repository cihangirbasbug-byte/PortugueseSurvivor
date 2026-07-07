import 'package:flutter/material.dart';

import '../../../../../core/animation/pico_animation_controller.dart';
import '../../../../../shared/widgets/celebration_card.dart';
import '../../../../../shared/widgets/pico_avatar.dart';

class LessonCompleteCard extends StatelessWidget {
  const LessonCompleteCard({
    super.key,
    required this.xp,
    required this.courage,
    required this.badge,
    required this.title,
    required this.message,
    this.picoAnimationController,
    required this.onPressed,
  });

  final int xp;
  final int courage;
  final String badge;
  final String title;
  final String message;
  final PicoAnimationController? picoAnimationController;
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
        if (picoAnimationController != null) ...[
          const SizedBox(height: 12),
          PicoAvatar(
            size: 68,
            controller: picoAnimationController,
          ),
        ],
      ],
    );
  }
}
