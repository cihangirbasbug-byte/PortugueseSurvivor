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
                  width: 210,
                  height: 110,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny_rounded,
                            size: 20,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Okul avlusu',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.school_rounded,
                              color: Colors.brown.shade400,
                              size: 30,
                            ),
                            Icon(
                              Icons.directions_walk_rounded,
                              color: Colors.blueGrey.shade500,
                              size: 28,
                            ),
                            Icon(
                              Icons.door_front_door_rounded,
                              color: Colors.brown.shade600,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ],
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
