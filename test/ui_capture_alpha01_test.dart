import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portuguese_survivor/core/animation/pico_animation_controller.dart';
import 'package:portuguese_survivor/features/home/presentation/home_page.dart';
import 'package:portuguese_survivor/features/lesson/presentation/lesson_page.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/mission_complete_scene.dart';
import 'package:portuguese_survivor/features/lesson/presentation/widgets/xp_dialog.dart';

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

  testWidgets('alpha01 capture home', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await _pumpFor(tester, const Duration(milliseconds: 1400));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/alpha01_home.png'),
    );
  });

  testWidgets('alpha01 capture lesson intro', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const MaterialApp(home: LessonPage(missionId: 'mission_001')));
    await _pumpFor(tester, const Duration(seconds: 3));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/alpha01_lesson_intro.png'),
    );
  });

  testWidgets('alpha01 capture first correct answer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFFFF9EA),
          body: Center(
            child: XpDialog(
              title: 'Harika!',
              message: 'Ilk dogru cevabin! Pico kutluyor, Teacher Sofia gulumseyerek seni alkisliyor.',
              xp: 20,
              courage: 10,
              showCelebrationCharacters: true,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    await _pumpFor(tester, const Duration(milliseconds: 900));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/alpha01_first_correct_answer.png'),
    );
  });

  testWidgets('alpha01 capture mission complete', (tester) async {
    final controller = PicoAnimationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MissionCompleteScene(
            xp: 20,
            courage: 10,
            badge: 'Ilk Adim',
            title: 'Gorev tamamlandi',
            message: 'Bugun sadece bir kelime ogrenmedin. Bugun ilk cesur adimini attin.',
            picoAnimationController: controller,
            onPressed: () {},
          ),
        ),
      ),
    );
    await _pumpFor(tester, const Duration(milliseconds: 1200));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/alpha01_mission_complete.png'),
    );
  });
}
