import 'package:flutter/material.dart';

import '../../../core/animation/pico_animation_controller.dart';
import '../../../core/services/mission_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/services/audio_playback_service.dart';
import '../../../shared/widgets/mission_header.dart';
import '../data/models/mission_model.dart';
import '../data/models/scene_model.dart';
import 'scenes/celebration_scene.dart';
import 'scenes/dialogue_scene.dart';
import 'scenes/intro_scene.dart';
import 'scenes/mission_complete_scene.dart';
import 'scenes/practice_scene.dart';
import 'scenes/quiz_scene.dart';
import 'scenes/real_life_scene.dart';
import 'scenes/story_scene.dart';
import 'scenes/word_scene.dart';
import 'widgets/xp_dialog.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({
    super.key,
    required this.missionId,
  });

  final String missionId;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final MissionManager _missionManager = MissionManager();
  final AudioPlaybackService _audioPlaybackService = NoopAudioPlaybackService();
  final PicoAnimationController _picoAnimationController =
      PicoAnimationController();

  MissionModel? _mission;
  int _sceneIndex = 0;
  int? _selectedAnswerIndex;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _showHint = false;
  bool _isLoading = true;
  bool _isReturningHome = false;
  bool _isCompletionSaved = false;
  bool _showIntroBubble = false;

  @override
  void initState() {
    super.initState();
    _loadMission();
  }

  Future<void> _loadMission() async {
    final mission = await _missionManager.loadMission(widget.missionId);
    await _audioPlaybackService.prepareForMission(widget.missionId);

    if (!mounted) return;
    setState(() {
      _mission = mission;
      _isLoading = false;
      _showIntroBubble = false;
    });

    _syncPicoAnimationForCurrentScene();
    _scheduleIntroBubble();
  }

  @override
  void dispose() {
    _audioPlaybackService.stop();
    _picoAnimationController.dispose();
    super.dispose();
  }

  void _syncPicoAnimationForCurrentScene() {
    final mission = _mission;
    if (mission == null) {
      return;
    }

    final usePicoAnimations = mission.id == 'mission_001';
    if (!usePicoAnimations) {
      _picoAnimationController.setState(PicoAnimationState.idle);
      return;
    }

    final scene = _sceneIndex < mission.scenes.length
        ? mission.scenes[_sceneIndex]
        : _resolveCompleteScene();
    final sceneType = scene?.type ?? 'mission_complete';
    _picoAnimationController.setSceneType(sceneType);
  }

  void _scheduleIntroBubble() {
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted || _sceneIndex != 0) return;
      setState(() {
        _showIntroBubble = true;
      });
    });
  }

  void _handleAnswer(int index) {
    final scene = _mission?.scenes[_sceneIndex];
    final isCorrect = scene?.answer == scene?.options[index];

    setState(() {
      _selectedAnswerIndex = index;
      _showFeedback = true;
      _isCorrect = isCorrect;
      _showHint = false;
    });

    if (isCorrect) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => XpDialog(
          title: 'Harika!',
          message: 'İlk Portekizce kelimeni öğrendin.',
          xp: _mission?.xpReward ?? 20,
          courage: _mission?.courageReward ?? 10,
          onPressed: () {
            Navigator.of(context).pop();
            _goToNextScene();
          },
        ),
      );
    }
  }

  void _goToNextScene() {
    final mission = _mission;
    if (mission == null) return;

    if (_sceneIndex < mission.scenes.length - 1) {
      final nextSceneIndex = _sceneIndex + 1;
      setState(() {
        _sceneIndex = nextSceneIndex;
        _selectedAnswerIndex = null;
        _showFeedback = false;
        _showHint = false;
        if (nextSceneIndex != 0) {
          _showIntroBubble = false;
        }
      });
      _syncPicoAnimationForCurrentScene();

      if (nextSceneIndex == 0) {
        _scheduleIntroBubble();
      }

      final nextScene = mission.scenes[nextSceneIndex];
      if (nextScene.type == 'complete') {
        _markMissionCompleted();
        _scheduleReturnToHome();
      }
    } else {
      _markMissionCompleted();
      setState(() {
        _sceneIndex = mission.scenes.length;
      });
      _syncPicoAnimationForCurrentScene();
      _scheduleReturnToHome();
    }
  }

  void _markMissionCompleted() {
    if (_isCompletionSaved) return;

    final mission = _mission;
    if (mission == null) return;

    _isCompletionSaved = true;
    _missionManager.completeMission(mission);
  }

  void _scheduleReturnToHome() {
    if (_isReturningHome) return;
    _isReturningHome = true;
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _mission == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final mission = _mission!;
    final scene = _sceneIndex < mission.scenes.length ? mission.scenes[_sceneIndex] : null;
    final sceneTotal = mission.scenes.length;
    final visualSceneIndex = scene == null ? sceneTotal : (_sceneIndex + 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Görev'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  MissionHeader(
                    chapterLabel: 'Chapter 1',
                    missionLabel: 'Mission 1 / 10',
                    title: mission.title,
                    sceneLabel: 'Scene $visualSceneIndex / $sceneTotal',
                    progress: sceneTotal == 0
                        ? 0
                        : (visualSceneIndex / sceneTotal).clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(_sceneIndex),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                child: _buildSceneContent(scene),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSceneContent(SceneModel? scene) {
    if (scene == null) {
      final complete = _resolveCompleteScene();
      return MissionCompleteScene(
        xp: _mission?.xpReward ?? 20,
        courage: _mission?.courageReward ?? 10,
        badge: _mission?.badge ?? '',
        title: complete?.title ?? 'Görev tamamlandı',
        message: complete?.body ?? 'Bugün ilk cesur adımını attın.',
        picoAnimationController: _picoAnimationController,
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      );
    }

    switch (scene.type) {
      case 'intro':
        return IntroScene(
          scene: scene,
          showBubble: _showIntroBubble,
          picoAnimationController: _picoAnimationController,
          onNext: _goToNextScene,
        );
      case 'story':
        return StoryScene(
          scene: scene,
          onNext: _goToNextScene,
        );
      case 'dialogue':
        return DialogueScene(
          scene: scene,
          onNext: _goToNextScene,
        );
      case 'word':
        return WordScene(
          scene: scene,
          onPlayAudio: () => _audioPlaybackService.playSceneCue('scene_word_audio'),
          onReplayAudio: () => _audioPlaybackService.playSceneCue('scene_word_repeat'),
          onNext: _goToNextScene,
        );
      case 'practice':
        return PracticeScene(
          scene: scene,
          onSkip: _goToNextScene,
          onNext: _goToNextScene,
        );
      case 'quiz':
        return QuizScene(
          scene: scene,
          selectedAnswerIndex: _selectedAnswerIndex,
          showFeedback: _showFeedback,
          isCorrect: _isCorrect,
          showHint: _showHint,
          onAnswer: _handleAnswer,
          picoAnimationController: _picoAnimationController,
          onShowHint: () {
            setState(() {
              _showHint = true;
            });
          },
        );
      case 'celebration':
        return CelebrationScene(
          scene: scene,
          badge: _mission?.badge ?? 'İlk Adım',
          xp: _mission?.xpReward ?? 20,
          courage: _mission?.courageReward ?? 10,
          picoAnimationController: _picoAnimationController,
          onNext: _goToNextScene,
        );
      case 'realLifeTip':
      case 'real_life':
      case 'real_life_tip':
        return RealLifeScene(
          scene: scene,
          onNext: _goToNextScene,
        );
      case 'complete':
      case 'mission_complete':
        _markMissionCompleted();
        _scheduleReturnToHome();
        return MissionCompleteScene(
          xp: _mission?.xpReward ?? 20,
          courage: _mission?.courageReward ?? 10,
          badge: _mission?.badge ?? '',
          title: scene.title,
          message: scene.body,
          picoAnimationController: _picoAnimationController,
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  SceneModel? _resolveCompleteScene() {
    final scenes = _mission?.scenes ?? const <SceneModel>[];
    for (final item in scenes) {
      if (item.type == 'complete' || item.type == 'mission_complete') {
        return item;
      }
    }
    return null;
  }
}
