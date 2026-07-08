import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/scene_model.dart';
import '../widgets/scene_action_button.dart';

class RealLifeScene extends StatelessWidget {
  const RealLifeScene({
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
          Text(
            scene.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
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
