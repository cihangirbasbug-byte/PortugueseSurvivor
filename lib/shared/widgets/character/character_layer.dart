import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/animation/pico_animation_controller.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import 'pico_character.dart';
import 'teacher_sofia_avatar.dart';

enum CharacterRole { pico, teacherSofia, custom }

class CharacterLayer extends StatefulWidget {
  const CharacterLayer({
    super.key,
    required this.role,
    this.size,
    this.name,
    this.picoController,
    this.picoAnimate = false,
    this.picoState = PicoCharacterState.idle,
    this.picoEmotion = PicoEmotion.neutral,
    this.picoSize = PicoCharacterSize.medium,
    this.customAvatar,
    this.showPlate = false,
    this.enableAmbientFloat = true,
  });

  final CharacterRole role;
  final double? size;
  final String? name;
  final PicoAnimationController? picoController;
  final bool picoAnimate;
  final PicoCharacterState picoState;
  final PicoEmotion picoEmotion;
  final PicoCharacterSize picoSize;
  final Widget? customAvatar;
  final bool showPlate;
  final bool enableAmbientFloat;

  @override
  State<CharacterLayer> createState() => _CharacterLayerState();
}

class _CharacterLayerState extends State<CharacterLayer>
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
    final avatar = _avatarForRole();
    final effectiveName = widget.name ?? _defaultNameForRole(widget.role);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.enableAmbientFloat)
          AnimatedBuilder(
            animation: _ambient,
            builder: (context, child) {
              final t = _ambient.value * math.pi * 2;
              return Transform.translate(
                offset: Offset(0, math.sin(t) * 3),
                child: child,
              );
            },
            child: avatar,
          )
        else
          avatar,
        if (widget.showPlate && effectiveName.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: AppShadows.panel,
            ),
            child: Text(
              effectiveName,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3F4C5A),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _avatarForRole() {
    switch (widget.role) {
      case CharacterRole.pico:
        return PicoCharacter(
          state: widget.picoAnimate
              ? PicoCharacterState.talking
              : widget.picoState,
          emotion: widget.picoAnimate ? PicoEmotion.happy : widget.picoEmotion,
          size: widget.picoSize,
          customSize: widget.size,
          controller: widget.picoController,
        );
      case CharacterRole.teacherSofia:
        return TeacherSofiaAvatar(
          size:
              widget.size ??
              PicoCharacter.dimensionFor(PicoCharacterSize.medium),
        );
      case CharacterRole.custom:
        final customSize =
            widget.size ?? PicoCharacter.dimensionFor(PicoCharacterSize.medium);
        return SizedBox(
          width: customSize,
          height: customSize,
          child: widget.customAvatar ?? const SizedBox.shrink(),
        );
    }
  }

  String _defaultNameForRole(CharacterRole role) {
    switch (role) {
      case CharacterRole.pico:
        return 'Pico';
      case CharacterRole.teacherSofia:
        return 'Teacher Sofia';
      case CharacterRole.custom:
        return '';
    }
  }
}
