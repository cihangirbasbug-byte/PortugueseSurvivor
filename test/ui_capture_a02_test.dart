import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:portuguese_survivor/core/animation/pico_animation_controller.dart';
import 'package:portuguese_survivor/features/lesson/data/models/scene_model.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/intro_scene.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/quiz_scene.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/story_scene.dart';

Future<void> _pumpFor(
  WidgetTester tester,
  Duration duration, {
  Duration step = const Duration(milliseconds: 16),
}) async {
  var elapsed = Duration.zero;
  while (elapsed < duration) {
    await tester.pump(step);
    elapsed += step;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a02 capture lesson intro', (tester) async {
    final controller = PicoAnimationController();
    addTearDown(controller.dispose);

    const scene = SceneModel(
      type: 'intro',
      title: 'Pico yaninda',
      body: 'Merhaba! Bugun Portekizce sinifina birlikte giriyoruz.',
      prompt: 'Maceraya Basla',
      answer: '',
      options: <String>[],
      reward: 0,
      tip: '',
      imagePath: '',
      character: 'Pico',
      illustration: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFFFF9EA),
          body: IntroScene(
            scene: scene,
            showBubble: true,
            picoAnimationController: controller,
            onNext: () {},
          ),
        ),
      ),
    );
    await _pumpFor(tester, const Duration(milliseconds: 900));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/a02_lesson_intro.png'),
    );
  });

  testWidgets('a02 capture story scene', (tester) async {
    const scene = SceneModel(
      type: 'story',
      title: 'Okul girisi',
      body: 'Kapi aciliyor, yumusak bir isik sinifa doluyor.',
      prompt: 'Devam',
      answer: '',
      options: <String>[],
      reward: 0,
      tip: '',
      imagePath: '',
      character: 'Pico',
      illustration: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFFFF9EA),
          body: StoryScene(
            scene: scene,
            onNext: _noop,
          ),
        ),
      ),
    );
    await _pumpFor(tester, const Duration(milliseconds: 700));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/a02_story_scene.png'),
    );
  });

  testWidgets('a02 capture quiz scene', (tester) async {
    final controller = PicoAnimationController();
    addTearDown(controller.dispose);

    const scene = SceneModel(
      type: 'quiz',
      title: 'Kisa soru',
      body: '',
      prompt: 'Ogretmen sana selam verdiginde ne dersin?',
      answer: 'Ola!',
      options: <String>['Ola!', 'Obrigado!', 'Tchau!'],
      reward: 20,
      tip: 'Bu kelime selam vermek icin kullanilir.',
      imagePath: '',
      character: '',
      illustration: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFFFF9EA),
          body: QuizScene(
            scene: scene,
            selectedAnswerIndex: null,
            showFeedback: false,
            isCorrect: false,
            showHint: false,
            onAnswer: (_) {},
            onShowHint: _noop,
            picoAnimationController: controller,
          ),
        ),
      ),
    );
    await _pumpFor(tester, const Duration(milliseconds: 700));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/a02_quiz_scene.png'),
    );
  });
}

void _noop() {}
