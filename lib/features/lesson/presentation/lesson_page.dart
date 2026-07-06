import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_playback_service.dart';
import '../data/models/mission_model.dart';
import '../data/models/scene_model.dart';
import '../data/repositories/mission_repository.dart';
import 'widgets/answer_button.dart';
import 'widgets/audio_button.dart';
import 'widgets/lesson_complete_card.dart';
import 'widgets/scene_action_button.dart';
import 'widgets/word_card.dart';
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
  final MissionRepository _repository = MissionRepository();
  final AudioPlaybackService _audioPlaybackService = NoopAudioPlaybackService();

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
    final mission = await _repository.loadMission(widget.missionId);
    await _audioPlaybackService.prepareForMission(widget.missionId);

    if (!mounted) return;
    setState(() {
      _mission = mission;
      _isLoading = false;
      _showIntroBubble = false;
    });

    _scheduleIntroBubble();
  }

  @override
  void dispose() {
    _audioPlaybackService.stop();
    super.dispose();
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
      _scheduleReturnToHome();
    }
  }

  void _markMissionCompleted() {
    if (_isCompletionSaved) return;

    final mission = _mission;
    if (mission == null) return;

    _isCompletionSaved = true;
    _repository.saveProgress(
      mission.id,
      completed: true,
      xpEarned: mission.xpReward,
      courageEarned: mission.courageReward,
    );
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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _MissionHeader(
                    chapterLabel: 'Chapter 1',
                    missionLabel: 'Mission 1 / 10',
                    title: mission.title,
                    sceneLabel: 'Scene $visualSceneIndex / $sceneTotal',
                    progress: sceneTotal == 0
                        ? 0
                        : (visualSceneIndex / sceneTotal).clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 14),
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
      return LessonCompleteCard(
        xp: _mission?.xpReward ?? 20,
        courage: _mission?.courageReward ?? 10,
        badge: _mission?.badge ?? '',
        title: complete?.title ?? 'Görev tamamlandı',
        message: complete?.body ?? 'Bugün ilk cesur adımını attın.',
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      );
    }

    switch (scene.type) {
      case 'intro':
        return _FadeInCard(
          child: Column(
            key: const ValueKey<String>('scene_intro'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _IntroAnimationPanel(showBubble: _showIntroBubble),
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: _showIntroBubble ? 1 : 0,
                duration: const Duration(milliseconds: 350),
                child: AnimatedSlide(
                  offset: _showIntroBubble ? Offset.zero : const Offset(0, 0.08),
                  duration: const Duration(milliseconds: 350),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _TypewriterText(
                      text: scene.body,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SceneActionButton(
                label: scene.prompt.isNotEmpty ? scene.prompt : 'Maceraya Başla',
                onPressed: _goToNextScene,
                isLarge: true,
              ),
            ],
          ),
        );
      case 'story':
        return _FadeInCard(
          child: _StoryScene(scene: scene, onNext: _goToNextScene),
        );
      case 'dialogue':
        return _FadeInCard(
          child: _DialogueScene(scene: scene, onNext: _goToNextScene),
        );
      case 'word':
        return _FadeInCard(
          child: _WordScene(
            scene: scene,
            onPlayAudio: () => _audioPlaybackService.playSceneCue('scene_word_audio'),
            onReplayAudio: () => _audioPlaybackService.playSceneCue('scene_word_repeat'),
            onNext: _goToNextScene,
          ),
        );
      case 'practice':
        return _FadeInCard(
          child: _PracticeScene(
            scene: scene,
            onSkip: _goToNextScene,
            onNext: _goToNextScene,
          ),
        );
      case 'quiz':
        return _FadeInCard(
          child: _QuizScene(
            scene: scene,
            selectedAnswerIndex: _selectedAnswerIndex,
            showFeedback: _showFeedback,
            isCorrect: _isCorrect,
            showHint: _showHint,
            onAnswer: _handleAnswer,
            onShowHint: () {
              setState(() {
                _showHint = true;
              });
            },
          ),
        );
      case 'celebration':
        return _FadeInCard(
          child: _CelebrationScene(
            scene: scene,
            badge: _mission?.badge ?? 'İlk Adım',
            xp: _mission?.xpReward ?? 20,
            courage: _mission?.courageReward ?? 10,
            onNext: _goToNextScene,
          ),
        );
      case 'realLifeTip':
      case 'real_life':
      case 'real_life_tip':
        return _FadeInCard(
          child: _RealLifeScene(scene: scene, onNext: _goToNextScene),
        );
      case 'complete':
        _markMissionCompleted();
        _scheduleReturnToHome();
        return LessonCompleteCard(
          xp: _mission?.xpReward ?? 20,
          courage: _mission?.courageReward ?? 10,
          badge: _mission?.badge ?? '',
          title: scene.title,
          message: scene.body,
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
      if (item.type == 'complete') {
        return item;
      }
    }
    return null;
  }
}

class _MissionHeader extends StatelessWidget {
  const _MissionHeader({
    required this.chapterLabel,
    required this.missionLabel,
    required this.title,
    required this.sceneLabel,
    required this.progress,
  });

  final String chapterLabel;
  final String missionLabel;
  final String title;
  final String sceneLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderPill(label: chapterLabel),
              _HeaderPill(label: missionLabel),
              _HeaderPill(label: sceneLabel),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _IntroAnimationPanel extends StatelessWidget {
  const _IntroAnimationPanel({required this.showBubble});

  final bool showBubble;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF6DB), Color(0xFFE7F5FF)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wb_sunny_rounded, color: Colors.amber.shade700),
              const SizedBox(width: 6),
              Text(
                'Sabah • Okul Girişi',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Kuş sesleri • Hafif arka plan müziği',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 950),
            curve: Curves.easeInOut,
            builder: (context, progress, child) {
              final flyInX = (1 - progress) * -72;
              final lookAround = progress > 0.45 ? (progress - 0.45) * 0.09 : 0.0;
              final smileScale = progress > 0.62 ? 1 + ((progress - 0.62) * 0.08) : 1.0;
              final waveY = progress > 0.72 ? ((progress - 0.72) * 9) : 0.0;
              final flap = progress > 0.82 ? ((progress - 0.82) * 0.20) : 0.0;

              return Transform.translate(
                offset: Offset(flyInX, waveY),
                child: Transform.scale(
                  scale: smileScale,
                  child: Transform.rotate(
                    angle: lookAround + flap,
                    child: child,
                  ),
                ),
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🦜', style: TextStyle(fontSize: 50)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (showBubble)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Pico',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StoryScene extends StatelessWidget {
  const _StoryScene({required this.scene, required this.onNext});

  final SceneModel scene;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (scene.character.isNotEmpty)
          Text(
            scene.character,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
          ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                scene.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    scene.illustration.isNotEmpty ? scene.illustration : '🏫',
                    style: const TextStyle(fontSize: 42),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                scene.body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SceneActionButton(label: 'Devam', onPressed: onNext),
      ],
    );
  }
}

class _DialogueScene extends StatelessWidget {
  const _DialogueScene({required this.scene, required this.onNext});

  final SceneModel scene;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (scene.character.isNotEmpty)
          Text(
            scene.character,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
          ),
        const SizedBox(height: 16),
        Text(
          scene.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.92, end: 1.0),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          builder: (context, bubbleScale, child) {
            return Transform.scale(scale: bubbleScale, child: child);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: -8, end: 8),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, waveOffset, child) {
                    return Transform.translate(
                      offset: Offset(0, waveOffset),
                      child: child,
                    );
                  },
                  child: const Text('👩‍🏫', style: TextStyle(fontSize: 52)),
                ),
                const SizedBox(height: 10),
                Text(
                  scene.body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F7EC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    scene.answer.isNotEmpty ? scene.answer : 'Olá!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SceneActionButton(
          label: scene.prompt.isNotEmpty ? scene.prompt : 'Devam',
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _WordScene extends StatelessWidget {
  const _WordScene({
    required this.scene,
    required this.onPlayAudio,
    required this.onReplayAudio,
    required this.onNext,
  });

  final SceneModel scene;
  final VoidCallback onPlayAudio;
  final VoidCallback onReplayAudio;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (scene.character.isNotEmpty)
          Text(
            scene.character,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
          ),
        const SizedBox(height: 12),
        Text(
          scene.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        WordCard(
          portugueseWord: scene.body,
          turkishMeaning: scene.answer,
          hint: 'Portekizce kelime',
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AudioButton(
              label: 'Ses',
              icon: Icons.volume_up_rounded,
              onPressed: onPlayAudio,
            ),
            const SizedBox(width: 12),
            AudioButton(
              label: 'Tekrar',
              icon: Icons.refresh_rounded,
              onPressed: onReplayAudio,
            ),
          ],
        ),
        const SizedBox(height: 20),
        SceneActionButton(label: 'Devam', onPressed: onNext),
      ],
    );
  }
}

class _PracticeScene extends StatefulWidget {
  const _PracticeScene({
    required this.scene,
    required this.onSkip,
    required this.onNext,
  });

  final SceneModel scene;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  State<_PracticeScene> createState() => _PracticeSceneState();
}

class _PracticeSceneState extends State<_PracticeScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.scene.character.isNotEmpty)
          Text(
            widget.scene.character,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
          ),
        const SizedBox(height: 12),
        Text(
          widget.scene.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.scene.body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = 1 + (_pulseController.value * 0.08);
            return Transform.scale(
              scale: _isListening ? pulse : 1,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isListening = !_isListening;
              });
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _isListening ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: _isListening ? 0.24 : 0.12),
                    blurRadius: _isListening ? 20 : 10,
                    spreadRadius: _isListening ? 6 : 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.mic_rounded,
                size: 54,
                color: _isListening ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedOpacity(
          opacity: _isListening ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            'Dinleniyor...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: widget.onSkip, child: const Text('Atla')),
        const SizedBox(height: 18),
        SceneActionButton(label: 'Devam', onPressed: widget.onNext),
      ],
    );
  }
}

class _QuizScene extends StatelessWidget {
  const _QuizScene({
    required this.scene,
    required this.selectedAnswerIndex,
    required this.showFeedback,
    required this.isCorrect,
    required this.showHint,
    required this.onAnswer,
    required this.onShowHint,
  });

  final SceneModel scene;
  final int? selectedAnswerIndex;
  final bool showFeedback;
  final bool isCorrect;
  final bool showHint;
  final ValueChanged<int> onAnswer;
  final VoidCallback onShowHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          scene.prompt,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 20),
        ...List.generate(scene.options.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnswerButton(
              label: scene.options[index],
              isCorrect: scene.options[index] == scene.answer,
              isSelected: selectedAnswerIndex == index,
              onPressed: () => onAnswer(index),
            ),
          );
        }),
        if (showFeedback)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                Text(
                  isCorrect ? 'Harika!' : 'Güzel denedin.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isCorrect ? AppColors.primary : Colors.orange.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (!isCorrect) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onShowHint,
                    icon: const Icon(Icons.lightbulb_outline_rounded),
                    label: const Text('İpucu'),
                  ),
                  if (showHint)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        scene.tip.isNotEmpty ? scene.tip : 'Öğretmen seni selamlıyor.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _CelebrationScene extends StatefulWidget {
  const _CelebrationScene({
    required this.scene,
    required this.badge,
    required this.xp,
    required this.courage,
    required this.onNext,
  });

  final SceneModel scene;
  final String badge;
  final int xp;
  final int courage;
  final VoidCallback onNext;

  @override
  State<_CelebrationScene> createState() => _CelebrationSceneState();
}

class _CelebrationSceneState extends State<_CelebrationScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );
    final xpAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
    );
    final courageAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.82, curve: Curves.easeOut),
    );
    final picoAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.82, 1.0, curve: Curves.easeOutBack),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(6, (index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: -90, end: 280),
                  duration: Duration(milliseconds: 1200 + (index * 120)),
                  curve: Curves.easeIn,
                  builder: (context, value, child) {
                    return Transform.translate(offset: Offset(0, value), child: child);
                  },
                  child: Text(index.isEven ? '🎉' : '✨', style: const TextStyle(fontSize: 22)),
                );
              }),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.scene.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.scene.body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: badgeAnim,
              child: _AnimatedRewardPill(
                text: '🏅 ${widget.badge}',
                textColor: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: xpAnim,
              child: AnimatedBuilder(
                animation: xpAnim,
                builder: (context, _) {
                  final value = (widget.xp * xpAnim.value).round();
                  return _AnimatedRewardPill(
                    text: '⭐ +$value XP',
                    textColor: AppColors.primary,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.22),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: courageAnim,
              child: AnimatedBuilder(
                animation: courageAnim,
                builder: (context, _) {
                  final value = (widget.courage * courageAnim.value).round();
                  return _AnimatedRewardPill(
                    text: '❤️ +$value Cesaret',
                    textColor: Colors.orange.shade800,
                    backgroundColor: Colors.orange.withValues(alpha: 0.18),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.05).animate(picoAnim),
              child: const Text('🦜', style: TextStyle(fontSize: 56)),
            ),
            const SizedBox(height: 24),
            SceneActionButton(label: 'Devam', onPressed: widget.onNext),
          ],
        ),
      ],
    );
  }
}

class _RealLifeScene extends StatelessWidget {
  const _RealLifeScene({required this.scene, required this.onNext});

  final SceneModel scene;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          scene.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          scene.body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(height: 24),
        SceneActionButton(label: 'Devam', onPressed: onNext),
      ],
    );
  }
}

class _TypewriterText extends StatefulWidget {
  const _TypewriterText({
    required this.text,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _durationFor(widget.text),
    )..forward();
  }

  Duration _durationFor(String text) {
    final ms = (text.length * 18).clamp(250, 3000);
    return Duration(milliseconds: ms);
  }

  @override
  void didUpdateWidget(covariant _TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.dispose();
      _controller = AnimationController(
        vsync: this,
        duration: _durationFor(widget.text),
      )..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _completeNow() {
    _controller.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _completeNow,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final visibleChars = (widget.text.length * _controller.value).floor();
          final visibleText = widget.text.substring(0, visibleChars.clamp(0, widget.text.length));
          return Text(
            visibleText,
            textAlign: TextAlign.center,
            style: widget.style,
          );
        },
      ),
    );
  }
}

class _FadeInCard extends StatelessWidget {
  const _FadeInCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      builder: (context, value, widgetChild) {
        return Opacity(opacity: value, child: widgetChild);
      },
      child: child,
    );
  }
}

class _AnimatedRewardPill extends StatelessWidget {
  const _AnimatedRewardPill({
    required this.text,
    required this.textColor,
    required this.backgroundColor,
  });

  final String text;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
      ),
    );
  }
}
