import 'package:flutter/material.dart';

import '../../../../core/animation/pico_animation_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/character/teacher_character.dart';
import '../../../../shared/widgets/character/pico_character.dart';
import '../../../../shared/widgets/speech_bubble.dart';
import '../../data/models/scene_model.dart';
import '../widgets/scene_action_button.dart';

class IntroScene extends StatelessWidget {
  const IntroScene({
    super.key,
    required this.scene,
    required this.showBubble,
    required this.picoAnimationController,
    required this.onNext,
  });

  final SceneModel scene;
  final bool showBubble;
  final PicoAnimationController picoAnimationController;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _FadeInScene(
      child: Column(
        key: const ValueKey<String>('scene_intro'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _IntroAnimationPanel(
            showBubble: showBubble,
            picoAnimationController: picoAnimationController,
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedOpacity(
            opacity: showBubble ? 1 : 0,
            duration: const Duration(milliseconds: 350),
            child: AnimatedSlide(
              offset: showBubble ? Offset.zero : const Offset(0, 0.08),
              duration: const Duration(milliseconds: 350),
              child: SpeechBubble(
                child: _TypewriterText(
                  text: scene.body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.mutedText,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          SceneActionButton(
            label: scene.prompt.isNotEmpty ? scene.prompt : 'Maceraya Başla',
            onPressed: onNext,
            isLarge: true,
          ),
        ],
      ),
    );
  }
}

class _IntroAnimationPanel extends StatelessWidget {
  const _IntroAnimationPanel({
    required this.showBubble,
    required this.picoAnimationController,
  });

  final bool showBubble;
  final PicoAnimationController picoAnimationController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF6DB), Color(0xFFE7F5FF)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wb_sunny_rounded, color: Colors.amber.shade700),
              const SizedBox(width: 6),
              Text(
                'Sabah 08:10 • Okula Varış',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: showBubble ? 1 : 0.65),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1C8A4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Align(
                    alignment: Alignment(-1 + (value * 2), 0),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E8A4B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0E8A4B).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Kapı açılıyor • Koridordan sınıfa geçiş',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSlide(
                offset: showBubble ? Offset.zero : const Offset(-0.08, 0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: const TeacherCharacter(
                  size: TeacherCharacterSize.medium,
                  emotion: TeacherEmotion.smile,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedSlide(
                offset: showBubble ? Offset.zero : const Offset(0.08, 0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: PicoCharacter(
                  size: PicoCharacterSize.medium,
                  state: PicoCharacterState.talking,
                  emotion: PicoEmotion.happy,
                  controller: picoAnimationController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: showBubble ? 1 : 0,
            duration: const Duration(milliseconds: 350),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Teacher Sofia: "Hoş geldin, bugün harika başlayacağız!"',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  const _TypewriterText({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _durationFor(widget.text),
    )..forward();
  }

  Duration _durationFor(String text) {
    final ms = (text.length * 18).clamp(250, 3000);
    return Duration(milliseconds: ms);
  }

  @override
  void didUpdateWidget(covariant _TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.dispose();
      _controller = AnimationController(
        vsync: this,
        duration: _durationFor(widget.text),
      )..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _completeNow() {
    _controller.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _completeNow,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final visibleChars = (widget.text.length * _controller.value).floor();
          final visibleText = widget.text.substring(
            0,
            visibleChars.clamp(0, widget.text.length),
          );
          return Text(
            visibleText,
            textAlign: TextAlign.center,
            style: widget.style,
          );
        },
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
