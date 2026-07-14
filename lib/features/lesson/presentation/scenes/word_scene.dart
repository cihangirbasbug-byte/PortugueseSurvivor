import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/character/pico_character.dart';
import '../../data/models/scene_model.dart';
import '../widgets/audio_button.dart';
import '../widgets/scene_action_button.dart';
import '../widgets/word_card.dart';

class WordScene extends StatefulWidget {
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
  State<WordScene> createState() => _WordSceneState();
}

class _WordSceneState extends State<WordScene> {
  bool _showWordStage = false;
  bool _showMeaningStage = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      setState(() {
        _showWordStage = true;
      });
    });
    Future<void>.delayed(const Duration(milliseconds: 1250), () {
      if (!mounted) return;
      setState(() {
        _showMeaningStage = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _FadeInScene(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.scene.character.isNotEmpty)
            Text(
              widget.scene.character,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
            ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: _showWordStage ? 1 : 0,
            duration: const Duration(milliseconds: 320),
            child: const PicoCharacter(
              size: PicoCharacterSize.small,
              customSize: 72,
              state: PicoCharacterState.thinking,
              emotion: PicoEmotion.thinking,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.scene.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ilk kelimeyi birlikte hissedelim',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          AnimatedScale(
            scale: _showWordStage ? 1 : 0.96,
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: _showWordStage ? 1 : 0,
              duration: const Duration(milliseconds: 340),
              child: WordCard(
                portugueseWord: widget.scene.body,
                turkishMeaning: _showMeaningStage ? widget.scene.answer : '...',
                hint: _showMeaningStage
                    ? 'Portekizce kelime'
                    : 'Pico once kelimeyi fısıldıyor...',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AudioButton(
                label: 'Ses',
                icon: Icons.volume_up_rounded,
                onPressed: widget.onPlayAudio,
              ),
              const SizedBox(width: 12),
              AudioButton(
                label: 'Tekrar',
                icon: Icons.refresh_rounded,
                onPressed: widget.onReplayAudio,
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: _showMeaningStage ? 1 : 0,
            duration: const Duration(milliseconds: 260),
            child: SceneActionButton(
              label: 'Devam',
              onPressed: _showMeaningStage ? widget.onNext : () {},
            ),
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
