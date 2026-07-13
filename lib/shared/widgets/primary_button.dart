import 'package:flutter/material.dart';

import '../design_system/animations.dart';
import '../design_system/colors.dart';
import '../design_system/durations.dart';
import '../design_system/radius.dart';
import '../design_system/spacing.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLarge = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLarge;
  final bool expand;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.buttonPulse,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: widget.onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: Size.fromHeight(
          widget.isLarge
              ? AppSpacing.primaryButtonHeightLarge
              : AppSpacing.primaryButtonHeightRegular,
        ),
        padding: EdgeInsets.symmetric(
          vertical: widget.isLarge
              ? AppSpacing.primaryButtonVerticalLarge
              : AppSpacing.primaryButtonVerticalRegular,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      child: Text(widget.label),
    );

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulse = 1.0 + (_pulseController.value * 0.02);
        final scale = _isPressed ? 0.97 : pulse;
        return AnimatedScale(
          scale: scale,
          duration: AppDurations.fast,
          curve: AppAnimations.standard,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapCancel: () => setState(() => _isPressed = false),
            onTapUp: (_) => setState(() => _isPressed = false),
            child: widget.expand
                ? SizedBox(width: double.infinity, child: button)
                : button,
          ),
        );
      },
    );
  }
}
