import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/scene_model.dart';
import '../widgets/answer_button.dart';

class QuizScene extends StatelessWidget {
  const QuizScene({
    super.key,
    required this.scene,
    required this.selectedAnswerIndex,
    required this.showFeedback,
    required this.isCorrect,
    required this.showHint,
    required this.onAnswer,
    required this.onShowHint,
  });

  final SceneModel scene;
  final int? selectedAnswerIndex;
  final bool showFeedback;
  final bool isCorrect;
  final bool showHint;
  final ValueChanged<int> onAnswer;
  final VoidCallback onShowHint;

  @override
  Widget build(BuildContext context) {
    return _FadeInScene(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            scene.prompt,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 20),
          ...List.generate(scene.options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnswerButton(
                label: scene.options[index],
                isCorrect: scene.options[index] == scene.answer,
                isSelected: selectedAnswerIndex == index,
                onPressed: () => onAnswer(index),
              ),
            );
          }),
          if (showFeedback)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  Text(
                    isCorrect ? 'Harika!' : 'Güzel denedin.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isCorrect ? AppColors.primary : Colors.orange.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: onShowHint,
                      icon: const Icon(Icons.lightbulb_outline_rounded),
                      label: const Text('İpucu'),
                    ),
                    if (showHint)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          scene.tip.isNotEmpty ? scene.tip : 'Öğretmen seni selamlıyor.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.mutedText,
                              ),
                        ),
                      ),
                  ],
                ],
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
