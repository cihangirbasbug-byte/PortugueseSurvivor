import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
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
  int _step = 0;
  int? _selectedAnswerIndex;
  bool _showFeedback = false;
  bool _isCorrect = false;

  final List<String> _answers = [
    'Merhaba',
    'Hoşça kal',
    'Teşekkür ederim',
    'Lütfen',
  ];

  void _handleAnswer(int index) {
    setState(() {
      _selectedAnswerIndex = index;
      _showFeedback = true;
      _isCorrect = index == 0;
    });

    if (_isCorrect) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => XpDialog(
          title: 'Harika!',
          message: 'Doğru cevap! Yeni kelimeyi öğrendin.',
          xp: 5,
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              _step = 2;
              _selectedAnswerIndex = null;
              _showFeedback = false;
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ders 1'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Öğrenmeye Başla',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            const WordCard(
              portugueseWord: 'Olá',
              turkishMeaning: 'Merhaba',
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
                onPressed: () {
                  setState(() {
                    _step = 1;
                  });
                },
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
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Olá ne demektir?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(_answers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnswerButton(
                  label: _answers[index],
                  isCorrect: index == 0,
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
      default:
        return LessonCompleteCard(
          xp: 20,
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        );
    }
  }
}
