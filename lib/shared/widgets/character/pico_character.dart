import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/animation/pico_animation_controller.dart' as pico;
import '../../../core/constants/pico_assets.dart';
import '../../../core/theme/app_shadows.dart';

enum PicoCharacterState {
  idle,
  talking,
  thinking,
  listening,
  celebrating,
  encouraging,
}

enum PicoEmotion { idle, happy, thinking, listen, celebrate, encourage }

enum PicoCharacterSize { small, medium, large, hero }

class PicoCharacter extends StatefulWidget {
  const PicoCharacter({
    super.key,
    this.state = PicoCharacterState.idle,
    this.emotion = PicoEmotion.idle,
    this.size = PicoCharacterSize.medium,
    this.customSize,
    this.controller,
  });

  final PicoCharacterState state;
  final PicoEmotion emotion;
  final PicoCharacterSize size;
  final double? customSize;
  final pico.PicoAnimationController? controller;

  static double dimensionFor(PicoCharacterSize size) {
    switch (size) {
      case PicoCharacterSize.small:
        return 64;
      case PicoCharacterSize.medium:
        return 92;
      case PicoCharacterSize.large:
        return 126;
      case PicoCharacterSize.hero:
        return 214;
    }
  }

  @override
  State<PicoCharacter> createState() => _PicoCharacterState();
}

class _PicoCharacterState extends State<PicoCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PicoCharacter oldWidget) {
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
        widget.customSize ?? PicoCharacter.dimensionFor(widget.size);
    final controllerState = widget.controller?.state;
    final controllerIdleMicro = widget.controller?.idleMicroAnimation;

    final resolvedState = controllerState == null
        ? widget.state
        : _stateFromController(controllerState);
    final resolvedEmotion = controllerState == null
        ? widget.emotion
        : _emotionFromController(controllerState);

    final assetPath = _assetFor(resolvedState, resolvedEmotion);
    final imageExtent = dimension * 0.8;
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
    final cacheExtent = (imageExtent * devicePixelRatio).round();

    final avatar = Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: AppShadows.soft,
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          width: imageExtent,
          height: imageExtent,
          cacheWidth: cacheExtent,
          cacheHeight: cacheExtent,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
        final t = _idleController.value * 2 * math.pi;

        var dx = 0.0;
        var dy = math.sin(t) * 1.1;
        var rotation = math.sin(t) * 0.008;
        var scale = 1 + (math.sin(t) * 0.009);
        var scaleY = 1.0;

        if (resolvedState == PicoCharacterState.idle) {
          if (controllerIdleMicro == pico.PicoIdleMicroAnimation.blink) {
            scaleY = 0.9;
          } else if (controllerIdleMicro ==
              pico.PicoIdleMicroAnimation.breathing) {
            scale = 1 + (math.sin(t * 2) * 0.015);
          }
        }

        if (resolvedState == PicoCharacterState.talking ||
            resolvedState == PicoCharacterState.encouraging) {
          dy = math.sin(t * 2.4) * 1.4;
          rotation = math.sin(t * 2.4) * 0.012;
        } else if (resolvedState == PicoCharacterState.listening) {
          dx = math.sin(t * 1.8) * 0.7;
          rotation = math.sin(t * 1.8) * 0.014;
        } else if (resolvedState == PicoCharacterState.thinking) {
          dx = math.sin(t * 1.6) * 1.0;
          rotation = math.sin(t * 1.6) * 0.02;
        } else if (resolvedState == PicoCharacterState.celebrating) {
          dy = math.sin(t * 3.2) * 2.2;
          rotation = math.sin(t * 3.2) * 0.03;
          scale = 1 + (math.sin(t * 3.2).abs() * 0.018);
        }

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Transform.scale(scaleY: scaleY, child: child),
            ),
          ),
        );
      },
      child: avatar,
    );
  }

  PicoCharacterState _stateFromController(pico.PicoAnimationState state) {
    switch (state) {
      case pico.PicoAnimationState.idle:
      case pico.PicoAnimationState.blink:
        return PicoCharacterState.idle;
      case pico.PicoAnimationState.wave:
        return PicoCharacterState.talking;
      case pico.PicoAnimationState.encourage:
        return PicoCharacterState.encouraging;
      case pico.PicoAnimationState.listen:
        return PicoCharacterState.listening;
      case pico.PicoAnimationState.think:
        return PicoCharacterState.thinking;
      case pico.PicoAnimationState.celebrate:
        return PicoCharacterState.celebrating;
    }
  }

  PicoEmotion _emotionFromController(pico.PicoAnimationState state) {
    switch (state) {
      case pico.PicoAnimationState.idle:
      case pico.PicoAnimationState.blink:
        return PicoEmotion.idle;
      case pico.PicoAnimationState.wave:
        return PicoEmotion.happy;
      case pico.PicoAnimationState.listen:
        return PicoEmotion.listen;
      case pico.PicoAnimationState.think:
        return PicoEmotion.thinking;
      case pico.PicoAnimationState.encourage:
        return PicoEmotion.encourage;
      case pico.PicoAnimationState.celebrate:
        return PicoEmotion.celebrate;
    }
  }

  String _assetFor(PicoCharacterState state, PicoEmotion emotion) {
    if (state == PicoCharacterState.celebrating ||
        emotion == PicoEmotion.celebrate) {
      return PicoAssets.celebrate;
    }
    if (state == PicoCharacterState.thinking ||
        emotion == PicoEmotion.thinking) {
      return PicoAssets.think;
    }
    if (state == PicoCharacterState.listening ||
        emotion == PicoEmotion.listen) {
      return PicoAssets.listen;
    }
    if (state == PicoCharacterState.encouraging ||
        emotion == PicoEmotion.encourage) {
      return PicoAssets.encourage;
    }
    if (state == PicoCharacterState.talking || emotion == PicoEmotion.happy) {
      return PicoAssets.wave;
    }
    return PicoAssets.idle;
  }
}
