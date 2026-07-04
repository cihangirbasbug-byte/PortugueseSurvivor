import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../data/models/mission_model.dart';
import '../data/models/scene_model.dart';
import '../data/repositories/mission_repository.dart';
import 'widgets/answer_button.dart';
import 'widgets/audio_button.dart';
import 'widgets/lesson_complete_card.dart';
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
    });

    if (isCorrect) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => XpDialog(
          title: 'Harika!',
          message: 'Doğru cevap! Yeni kelimeyi öğrendin.',
          xp: scene?.reward ?? 0,
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
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _goToNextScene,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Devam'),
              ),
            ),
          ],
        );
      case 'word':
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
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _goToNextScene,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Devam'),
              ),
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
                child: Text(
                  _isCorrect ? 'Harika!' : 'Tekrar deneyelim.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _isCorrect ? AppColors.primary : Colors.orange.shade700,
                    fontWeight: FontWeight.w700,
                  ),
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
            FilledButton(
              onPressed: _goToNextScene,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Devam'),
            ),
          ],
        );
      case 'realLifeTip':
      default:
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
            FilledButton(
              onPressed: _goToNextScene,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Devam'),
            ),
          ],
        );
    }
  }
}
