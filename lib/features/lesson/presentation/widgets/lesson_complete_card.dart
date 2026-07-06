import 'package:flutter/material.dart';

import '../../../../../shared/widgets/celebration_card.dart';

class LessonCompleteCard extends StatelessWidget {
  const LessonCompleteCard({
    super.key,
    required this.xp,
    required this.courage,
    required this.badge,
    required this.title,
    required this.message,
    required this.onPressed,
  });

  final int xp;
  final int courage;
  final String badge;
  final String title;
  final String message;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CelebrationCard(
      xp: xp,
      courage: courage,
      badge: badge,
      title: title,
      message: message,
      onPressed: onPressed,
      buttonLabel: 'Devam Et',
      showCountUp: false,
    );
  }
}
