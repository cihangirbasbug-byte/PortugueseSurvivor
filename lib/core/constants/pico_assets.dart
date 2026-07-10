import '../animation/pico_animation_controller.dart';

/// Single source of truth for all renderable Pico visual states.
abstract final class PicoAssets {
  static const String idle = 'assets/characters/pico/pico_idle.png';
  static const String wave = 'assets/characters/pico/pico_wave.png';
  static const String think = 'assets/characters/pico/pico_think.png';
  static const String encourage = 'assets/characters/pico/pico_encourage.png';
  static const String celebrate = 'assets/characters/pico/pico_celebrate.png';
  static const String listen = 'assets/characters/pico/pico_listen.png';

  static String forState(PicoAnimationState state) {
    switch (state) {
      case PicoAnimationState.idle:
      case PicoAnimationState.blink:
        return idle;
      case PicoAnimationState.wave:
        return wave;
      case PicoAnimationState.listen:
        return listen;
      case PicoAnimationState.think:
        return think;
      case PicoAnimationState.encourage:
        return encourage;
      case PicoAnimationState.celebrate:
        return celebrate;
    }
  }
}