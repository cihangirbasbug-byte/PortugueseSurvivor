import 'package:flutter/material.dart';

import 'stat_card.dart';

class XpCard extends StatelessWidget {
  final int xp;

  const XpCard({
    super.key,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      icon: Icons.emoji_events_rounded,
      value: '$xp',
      label: 'XP',
      iconColor: const Color(0xFFF5C542),
    );
  }
}