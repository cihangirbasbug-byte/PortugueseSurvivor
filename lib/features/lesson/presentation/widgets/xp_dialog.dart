import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/character/pico_character.dart';
import '../../../../../shared/widgets/character/teacher_character.dart';

class XpDialog extends StatefulWidget {
  final String title;
  final String message;
  final int xp;
  final int courage;
  final bool showCelebrationCharacters;
  final VoidCallback onPressed;

  const XpDialog({
    super.key,
    required this.title,
    required this.message,
    required this.xp,
    required this.courage,
    this.showCelebrationCharacters = false,
    required this.onPressed,
  });

  @override
  State<XpDialog> createState() => _XpDialogState();
}

class _XpDialogState extends State<XpDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Stack(
        children: [
          if (widget.showCelebrationCharacters)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    final t = _confettiController.value;
                    final dots = <Widget>[];
                    for (var i = 0; i < 18; i++) {
                      final x = (i * 17.0) % 210;
                      final y = ((t + (i * 0.06)) % 1.0) * 120;
                      dots.add(
                        Positioned(
                          left: x,
                          top: y,
                          child: Container(
                            width: 4 + (i % 3),
                            height: 4 + (i % 3),
                            decoration: BoxDecoration(
                              color: i.isEven
                                  ? const Color(0xFFF5C542).withValues(alpha: 0.6)
                                  : const Color(0xFF7BC6FF).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      );
                    }
                    return Stack(children: dots);
                  },
                ),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showCelebrationCharacters) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    TeacherCharacter(
                      size: TeacherCharacterSize.small,
                      customSize: 72,
                      emotion: TeacherEmotion.smile,
                    ),
                    SizedBox(width: 8),
                    PicoCharacter(
                      size: PicoCharacterSize.small,
                      customSize: 72,
                      state: PicoCharacterState.celebrating,
                      emotion: PicoEmotion.celebrate,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              Text(widget.message, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Teacher Sofia: "Harika gidiyorsun, yarina da hazirsin!"',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: widget.xp.toDouble()),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+${value.round()} XP',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: widget.courage.toDouble(),
                    ),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+${value.round()} Cesaret',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: const Text('Devam'),
        ),
      ],
    );
  }
}
