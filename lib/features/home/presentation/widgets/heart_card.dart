import 'package:flutter/material.dart';

import 'stat_card.dart';

class HeartCard extends StatelessWidget {
  final int hearts;

  const HeartCard({
    super.key,
    required this.hearts,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      icon: Icons.favorite_rounded,
      value: '$hearts',
      label: 'Hak',
      iconColor: const Color(0xFFFF6B6B),
    );
  }
}
