import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_shadows.dart';

class TeacherSofiaAvatar extends StatelessWidget {
  const TeacherSofiaAvatar({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF4E6), Color(0xFFFFE4C8)],
        ),
        boxShadow: AppShadows.soft,
      ),
      child: CustomPaint(painter: _TeacherSofiaPainter()),
    );
  }
}

class _TeacherSofiaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final facePaint = Paint()..color = const Color(0xFFFFDFC2);
    final hairPaint = Paint()..color = const Color(0xFF4F3A2F);
    final shirtPaint = Paint()..color = const Color(0xFF6AA5E6);
    final blazerPaint = Paint()..color = const Color(0xFF3A537A);
    final chalkPaint = Paint()..color = const Color(0xFFEFF7FF);

    final hairRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - (size.height * 0.1)),
      width: size.width * 0.56,
      height: size.height * 0.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hairRect, Radius.circular(size.width * 0.18)),
      hairPaint,
    );

    canvas.drawCircle(
      Offset(center.dx, center.dy - (size.height * 0.1)),
      size.width * 0.18,
      facePaint,
    );

    final eyePaint = Paint()..color = const Color(0xFF304054);
    canvas.drawCircle(
      Offset(center.dx - (size.width * 0.06), center.dy - (size.height * 0.11)),
      size.width * 0.012,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + (size.width * 0.06), center.dy - (size.height * 0.11)),
      size.width * 0.012,
      eyePaint,
    );

    final smilePath = Path()
      ..moveTo(
        center.dx - (size.width * 0.05),
        center.dy - (size.height * 0.04),
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx + (size.width * 0.05),
        center.dy - (size.height * 0.04),
      );
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFF91565A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.012,
    );

    final shoulderRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + (size.height * 0.2)),
      width: size.width * 0.62,
      height: size.height * 0.34,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shoulderRect, Radius.circular(size.width * 0.18)),
      blazerPaint,
    );

    final shirtRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + (size.height * 0.22)),
      width: size.width * 0.26,
      height: size.height * 0.22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shirtRect, Radius.circular(size.width * 0.08)),
      shirtPaint,
    );

    canvas.save();
    canvas.translate(
      center.dx + (size.width * 0.18),
      center.dy + (size.height * 0.06),
    );
    canvas.rotate(-math.pi / 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -size.width * 0.04,
          -size.height * 0.1,
          size.width * 0.08,
          size.height * 0.16,
        ),
        Radius.circular(size.width * 0.02),
      ),
      chalkPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
