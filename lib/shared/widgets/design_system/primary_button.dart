import 'package:flutter/material.dart';

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
    final bg = widget.invertColors ? Colors.white : const Color(0xFF0E8A4B);
    final fg = widget.invertColors ? const Color(0xFF0E8A4B) : Colors.white;

    final button = FilledButton.icon(
      onPressed: widget.onPressed,
      icon: widget.icon == null ? const SizedBox.shrink() : Icon(widget.icon, size: 18),
      label: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w800)),
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 0,
      ),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 100),
        child: widget.expand ? SizedBox(width: double.infinity, child: button) : button,
      ),
    );
  }
}
