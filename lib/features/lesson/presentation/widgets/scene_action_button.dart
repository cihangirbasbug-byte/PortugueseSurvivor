import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class SceneActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLarge;

  const SceneActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLarge = false,
  });

  @override
  State<SceneActionButton> createState() => _SceneActionButtonState();
}

class _SceneActionButtonState extends State<SceneActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = 1.0 + (_pulseController.value * 0.02);
        final scale = _isPressed ? 0.97 : pulse;

        return AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size.fromHeight(widget.isLarge ? 60 : 52),
              padding: EdgeInsets.symmetric(vertical: widget.isLarge ? 18 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.isLarge ? 999 : 16),
              ),
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
