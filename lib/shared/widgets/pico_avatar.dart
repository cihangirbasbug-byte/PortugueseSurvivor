import 'package:flutter/material.dart';

import '../../core/animation/pico_animation_controller.dart' as pico;
import 'character/pico_character.dart';

class PicoAvatar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return PicoCharacter(
      state: animate ? PicoCharacterState.talking : PicoCharacterState.idle,
      emotion: animate ? PicoEmotion.happy : PicoEmotion.idle,
      customSize: size,
      controller: controller,
    );
  }
}
