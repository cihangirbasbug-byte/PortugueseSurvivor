import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/scene_model.dart';
import '../widgets/audio_button.dart';
import '../widgets/scene_action_button.dart';
import '../widgets/word_card.dart';

class WordScene extends StatelessWidget {
  const WordScene({
    super.key,
    required this.scene,
    required this.onPlayAudio,
    required this.onReplayAudio,
    required this.onNext,
  });

  final SceneModel scene;
  final VoidCallback onPlayAudio;
  final VoidCallback onReplayAudio;
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
          const SizedBox(height: 12),
          Text(
            scene.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          WordCard(
            portugueseWord: scene.body,
            turkishMeaning: scene.answer,
            hint: 'Portekizce kelime',
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AudioButton(
                label: 'Ses',
                icon: Icons.volume_up_rounded,
                onPressed: onPlayAudio,
              ),
              const SizedBox(width: 12),
              AudioButton(
                label: 'Tekrar',
                icon: Icons.refresh_rounded,
                onPressed: onReplayAudio,
              ),
            ],
          ),
          const SizedBox(height: 20),
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
