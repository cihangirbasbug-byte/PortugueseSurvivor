import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:portuguese_survivor/features/lesson/data/models/scene_model.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/word_scene.dart';

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

  testWidgets('alpha foundation capture word scene', (tester) async {
    const scene = SceneModel(
      type: 'word',
      title: 'Yeni kelime',
      body: 'Ola',
      prompt: 'Dinle ve tekrar et',
      answer: 'Merhaba',
      options: <String>[],
      reward: 0,
      tip: 'Sinifa girerken kullan',
      imagePath: '',
      character: 'Pico',
      illustration: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFFFF9EA),
          body: WordScene(
            scene: scene,
            onPlayAudio: () {},
            onReplayAudio: () {},
            onNext: () {},
          ),
        ),
      ),
    );

    await _pumpFor(tester, const Duration(milliseconds: 1700));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/alpha_foundation_word.png'),
    );
  });
}
