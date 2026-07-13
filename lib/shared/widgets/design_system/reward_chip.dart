import 'package:flutter/material.dart';

import '../../design_system/colors.dart';
import '../../design_system/durations.dart';
import '../../design_system/radius.dart';
import '../../design_system/spacing.dart';

class RewardChip extends StatefulWidget {
  const RewardChip({
    super.key,
    required this.label,
    required this.icon,
    this.backgroundColor = const Color(0x220E8A4B),
    this.foregroundColor = AppColors.primary,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  State<RewardChip> createState() => _RewardChipState();
}

class _RewardChipState extends State<RewardChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: AppDurations.ambientLoopSlow,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.99 + (_pulse.value * 0.02),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.surface.withValues(alpha: 0.35)),
          gradient: LinearGradient(
            colors: [
              widget.backgroundColor.withValues(alpha: 0.95),
              widget.backgroundColor,
            ],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 16, color: widget.foregroundColor),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: widget.foregroundColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
