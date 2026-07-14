import 'package:flutter/material.dart';

import '../../../core/animation/pico_animation_controller.dart';
import '../../../core/services/audio_playback_service.dart';
import '../../../core/services/mission_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/character/character_layer.dart';
import '../../../shared/widgets/character/pico_character.dart';
import '../../../shared/widgets/character/teacher_character.dart';
import '../../../shared/widgets/design_system/dialogue_bubble.dart';
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
  const LessonPage({super.key, required this.missionId});

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
  bool _firstCorrectAnswerCelebrated = false;

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
      _picoAnimationController.setState(PicoAnimationState.celebrate);
      final showFirstCelebration = !_firstCorrectAnswerCelebrated;
      _firstCorrectAnswerCelebrated = true;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => XpDialog(
          title: 'Harika!',
          message: showFirstCelebration
              ? 'Ilk dogru cevabin! Pico kutluyor, Teacher Sofia gulumseyerek seni alkisliyor.'
              : 'Dogru cevap! Harika devam ediyorsun.',
          xp: _mission?.xpReward ?? 20,
          courage: _mission?.courageReward ?? 10,
          showCelebrationCharacters: showFirstCelebration,
          onPressed: () {
            Navigator.of(context).pop();
            _goToNextScene();
          },
        ),
      );
    } else {
      _picoAnimationController.setState(PicoAnimationState.encourage);
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final mission = _mission!;
    final scene = _sceneIndex < mission.scenes.length
        ? mission.scenes[_sceneIndex]
        : null;
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
              _LessonBackgroundDecor(),
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
                        const SizedBox(height: AppSpacing.xs),
                        MissionHeader(
                          chapterLabel: 'Chapter 1',
                          missionLabel: missionLabel,
                          title: mission.title,
                          sceneLabel: 'Scene $visualSceneIndex / $sceneTotal',
                          progress: sceneTotal == 0
                              ? 0
                              : (visualSceneIndex / sceneTotal).clamp(0.0, 1.0),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(
                                    0xFFFFFCF2,
                                  ).withValues(alpha: 0.88),
                                  const Color(
                                    0xFFF0F9FF,
                                  ).withValues(alpha: 0.84),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              boxShadow: AppShadows.soft,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey<int>(_sceneIndex),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight,
                                        ),
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
          onPlayAudio: () =>
              _audioPlaybackService.playSceneCue('scene_word_audio'),
          onReplayAudio: () =>
              _audioPlaybackService.playSceneCue('scene_word_repeat'),
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

class _LessonBackgroundDecor extends StatefulWidget {
  const _LessonBackgroundDecor();

  @override
  State<_LessonBackgroundDecor> createState() => _LessonBackgroundDecorState();
}

class _LessonBackgroundDecorState extends State<_LessonBackgroundDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ambient,
        builder: (context, child) {
          final drift = (_ambient.value - 0.5) * 2;
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF7EBD2),
                        const Color(0xFFE9F4FF),
                        const Color(0xFFF6EFD9),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                top: 306,
                child: CustomPaint(painter: _WoodFloorPainter()),
              ),
              Positioned(
                left: -20,
                top: 16,
                child: Opacity(
                  opacity: 0.22 + (_ambient.value * 0.18),
                  child: Container(
                    width: 226,
                    height: 226,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFE39D),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 40,
                top: 42,
                child: Transform.rotate(
                  angle: -0.26 + (drift * 0.04),
                  child: Container(
                    width: 300,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFE6A6).withValues(alpha: 0.44),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 78 + (drift * 22),
                top: 54,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.24,
                    child: Container(
                      width: 340,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFFE89C),
                            const Color(0xFFFFF6D3).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 20,
                child: _LargeWindowBand(drift: drift),
              ),
              Positioned(
                left: 18,
                top: 142,
                right: 150,
                child: Container(
                  height: 102,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B8C62),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF295F43),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'ola turma',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFDAF3DF),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(right: 16, top: 138, child: const _BookshelfPanel()),
              Positioned(
                left: 22,
                top: 248,
                child: Row(
                  children: const [
                    _PosterCard(label: 'A B C D', icon: Icons.abc_rounded),
                    SizedBox(width: 8),
                    _PosterCard(label: 'bem-vindo', icon: Icons.waving_hand_rounded),
                    SizedBox(width: 8),
                    _PosterCard(label: 'amigo', icon: Icons.favorite_rounded),
                    SizedBox(width: 8),
                    _PosterCard(label: 'obrigado', icon: Icons.pan_tool_alt_rounded),
                  ],
                ),
              ),
              Positioned(
                right: 18,
                top: 248,
                child: const Row(
                  children: [
                    _PortugalMapPoster(),
                    SizedBox(width: 8),
                    _ChildrenDrawingsPoster(),
                    SizedBox(width: 8),
                    _PortugalDecorRow(),
                  ],
                ),
              ),
              Positioned(
                right: 72,
                top: 150,
                child: Transform.translate(
                  offset: Offset(0, drift * 4),
                  child: const Opacity(
                    opacity: 0.95,
                    child: TeacherCharacter(
                      size: TeacherCharacterSize.small,
                      customSize: 82,
                      emotion: TeacherEmotion.explain,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 88,
                child: Transform.translate(
                  offset: Offset(0, drift * 5),
                  child: Row(
                    children: [
                      Icon(
                        Icons.park_rounded,
                        size: 48,
                        color: Colors.green.shade400,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.menu_book_rounded,
                        size: 42,
                        color: Colors.brown.shade300,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.draw_rounded,
                        size: 34,
                        color: Colors.orange.shade300,
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.local_florist_rounded,
                        size: 30,
                        color: Colors.green.shade500,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _DustParticlesPainter(phase: _ambient.value),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 24,
                right: 16,
                child: Opacity(
                  opacity: 0.92,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [_DeskChair(), _DeskChair(), _DeskChair()],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                bottom: 56,
                child: Icon(
                  Icons.local_florist_rounded,
                  color: Colors.green.shade500,
                  size: 34,
                ),
              ),
              Positioned(
                right: 26,
                bottom: 52,
                child: Icon(
                  Icons.local_florist_rounded,
                  color: Colors.green.shade600,
                  size: 28,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LargeWindowBand extends StatelessWidget {
  const _LargeWindowBand({required this.drift});

  final double drift;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3D5BD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD9F1FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Transform.translate(
                      offset: Offset(0, drift * 3),
                      child: Icon(
                        Icons.cloud_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BookshelfPanel extends StatelessWidget {
  const _BookshelfPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 122,
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFC79362),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(2, (shelf) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: shelf == 0 ? 8 : 0),
              decoration: BoxDecoration(
                color: const Color(0xFFA97449),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _Book(color: Color(0xFF62A8EA)),
                  _Book(color: Color(0xFFE57F5D)),
                  _Book(color: Color(0xFF7BBF7A)),
                  _Book(color: Color(0xFFF0C75E)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Book extends StatelessWidget {
  const _Book({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _PosterCard extends StatelessWidget {
  const _PosterCard({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 74,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4F7F61)),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3F4D5A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PortugalDecorRow extends StatelessWidget {
  const _PortugalDecorRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _PortugalTile(flag: true),
        SizedBox(width: 6),
        _PortugalTile(flag: false),
      ],
    );
  }
}

class _PortugalMapPoster extends StatelessWidget {
  const _PortugalMapPoster();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 74,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.panel,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_rounded, size: 18, color: Colors.green.shade700),
          const SizedBox(height: 4),
          Text(
            'Portugal',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3F4D5A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChildrenDrawingsPoster extends StatelessWidget {
  const _ChildrenDrawingsPoster();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 74,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.panel,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.palette_rounded, size: 12, color: Colors.orange.shade400),
              const SizedBox(width: 3),
              Icon(Icons.brush_rounded, size: 12, color: Colors.blue.shade400),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'cocuk\nresim',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3F4D5A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DustParticlesPainter extends CustomPainter {
  const _DustParticlesPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFF4CE).withValues(alpha: 0.22);

    for (var i = 0; i < 28; i++) {
      final x = ((i * 31.0) + (phase * 42)) % (size.width + 20) - 10;
      final y = ((i * 23.0) + (phase * 16)) % (size.height * 0.75);
      final radius = 0.8 + (i % 3) * 0.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustParticlesPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}

class _PortugalTile extends StatelessWidget {
  const _PortugalTile({required this.flag});

  final bool flag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.panel,
      ),
      child: flag
          ? Row(
              children: [
                Expanded(child: Container(color: const Color(0xFF0E8A4B))),
                Expanded(child: Container(color: const Color(0xFFE54949))),
              ],
            )
          : const Center(
              child: Icon(
                Icons.pattern_rounded,
                color: Color(0xFF3C74AD),
                size: 20,
              ),
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

class _LessonHeroBannerState extends State<_LessonHeroBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
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
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFEFD1).withValues(alpha: 0.97),
            const Color(0xFFFFF9E6).withValues(alpha: 0.95),
            const Color(0xFFE8F7FF).withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: AppShadows.soft,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final picoWidget = AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final breath = 1 + (_controller.value * 0.035);
              final float = (_controller.value - 0.5) * 7;
              return Transform.translate(
                offset: Offset(0, float),
                child: Transform.scale(scale: breath, child: child),
              );
            },
            child: CharacterLayer(
              role: CharacterRole.pico,
              size: compact ? 150 : 178,
              picoSize: compact
                  ? PicoCharacterSize.large
                  : PicoCharacterSize.hero,
              picoState: PicoCharacterState.talking,
              picoEmotion: PicoEmotion.happy,
              picoController: widget.controller,
              showPlate: false,
              enableAmbientFloat: false,
            ),
          );

          final teacherWidget = CharacterLayer(
            role: CharacterRole.teacherSofia,
            size: compact ? 82 : 104,
            teacherEmotion: _teacherEmotionForScene(scene?.type),
            showPlate: false,
            enableAmbientFloat: false,
          );

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Teacher Sofia',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF3A4A64),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pico ile Portekizce sinifina hos geldin',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF3A4A64),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: Colors.brown.shade300,
                    size: 20,
                  ),
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
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: DialogueBubble(
                  text: bubbleText,
                  maxLines: compact ? 5 : 4,
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    teacherWidget,
                    const SizedBox(width: 6),
                    picoWidget,
                  ],
                ),
                const SizedBox(height: 6),
                content,
              ],
            );
          }

          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC79664).withValues(alpha: 0.52),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  teacherWidget,
                  const SizedBox(width: 6),
                  picoWidget,
                  const SizedBox(width: 10),
                  Expanded(child: content),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  TeacherEmotion _teacherEmotionForScene(String? sceneType) {
    switch ((sceneType ?? '').toLowerCase()) {
      case 'intro':
        return TeacherEmotion.smile;
      case 'story':
      case 'dialogue':
      case 'word':
      case 'practice':
        return TeacherEmotion.explain;
      case 'quiz':
        return TeacherEmotion.listen;
      case 'celebration':
      case 'complete':
      case 'mission_complete':
        return TeacherEmotion.celebrate;
      default:
        return TeacherEmotion.encourage;
    }
  }
}

class _WoodFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..color = const Color(0xFFD7B186).withValues(alpha: 0.62);
    canvas.drawRect(Offset.zero & size, base);

    final line = Paint()
      ..color = const Color(0xFFB88C5F).withValues(alpha: 0.4)
      ..strokeWidth = 1.2;

    for (double y = 10; y < size.height; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _DeskChair extends StatelessWidget {
  const _DeskChair();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 52,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 18,
            child: Container(
              width: 70,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFD0A273),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF9B6A4D),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
