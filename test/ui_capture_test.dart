import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portuguese_survivor/core/animation/pico_animation_controller.dart';
import 'package:portuguese_survivor/core/services/mission_manager.dart';
import 'package:portuguese_survivor/features/home/presentation/home_page.dart';
import 'package:portuguese_survivor/features/lesson/data/models/mission_model.dart';
import 'package:portuguese_survivor/features/lesson/data/models/scene_model.dart';
import 'package:portuguese_survivor/features/lesson/presentation/lesson_page.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/celebration_scene.dart';

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

MissionModel _mission(String id, String title) {
  return MissionModel(
    id: id,
    title: title,
    description: 'mock',
    duration: '5m',
    xpReward: 20,
    courageReward: 10,
    badge: 'Ilk Adim',
    emotionGoal: 'confidence',
    learningGoal: 'greeting',
    realLifeGoal: 'classroom',
    scenes: const <SceneModel>[],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture home screen b01', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await _pumpFor(tester, const Duration(milliseconds: 1400));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home_screen_b01.png'),
    );
  });

  testWidgets('capture lesson screen b01', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const MaterialApp(home: LessonPage(missionId: 'mission_001')));
    await _pumpFor(tester, const Duration(seconds: 3));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/lesson_screen_b01.png'),
    );
  });

  testWidgets('capture celebration screen b01', (tester) async {
    final controller = PicoAnimationController();
    addTearDown(controller.dispose);

    const scene = SceneModel(
      type: 'celebration',
      title: 'Harika Is!',
      body: 'Bugunku gorevi basariyla tamamladin.',
      prompt: '',
      answer: '',
      options: <String>[],
      reward: 0,
      tip: '',
      imagePath: '',
      character: '',
      illustration: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
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
      matchesGoldenFile('goldens/celebration_screen_b01.png'),
    );
  });

  testWidgets('capture chapter map b01', (tester) async {
    final states = <MissionState>[
      MissionState(mission: _mission('mission_001', 'School Entrance'), isUnlocked: true, isCompleted: true, progress: 1),
      MissionState(mission: _mission('mission_002', 'Classroom'), isUnlocked: true, isCompleted: true, progress: 1),
      MissionState(mission: _mission('mission_003', 'Playground'), isUnlocked: true, isCompleted: false, progress: 0.6),
      MissionState(mission: _mission('mission_004', 'Library'), isUnlocked: false, isCompleted: false, progress: 0),
      MissionState(mission: _mission('mission_005', 'Cafeteria'), isUnlocked: false, isCompleted: false, progress: 0),
      MissionState(mission: _mission('mission_006', 'Art Room'), isUnlocked: false, isCompleted: false, progress: 0),
      MissionState(mission: _mission('mission_007', 'Music Room'), isUnlocked: false, isCompleted: false, progress: 0),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ChapterWorldMap(
              missionStates: states,
              currentMissionId: 'mission_003',
              onMissionTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await _pumpFor(tester, const Duration(milliseconds: 800));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/map_screen_b01.png'),
    );
  });
}
