import 'package:flutter/material.dart';

import 'stat_card.dart';

class StreakCard extends StatelessWidget {
  final int days;

  const StreakCard({
    super.key,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      icon: Icons.local_fire_department_rounded,
      value: '$days',
      label: 'Gün Seri',
      iconColor: const Color(0xFFFF6B35),
    );
  }
}