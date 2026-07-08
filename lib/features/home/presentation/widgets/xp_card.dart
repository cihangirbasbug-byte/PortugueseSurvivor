import 'package:flutter/material.dart';

import 'stat_card.dart';

class XpCard extends StatefulWidget {
  final int xp;

  const XpCard({
    super.key,
    required this.xp,
  });

  @override
  State<XpCard> createState() => _XpCardState();
}

class _XpCardState extends State<XpCard> {
  double _beginValue = 0;

  @override
  void didUpdateWidget(covariant XpCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.xp != widget.xp) {
      _beginValue = oldWidget.xp.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _beginValue, end: widget.xp.toDouble()),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      onEnd: () {
        _beginValue = widget.xp.toDouble();
      },
      builder: (context, animatedXp, _) {
        return StatCard(
          icon: Icons.emoji_events_rounded,
          value: '${animatedXp.round()}',
          label: 'XP',
          iconColor: const Color(0xFFF5C542),
        );
      },
    );
  }
}