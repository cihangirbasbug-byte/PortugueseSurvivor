import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../core/animation/pico_animation_controller.dart' as pico;
import '../../core/constants/pico_assets.dart';
import '../../core/theme/app_shadows.dart';

class PicoAvatar extends StatefulWidget {
  const PicoAvatar({
    super.key,
    this.size = 100,
    this.animate = false,
    this.controller,
  });

  final double size;
  final bool animate;
  final pico.PicoAnimationController? controller;

  @override
  State<PicoAvatar> createState() => _PicoAvatarState();
}

class _PicoAvatarState extends State<PicoAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lifeController;

  @override
  void initState() {
    super.initState();
    _lifeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PicoAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _lifeController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  pico.PicoAnimationState get _effectiveState {
    final controller = widget.controller;
    if (controller != null) {
      return controller.state;
    }
    return widget.animate ? pico.PicoAnimationState.wave : pico.PicoAnimationState.idle;
  }

  pico.PicoIdleMicroAnimation get _idleMicroAnimation {
    return widget.controller?.idleMicroAnimation ?? pico.PicoIdleMicroAnimation.none;
  }

  @override
  Widget build(BuildContext context) {
    final state = _effectiveState;
    final picoAssetPath = PicoAssets.forState(state);

    final avatar = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: AppShadows.soft,
      ),
      child: Center(
        child: Image.asset(
          picoAssetPath,
          fit: BoxFit.contain,
          width: widget.size * 0.78,
          height: widget.size * 0.78,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.smart_toy_rounded,
              size: widget.size * 0.48,
              color: Colors.lightBlue.shade700,
            );
          },
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _lifeController,
      builder: (context, child) {
        final t = _lifeController.value * 2 * math.pi;
        final idleMotion = _idleMicroAnimation;

        var dx = 0.0;
        var dy = math.sin(t) * 1.6;
        var rotation = math.sin(t) * 0.012;
        var scale = 1 + (math.sin(t) * 0.012);
        var scaleY = 1.0;

        switch (state) {
          case pico.PicoAnimationState.idle:
            if (idleMotion == pico.PicoIdleMicroAnimation.blink) {
              scaleY = 0.82;
            } else if (idleMotion == pico.PicoIdleMicroAnimation.breathing) {
              scale = 1 + (math.sin(t * 2) * 0.025);
            } else if (idleMotion == pico.PicoIdleMicroAnimation.headMove) {
              rotation = math.sin(t * 2.6) * 0.06;
            } else if (idleMotion == pico.PicoIdleMicroAnimation.wingMove) {
              dx = math.sin(t * 5) * 2.8;
              rotation = math.sin(t * 5) * 0.03;
            }
            break;
          case pico.PicoAnimationState.blink:
            scaleY = 0.8;
            break;
          case pico.PicoAnimationState.wave:
            dy = math.sin(t * 4) * 3;
            rotation = math.sin(t * 4) * 0.12;
            break;
          case pico.PicoAnimationState.listen:
            dx = math.sin(t * 2.2) * 0.8;
            rotation = math.sin(t * 2.2) * 0.025;
            break;
          case pico.PicoAnimationState.think:
            dx = math.sin(t * 1.8) * 1.6;
            rotation = math.sin(t * 1.8) * 0.045;
            break;
          case pico.PicoAnimationState.encourage:
            scale = 1 + (math.sin(t * 3).abs() * 0.05);
            dy = math.sin(t * 3) * 2;
            break;
          case pico.PicoAnimationState.celebrate:
            dy = math.sin(t * 6) * 4;
            rotation = math.sin(t * 8) * 0.12;
            scale = 1 + (math.sin(t * 6).abs() * 0.05);
            break;
        }

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Transform.scale(
                scaleY: scaleY,
                child: child,
              ),
            ),
          ),
        );
      },
      child: avatar,
    );
  }
}
