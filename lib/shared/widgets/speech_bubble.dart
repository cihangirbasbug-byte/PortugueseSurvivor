import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/radius.dart';
import '../design_system/shadows.dart';
import '../design_system/spacing.dart';

class SpeechBubble extends StatelessWidget {
  const SpeechBubble({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.speechBubble),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }
}
