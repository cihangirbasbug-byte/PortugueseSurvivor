import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String label;
  final bool isCorrect;
  final bool isSelected;
  final VoidCallback onPressed;

  const AnswerButton({
    super.key,
    required this.label,
    required this.isCorrect,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? (isCorrect ? Colors.green.shade600 : Colors.red.shade400)
        : Colors.white;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          backgroundColor: color,
          side: BorderSide(
            color: isSelected
                ? color
                : Colors.grey.shade300,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
