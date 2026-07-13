import 'package:flutter/material.dart';

import '../../design_system/animations.dart';
import '../../design_system/colors.dart';
import '../../design_system/durations.dart';
import '../../design_system/radius.dart';
import '../../design_system/shadows.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.invertColors = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool invertColors;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.invertColors ? AppColors.surface : AppColors.primary;
    final fg = widget.invertColors ? AppColors.primary : AppColors.surface;

    final button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.soft,
      ),
      child: FilledButton.icon(
        onPressed: widget.onPressed,
        icon: widget.icon == null
            ? const SizedBox.shrink()
            : Icon(widget.icon, size: 18),
        label: Text(
          widget.label,
          style: const TextStyle(
            fontWeight: AppTypography.buttonWeight,
            fontSize: AppTypography.buttonLabel,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          minimumSize: const Size(0, AppSpacing.primaryButtonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.primaryButtonHorizontal,
            vertical: AppSpacing.primaryButtonVertical,
          ),
          elevation: 0,
        ),
      ),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppAnimations.standard,
        child: Transform.translate(
          offset: Offset(0, _pressed ? 1.5 : 0),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1,
            duration: AppDurations.buttonPress,
            child: widget.expand
                ? SizedBox(width: double.infinity, child: button)
                : button,
          ),
        ),
      ),
    );
  }
}
