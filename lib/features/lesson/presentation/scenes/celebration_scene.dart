import 'package:flutter/material.dart';

import '../../../../core/animation/pico_animation_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/celebration_card.dart';
import '../../../../shared/widgets/pico_avatar.dart';
import '../../data/models/scene_model.dart';

class CelebrationScene extends StatefulWidget {
  const CelebrationScene({
    super.key,
    required this.scene,
    required this.badge,
    required this.xp,
    required this.courage,
    required this.picoAnimationController,
    required this.onNext,
  });

  final SceneModel scene;
  final String badge;
  final int xp;
  final int courage;
  final PicoAnimationController picoAnimationController;
  final VoidCallback onNext;

  @override
  State<CelebrationScene> createState() => _CelebrationSceneState();
}

class _CelebrationSceneState extends State<CelebrationScene> {
  @override
  Widget build(BuildContext context) {
    return _FadeInScene(
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(6, (index) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: -90, end: 280),
                    duration: Duration(milliseconds: 1200 + (index * 120)),
                    curve: Curves.easeIn,
                    builder: (context, value, child) {
                      return Transform.translate(offset: Offset(0, value), child: child);
                    },
                    child: Text(index.isEven ? '🎉' : '✨', style: const TextStyle(fontSize: 22)),
                  );
                }),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CelebrationCard(
                xp: widget.xp,
                courage: widget.courage,
                badge: widget.badge,
                title: widget.scene.title,
                message: widget.scene.body,
                onPressed: widget.onNext,
                buttonLabel: 'Devam',
                showCountUp: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              PicoAvatar(
                size: 64,
                controller: widget.picoAnimationController,
              ),
            ],
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
