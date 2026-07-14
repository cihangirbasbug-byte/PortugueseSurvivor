import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portuguese_survivor/core/animation/pico_animation_controller.dart';
import 'package:portuguese_survivor/features/home/presentation/home_page.dart';
import 'package:portuguese_survivor/features/lesson/data/models/scene_model.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/celebration_scene.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/dialogue_scene.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/intro_scene.dart';

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

  testWidgets('m3s2 capture home', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await _pumpFor(tester, const Duration(milliseconds: 1400));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/m3s2_home.png'),
    );
  });

  testWidgets('m3s2 capture lesson intro', (tester) async {
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
      matchesGoldenFile('goldens/m3s2_lesson_intro.png'),
    );
  });

  testWidgets('m3s2 capture dialogue', (tester) async {
    const scene = SceneModel(
      type: 'dialogue',
      title: 'Ogretmen seni karsiliyor',
      body: 'Ogretmen gulumseyerek sana selam veriyor.',
      prompt: 'Devam',
      answer: 'Ola!',
      options: <String>[],
      reward: 0,
      tip: '',
      imagePath: '',
      character: 'Ogretmen',
      illustration: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFFFF9EA),
          body: DialogueScene(
            scene: scene,
            onNext: () {},
          ),
        ),
      ),
    );
    await _pumpFor(tester, const Duration(milliseconds: 900));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/m3s2_dialogue.png'),
    );
  });

  testWidgets('m3s2 capture celebration', (tester) async {
    final controller = PicoAnimationController();
    addTearDown(controller.dispose);

    const scene = SceneModel(
      type: 'celebration',
      title: 'Harika Is',
      body: 'Ilk okul gununde cok cesur bir adim attin.',
      prompt: '',
      answer: '',
      options: <String>[],
      reward: 20,
      tip: '',
      imagePath: '',
      character: 'Pico',
      illustration: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFFFF9EA),
          body: CelebrationScene(
            scene: scene,
            badge: 'Ilk Adim',
            xp: 20,
            courage: 10,
            picoAnimationController: controller,
            onNext: () {},
          ),
        ),
      ),
    );
    await _pumpFor(tester, const Duration(milliseconds: 1200));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/m3s2_celebration.png'),
    );
  });
}
