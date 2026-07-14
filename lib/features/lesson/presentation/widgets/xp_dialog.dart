import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/character/pico_character.dart';
import '../../../../../shared/widgets/character/teacher_character.dart';

class XpDialog extends StatelessWidget {
  final String title;
  final String message;
  final int xp;
  final int courage;
  final bool showCelebrationCharacters;
  final VoidCallback onPressed;

  const XpDialog({
    super.key,
    required this.title,
    required this.message,
    required this.xp,
    required this.courage,
    this.showCelebrationCharacters = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCelebrationCharacters) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                TeacherCharacter(
                  size: TeacherCharacterSize.small,
                  customSize: 72,
                  emotion: TeacherEmotion.smile,
                ),
                SizedBox(width: 8),
                PicoCharacter(
                  size: PicoCharacterSize.small,
                  customSize: 72,
                  state: PicoCharacterState.celebrating,
                  emotion: PicoEmotion.celebrate,
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Text(message),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '+$xp XP',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '+$courage Cesaret',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: const Text('Devam'),
        ),
      ],
    );
  }
}
