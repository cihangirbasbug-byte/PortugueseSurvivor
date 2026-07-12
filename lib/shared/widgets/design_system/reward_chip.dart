import 'package:flutter/material.dart';

class RewardChip extends StatefulWidget {
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
      duration: const Duration(milliseconds: 2200),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
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
