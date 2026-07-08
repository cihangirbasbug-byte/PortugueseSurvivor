import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/scene_model.dart';
import '../widgets/scene_action_button.dart';

class PracticeScene extends StatefulWidget {
  const PracticeScene({
    super.key,
    required this.scene,
    required this.onSkip,
    required this.onNext,
  });

  final SceneModel scene;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  State<PracticeScene> createState() => _PracticeSceneState();
}

class _PracticeSceneState extends State<PracticeScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
          const SizedBox(height: 12),
          Text(
            widget.scene.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.scene.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedText,
                ),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final pulse = 1 + (_pulseController.value * 0.08);
              return Transform.scale(
                scale: _isListening ? pulse : 1,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isListening = !_isListening;
                });
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _isListening ? AppColors.primary : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _isListening ? 0.24 : 0.12),
                      blurRadius: _isListening ? 20 : 10,
                      spreadRadius: _isListening ? 6 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: 54,
                  color: _isListening ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: _isListening ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              'Dinleniyor...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: widget.onSkip, child: const Text('Atla')),
          const SizedBox(height: 18),
          SceneActionButton(label: 'Devam', onPressed: widget.onNext),
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
