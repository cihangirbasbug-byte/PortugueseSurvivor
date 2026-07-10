import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

enum PicoAnimationState {
  idle,
  blink,
  wave,
  listen,
  think,
  encourage,
  celebrate,
}

enum PicoIdleMicroAnimation {
  none,
  blink,
  breathing,
  headMove,
  wingMove,
}

class PicoSceneAnimationMapper {
  static const Map<String, PicoAnimationState> _sceneMap = <String, PicoAnimationState>{
    'intro': PicoAnimationState.wave,
    'dialogue': PicoAnimationState.listen,
    'practice': PicoAnimationState.encourage,
    'quiz': PicoAnimationState.think,
    'celebration': PicoAnimationState.celebrate,
    'mission_complete': PicoAnimationState.celebrate,
    'complete': PicoAnimationState.celebrate,
  };

  static PicoAnimationState fromSceneType(String sceneType) {
    final normalized = sceneType.trim().toLowerCase();
    return _sceneMap[normalized] ?? PicoAnimationState.idle;
  }
}

class PicoAnimationController extends ChangeNotifier {
  PicoAnimationController({Random? random}) : _random = random ?? Random();

  final Random _random;

  Timer? _idleTimer;
  Timer? _idleResetTimer;

  PicoAnimationState _state = PicoAnimationState.idle;
  PicoIdleMicroAnimation _idleMicroAnimation = PicoIdleMicroAnimation.none;

  PicoAnimationState get state => _state;
  PicoIdleMicroAnimation get idleMicroAnimation => _idleMicroAnimation;

  void setSceneType(String sceneType) {
    setState(PicoSceneAnimationMapper.fromSceneType(sceneType));
  }

  void setState(PicoAnimationState nextState) {
    _state = nextState;

    if (_state == PicoAnimationState.idle) {
      _startIdleLoop();
    } else {
      _cancelIdleLoop();
      _idleMicroAnimation = PicoIdleMicroAnimation.none;
    }

    notifyListeners();
  }

  void _startIdleLoop() {
    _idleMicroAnimation = PicoIdleMicroAnimation.none;
    _idleTimer?.cancel();
    _idleResetTimer?.cancel();
    _scheduleNextIdleMicroAnimation();
  }

  void _scheduleNextIdleMicroAnimation() {
    final delaySeconds = 3 + _random.nextInt(5);
    _idleTimer = Timer(Duration(seconds: delaySeconds), _triggerIdleMicroAnimation);
  }

  void _triggerIdleMicroAnimation() {
    if (_state != PicoAnimationState.idle) {
      return;
    }

    final options = <PicoIdleMicroAnimation>[
      PicoIdleMicroAnimation.blink,
      PicoIdleMicroAnimation.breathing,
      PicoIdleMicroAnimation.headMove,
      PicoIdleMicroAnimation.wingMove,
    ];

    _idleMicroAnimation = options[_random.nextInt(options.length)];
    notifyListeners();

    final resetDelay = _idleMicroAnimation == PicoIdleMicroAnimation.breathing
        ? const Duration(milliseconds: 1200)
        : const Duration(milliseconds: 700);

    _idleResetTimer?.cancel();
    _idleResetTimer = Timer(resetDelay, () {
      if (_state != PicoAnimationState.idle) {
        return;
      }
      _idleMicroAnimation = PicoIdleMicroAnimation.none;
      notifyListeners();
      _scheduleNextIdleMicroAnimation();
    });
  }

  void _cancelIdleLoop() {
    _idleTimer?.cancel();
    _idleResetTimer?.cancel();
    _idleTimer = null;
    _idleResetTimer = null;
  }

  @override
  void dispose() {
    _cancelIdleLoop();
    super.dispose();
  }
}
