import 'package:flutter/material.dart';

class AppShadows {
  static List<BoxShadow> get level1 => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get level2 => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get panel => level1;
  static List<BoxShadow> get soft => level2;

  static List<BoxShadow> get statCard => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> heroCard(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.28),
      blurRadius: 24,
      offset: const Offset(0, 14),
    ),
  ];
}
