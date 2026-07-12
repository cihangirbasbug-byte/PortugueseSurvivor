import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

class DialogueBubble extends StatefulWidget {
  const DialogueBubble({
    super.key,
    required this.text,
    this.alignLeft = true,
    this.maxLines,
  });

  final String text;
  final bool alignLeft;
  final int? maxLines;

  @override
  State<DialogueBubble> createState() => _DialogueBubbleState();
}

class _DialogueBubbleState extends State<DialogueBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.xl + 4);
    return AnimatedBuilder(
      animation: _ambient,
      builder: (context, child) {
        final wobble = (_ambient.value - 0.5) * 2;
        return Opacity(
          opacity: 0.92 + (_ambient.value * 0.08),
          child: Transform.translate(
            offset: Offset(0, wobble * 1.8),
            child: child,
          ),
        );
      },
      child: CustomPaint(
        painter: _BubbleTailPainter(alignLeft: widget.alignLeft),
        child: Container(
          margin: EdgeInsets.only(
            left: widget.alignLeft ? 0 : 14,
            right: widget.alignLeft ? 14 : 0,
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: radius,
            border: Border.all(color: const Color(0xFFE3EFE4), width: 1.4),
            boxShadow: AppShadows.panel,
          ),
          child: Text(
            widget.text,
            maxLines: widget.maxLines,
            overflow: widget.maxLines == null
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF3D4350),
              height: 1.42,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  const _BubbleTailPainter({required this.alignLeft});

  final bool alignLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.96);
    final path = Path();

    if (alignLeft) {
      path.moveTo(10, size.height - 24);
      path.lineTo(10, size.height - 8);
      path.lineTo(24, size.height - 20);
    } else {
      path.moveTo(size.width - 10, size.height - 24);
      path.lineTo(size.width - 10, size.height - 8);
      path.lineTo(size.width - 24, size.height - 20);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) {
    return oldDelegate.alignLeft != alignLeft;
  }
}
