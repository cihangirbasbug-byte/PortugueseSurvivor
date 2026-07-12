import 'package:flutter/material.dart';

import '../../../core/animation/pico_animation_controller.dart';
import '../../../core/services/audio_playback_service.dart';
import '../../../core/services/mission_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/design_system/dialogue_bubble.dart';
import '../../../shared/widgets/mission_header.dart';
import '../../../shared/widgets/pico_avatar.dart';
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
  final PicoAnimationController _picoAnimationController = PicoAnimationController();

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
    if (mission == null) return;

    final scene = _sceneIndex < mission.scenes.length ? mission.scenes[_sceneIndex] : _resolveCompleteScene();
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
          message: 'Ilk Portekizce kelimeni ogrendin.',
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
    final missionNumber = int.tryParse(mission.id.replaceFirst('mission_', ''));
    final missionLabel = missionNumber == null
        ? 'Mission / 10'
        : 'Mission ${missionNumber.toString().padLeft(2, '0')} / 10';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9EA),
      appBar: AppBar(
        title: const Text('Lesson'),
        backgroundColor: const Color(0xFFFFF9EA),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF9EA), Color(0xFFEAF6FF), Color(0xFFFFF8D0)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _LessonBackgroundDecor(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      children: [
                        _LessonHeroBanner(
                          header: 'Classroom',
                          scene: scene,
                          controller: _picoAnimationController,
                        ),
                        const SizedBox(height: 10),
                        MissionHeader(
                          chapterLabel: 'Chapter 1',
                          missionLabel: missionLabel,
                          title: mission.title,
                          sceneLabel: 'Scene $visualSceneIndex / $sceneTotal',
                          progress: sceneTotal == 0 ? 0 : (visualSceneIndex / sceneTotal).clamp(0.0, 1.0),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFFFCF2), Color(0xFFF0F9FF)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
        title: complete?.title ?? 'Gorev tamamlandi',
        message: complete?.body ?? 'Bugun ilk cesur adimini attin.',
        picoAnimationController: _picoAnimationController,
        showChapterSummary: _mission?.id == 'mission_010',
        chapterId: 'chapter_01',
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
        return StoryScene(scene: scene, onNext: _goToNextScene);
      case 'dialogue':
        return DialogueScene(scene: scene, onNext: _goToNextScene);
      case 'word':
        return WordScene(
          scene: scene,
          onPlayAudio: () => _audioPlaybackService.playSceneCue('scene_word_audio'),
          onReplayAudio: () => _audioPlaybackService.playSceneCue('scene_word_repeat'),
          onNext: _goToNextScene,
        );
      case 'practice':
        return PracticeScene(scene: scene, onSkip: _goToNextScene, onNext: _goToNextScene);
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
          badge: _mission?.badge ?? 'Ilk Adim',
          xp: _mission?.xpReward ?? 20,
          courage: _mission?.courageReward ?? 10,
          picoAnimationController: _picoAnimationController,
          onNext: _goToNextScene,
        );
      case 'realLifeTip':
      case 'real_life':
      case 'real_life_tip':
        return RealLifeScene(scene: scene, onNext: _goToNextScene);
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
          showChapterSummary: _mission?.id == 'mission_010',
          chapterId: 'chapter_01',
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

class _LessonBackgroundDecor extends StatelessWidget {
  const _LessonBackgroundDecor();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -20,
            top: 30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFE39D).withValues(alpha: 0.26),
              ),
            ),
          ),
          Positioned(
            right: -30,
            top: 90,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFBDE7FF).withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            left: 14,
            bottom: 88,
            child: Row(
              children: [
                Icon(Icons.school_rounded, size: 54, color: Colors.brown.shade300),
                const SizedBox(width: 6),
                Icon(Icons.person_rounded, size: 40, color: Colors.indigo.shade300),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 92,
            child: Row(
              children: [
                Icon(Icons.groups_rounded, size: 52, color: Colors.blueGrey.shade300),
                const SizedBox(width: 6),
                Icon(Icons.menu_book_rounded, size: 34, color: Colors.teal.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonHeroBanner extends StatefulWidget {
  const _LessonHeroBanner({
    required this.header,
    required this.scene,
    required this.controller,
  });

  final String header;
  final SceneModel? scene;
  final PicoAnimationController controller;

  @override
  State<_LessonHeroBanner> createState() => _LessonHeroBannerState();
}

class _LessonHeroBannerState extends State<_LessonHeroBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final bubbleText = scene == null
        ? 'Harika is cikardin, eve donmeye haziriz!'
        : (scene.prompt.isNotEmpty ? scene.prompt : 'Hazirsan devam edelim!');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFEFD1), Color(0xFFFFF9E6), Color(0xFFE8F7FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final breath = 1 + (_controller.value * 0.04);
              return Transform.scale(scale: breath, child: child);
            },
            child: PicoAvatar(size: 132, controller: widget.controller),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school_rounded, color: Colors.brown.shade300, size: 20),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${widget.header} - Teacher Sofia',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DialogueBubble(text: bubbleText, maxLines: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
