import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/character/teacher_character.dart';
import '../../../../shared/widgets/speech_bubble.dart';
import '../../data/models/scene_model.dart';
import '../widgets/scene_action_button.dart';

class DialogueScene extends StatelessWidget {
  const DialogueScene({
    super.key,
    required this.scene,
    required this.onNext,
  });

  final SceneModel scene;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _FadeInScene(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (scene.character.isNotEmpty)
            Text(
              scene.character,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            scene.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.92, end: 1.0),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            builder: (context, bubbleScale, child) {
              return Transform.scale(scale: bubbleScale, child: child);
            },
            child: SpeechBubble(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: -8, end: 8),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, waveOffset, child) {
                      return Transform.translate(
                        offset: Offset(0, waveOffset),
                        child: child,
                      );
                    },
                    child: const TeacherCharacter(
                      size: TeacherCharacterSize.medium,
                      emotion: TeacherEmotion.smile,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    scene.body,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedText,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F7EC),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Text(
                      scene.answer.isNotEmpty ? scene.answer : 'Olá!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SceneActionButton(
            label: scene.prompt.isNotEmpty ? scene.prompt : 'Devam',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _FadeInScene extends StatelessWidget {
  const _FadeInScene({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      builder: (context, value, widgetChild) {
        return Opacity(opacity: value, child: widgetChild);
      },
      child: child,
    );
  }
}
