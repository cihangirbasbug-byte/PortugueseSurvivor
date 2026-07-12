import 'package:flutter/material.dart';

class RewardChip extends StatelessWidget {
  const RewardChip({
    super.key,
    required this.label,
    required this.icon,
    this.backgroundColor = const Color(0x220E8A4B),
    this.foregroundColor = const Color(0xFF0E8A4B),
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
