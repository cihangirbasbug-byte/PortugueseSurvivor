import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/speech_bubble.dart';
import '../../data/models/scene_model.dart';
import '../widgets/scene_action_button.dart';

class StoryScene extends StatelessWidget {
  const StoryScene({
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
          SpeechBubble(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Text(
                  scene.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      scene.illustration.isNotEmpty ? scene.illustration : '🏫',
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  scene.body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SceneActionButton(label: 'Devam', onPressed: onNext),
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
