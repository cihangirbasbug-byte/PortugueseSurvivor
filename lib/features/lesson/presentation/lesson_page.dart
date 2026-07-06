import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
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
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final MissionRepository _repository = MissionRepository();
  MissionModel? _mission;
  int _sceneIndex = 0;
  int? _selectedAnswerIndex;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _showHint = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMission();
  }

  Future<void> _loadMission() async {
    final mission = await _repository.loadMission('mission_001');
    if (!mounted) return;
    setState(() {
      _mission = mission;
      _isLoading = false;
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
      setState(() {
        _sceneIndex += 1;
        _selectedAnswerIndex = null;
        _showFeedback = false;
        _showHint = false;
      });
    } else {
      _repository.saveProgress(
        mission.id,
        completed: true,
        xpEarned: mission.xpReward,
        courageEarned: mission.courageReward,
      );
      setState(() {
        _sceneIndex = mission.scenes.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _mission == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final scene = _sceneIndex < _mission!.scenes.length ? _mission!.scenes[_sceneIndex] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_mission!.title),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildSceneContent(scene),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSceneContent(SceneModel? scene) {
    if (scene == null) {
      return LessonCompleteCard(
        xp: _mission?.xpReward ?? 20,
        courage: _mission?.courageReward ?? 10,
        onPressed: () {
          Navigator.of(context).maybePop();
        },
      );
    }

    switch (scene.type) {
      case 'intro':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (scene.character.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  scene.character,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
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
            Text(
              scene.body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            SceneActionButton(
              label: scene.prompt.isNotEmpty ? scene.prompt : 'Başlayalım',
              onPressed: _goToNextScene,
            ),
          ],
        );
      case 'dialogue':
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                scene.body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (scene.answer.isNotEmpty)
              Text(
                scene.answer,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(height: 20),
            SceneActionButton(
              label: scene.prompt.isNotEmpty ? scene.prompt : 'Devam',
              onPressed: _goToNextScene,
            ),
          ],
        );
      case 'story':
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
            SceneActionButton(
              label: 'Devam',
              onPressed: _goToNextScene,
            ),
          ],
        );
      case 'word':
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
                  onPressed: () {},
                ),
                const SizedBox(width: 12),
                AudioButton(
                  label: 'Tekrar',
                  icon: Icons.refresh_rounded,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            SceneActionButton(
              label: 'Devam',
              onPressed: _goToNextScene,
            ),
          ],
        );
      case 'practice':
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
            Text(
              scene.body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AudioButton(
                  label: 'Mikrofon',
                  icon: Icons.mic_rounded,
                  onPressed: () {},
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _goToNextScene,
                  child: const Text('Atla'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SceneActionButton(
              label: 'Devam',
              onPressed: _goToNextScene,
            ),
          ],
        );
      case 'quiz':
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
                  isSelected: _selectedAnswerIndex == index,
                  onPressed: () => _handleAnswer(index),
                ),
              );
            }),
            if (_showFeedback)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    Text(
                      _isCorrect ? 'Harika!' : 'Güzel denedin.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _isCorrect ? AppColors.primary : Colors.orange.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!_isCorrect) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showHint = true;
                          });
                        },
                        icon: const Icon(Icons.lightbulb_outline_rounded),
                        label: const Text('İpucu'),
                      ),
                      if (_showHint)
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
      case 'celebration':
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
            SceneActionButton(
              label: 'Devam',
              onPressed: _goToNextScene,
            ),
          ],
        );
      case 'realLifeTip':
      case 'real_life':
      case 'real_life_tip':
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
            SceneActionButton(
              label: 'Devam',
              onPressed: _goToNextScene,
            ),
          ],
        );
      case 'complete':
        return LessonCompleteCard(
          xp: _mission?.xpReward ?? 20,
          courage: _mission?.courageReward ?? 10,
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
