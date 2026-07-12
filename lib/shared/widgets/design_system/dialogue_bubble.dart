import 'package:flutter/material.dart';

class DialogueBubble extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return CustomPaint(
      painter: _BubbleTailPainter(alignLeft: alignLeft),
      child: Container(
        margin: EdgeInsets.only(left: alignLeft ? 0 : 14, right: alignLeft ? 14 : 0),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          text,
          maxLines: maxLines,
          overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF3D4350),
                height: 1.3,
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
      path.moveTo(8, size.height - 24);
      path.lineTo(8, size.height - 10);
      path.lineTo(20, size.height - 20);
    } else {
      path.moveTo(size.width - 8, size.height - 24);
      path.lineTo(size.width - 8, size.height - 10);
      path.lineTo(size.width - 20, size.height - 20);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) {
    return oldDelegate.alignLeft != alignLeft;
  }
}
