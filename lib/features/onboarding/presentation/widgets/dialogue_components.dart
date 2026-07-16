import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/character/pico_character.dart';
import '../../../../shared/widgets/character/teacher_character.dart';

enum TeacherSofiaExpression { happy, speaking, thinking, encouraging }

enum DialogueAvatarRole { teacherSofia, pico, student }

class DialogueAvatar extends StatelessWidget {
  const DialogueAvatar({
    super.key,
    required this.role,
    this.teacherExpression = TeacherSofiaExpression.happy,
    this.size = 84,
  });

  final DialogueAvatarRole role;
  final TeacherSofiaExpression teacherExpression;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case DialogueAvatarRole.teacherSofia:
        return TeacherCharacter(
          emotion: _teacherEmotion(teacherExpression),
          customSize: size,
        );
      case DialogueAvatarRole.pico:
        return PicoCharacter(
          state: PicoCharacterState.talking,
          emotion: PicoEmotion.happy,
          customSize: size,
        );
      case DialogueAvatarRole.student:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.speechBorder),
          ),
          child: Icon(
            Icons.person_rounded,
            size: size * 0.54,
            color: AppColors.mutedText,
          ),
        );
    }
  }

  TeacherEmotion _teacherEmotion(TeacherSofiaExpression expression) {
    switch (expression) {
      case TeacherSofiaExpression.happy:
        return TeacherEmotion.smile;
      case TeacherSofiaExpression.speaking:
        return TeacherEmotion.explain;
      case TeacherSofiaExpression.thinking:
        return TeacherEmotion.listen;
      case TeacherSofiaExpression.encouraging:
        return TeacherEmotion.encourage;
    }
  }
}

class TeacherBubble extends StatelessWidget {
  const TeacherBubble({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return _DialogueBubble(
      message: message,
      backgroundColor: AppColors.surface,
      textColor: AppColors.speechText,
      alignment: Alignment.centerLeft,
      borderColor: AppColors.speechBorder,
    );
  }
}

class StudentBubble extends StatelessWidget {
  const StudentBubble({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return _DialogueBubble(
      message: message,
      backgroundColor: AppColors.primary,
      textColor: AppColors.surface,
      alignment: Alignment.centerRight,
      borderColor: AppColors.primary,
    );
  }
}

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(label),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({
    super.key,
    this.dotCount = 3,
  });

  final int dotCount;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> {
  late final Timer _timer;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 320), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _activeIndex = (_activeIndex + 1) % widget.dotCount;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.speechBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.dotCount, (index) {
            final isActive = index == _activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 8 : 6,
              height: isActive ? 8 : 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.speechBorder,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DialogueBubble extends StatelessWidget {
  const _DialogueBubble({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.alignment,
    required this.borderColor,
  });

  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Alignment alignment;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
