import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/animation/pico_animation_controller.dart' as pico;
import '../../../core/constants/teacher_sofia_assets.dart';
import '../../../core/theme/app_shadows.dart';

enum TeacherEmotion { idle, smile, explain, listen, celebrate, encourage }

enum TeacherCharacterSize { small, medium, large, hero }

class TeacherCharacter extends StatefulWidget {
  const TeacherCharacter({
    super.key,
    this.emotion = TeacherEmotion.idle,
    this.size = TeacherCharacterSize.medium,
    this.customSize,
    this.controller,
  });

  final TeacherEmotion emotion;
  final TeacherCharacterSize size;
  final double? customSize;
  final pico.PicoAnimationController? controller;

  static double dimensionFor(TeacherCharacterSize size) {
    switch (size) {
      case TeacherCharacterSize.small:
        return 72;
      case TeacherCharacterSize.medium:
        return 104;
      case TeacherCharacterSize.large:
        return 140;
      case TeacherCharacterSize.hero:
        return 186;
    }
  }

  @override
  State<TeacherCharacter> createState() => _TeacherCharacterState();
}

class _TeacherCharacterState extends State<TeacherCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant TeacherCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _idleController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimension =
        widget.customSize ?? TeacherCharacter.dimensionFor(widget.size);
    final resolvedEmotion = widget.controller == null
        ? widget.emotion
        : _emotionFromController(widget.controller!.state);

    final avatar = Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.92),
        boxShadow: AppShadows.soft,
      ),
      child: Center(
        child: Image.asset(
          _assetFor(resolvedEmotion),
          fit: BoxFit.contain,
          width: dimension * 0.84,
          height: dimension * 0.84,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.school_rounded,
              size: dimension * 0.46,
              color: const Color(0xFF4A5F86),
            );
          },
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
        final t = _idleController.value * 2 * math.pi;

        var dx = 0.0;
        var dy = math.sin(t) * 0.9;
        var rotation = math.sin(t) * 0.006;
        var scale = 1 + (math.sin(t) * 0.008);

        if (resolvedEmotion == TeacherEmotion.explain) {
          dx = math.sin(t * 2.0) * 0.9;
          rotation = math.sin(t * 2.0) * 0.012;
        } else if (resolvedEmotion == TeacherEmotion.listen) {
          dx = math.sin(t * 1.5) * 0.6;
          rotation = math.sin(t * 1.5) * 0.01;
        } else if (resolvedEmotion == TeacherEmotion.celebrate) {
          dy = math.sin(t * 3.0) * 1.8;
          rotation = math.sin(t * 3.0) * 0.02;
          scale = 1 + (math.sin(t * 3.0).abs() * 0.014);
        } else if (resolvedEmotion == TeacherEmotion.encourage) {
          dy = math.sin(t * 2.3) * 1.1;
          rotation = math.sin(t * 2.3) * 0.012;
        }

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: avatar,
    );
  }

  TeacherEmotion _emotionFromController(pico.PicoAnimationState state) {
    switch (state) {
      case pico.PicoAnimationState.idle:
      case pico.PicoAnimationState.blink:
        return TeacherEmotion.idle;
      case pico.PicoAnimationState.wave:
        return TeacherEmotion.smile;
      case pico.PicoAnimationState.listen:
        return TeacherEmotion.listen;
      case pico.PicoAnimationState.think:
        return TeacherEmotion.explain;
      case pico.PicoAnimationState.encourage:
        return TeacherEmotion.encourage;
      case pico.PicoAnimationState.celebrate:
        return TeacherEmotion.celebrate;
    }
  }

  String _assetFor(TeacherEmotion emotion) {
    switch (emotion) {
      case TeacherEmotion.idle:
        return TeacherSofiaAssets.idle;
      case TeacherEmotion.smile:
        return TeacherSofiaAssets.smile;
      case TeacherEmotion.explain:
        return TeacherSofiaAssets.explain;
      case TeacherEmotion.listen:
        return TeacherSofiaAssets.listen;
      case TeacherEmotion.celebrate:
        return TeacherSofiaAssets.celebrate;
      case TeacherEmotion.encourage:
        return TeacherSofiaAssets.encourage;
    }
  }
}
