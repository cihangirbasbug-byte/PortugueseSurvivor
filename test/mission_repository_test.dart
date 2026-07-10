import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portuguese_survivor/features/lesson/data/repositories/mission_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MissionRepository', () {
    test('loads a mission from the local JSON asset', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      final mission = await repository.loadMission('mission_001');

      expect(mission.id, 'mission_001');
      expect(mission.title, 'İlk Okul Günüm');
      expect(mission.scenes, isNotEmpty);
    });

    test('saves and loads mission progress locally', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      await repository.saveProgress(
        'mission_001',
        completed: true,
        xpEarned: 20,
        courageEarned: 5,
      );

      final progress = await repository.loadProgress('mission_001');

      expect(progress['completed'], true);
      expect(progress['xpEarned'], 20);
      expect(progress['courageEarned'], 5);
    });

    test('stores and reads unlocked mission state', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      await repository.setMissionUnlocked('mission_002', true);

      final second = await repository.loadProgress('mission_002');

      expect(second['unlocked'], true);
    });

    test('loads chapter missions without hardcoded chapter rules', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      final missions = await repository.loadChapterMissions('chapter_01');

      expect(missions.length, greaterThanOrEqualTo(10));
      expect(missions.first.id, 'mission_001');
    });

    test('discovers available mission chapters from asset paths', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      final chapters = await repository.loadAvailableChapters();

      expect(chapters, contains('chapter_01'));
    });

    test('loads Mission 002 with requested rewards and flow', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      final mission = await repository.loadMission('mission_002');

      expect(mission.title, 'Benim Adım');
      expect(mission.learningGoal, 'Meu nome é...');
      expect(mission.courageReward, 15);
      expect(mission.badge, 'Kendimi Tanıttım');
      expect(
        mission.scenes.map((scene) => scene.type).toList(),
        <String>[
          'intro',
          'dialogue',
          'word',
          'practice',
          'quiz',
          'celebration',
          'real_life',
          'mission_complete',
        ],
      );
    });

    test('loads Mission 003 with requested rewards and flow', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      final mission = await repository.loadMission('mission_003');

      expect(mission.title, 'Öğretmenimi Anlıyorum');
      expect(mission.learningGoal, 'Senta-te.');
      expect(mission.courageReward, 15);
      expect(mission.badge, 'İlk Yönerge');
      expect(
        mission.scenes.map((scene) => scene.type).toList(),
        <String>[
          'intro',
          'story',
          'dialogue',
          'word',
          'practice',
          'quiz',
          'celebration',
          'real_life',
          'mission_complete',
        ],
      );
    });

    test('loads Mission 005 with requested rewards and flow', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      final mission = await repository.loadMission('mission_005');

      expect(mission.title, 'İlk Arkadaşım');
      expect(mission.learningGoal, 'Queres brincar comigo?');
      expect(mission.courageReward, 15);
      expect(mission.badge, 'İlk Arkadaş');
      expect(
        mission.scenes.map((scene) => scene.type).toList(),
        <String>[
          'intro',
          'story',
          'dialogue',
          'word',
          'practice',
          'quiz',
          'celebration',
          'real_life',
          'mission_complete',
        ],
      );
    });

    test('loads Mission 006 with requested rewards and flow', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      final mission = await repository.loadMission('mission_006');

      expect(mission.title, 'Birlikte Oynayalım');
      expect(mission.learningGoal, 'Vamos brincar!');
      expect(mission.courageReward, 15);
      expect(mission.badge, 'Takım Oyuncusu');
      expect(
        mission.scenes.map((scene) => scene.type).toList(),
        <String>[
          'intro',
          'story',
          'dialogue',
          'word',
          'practice',
          'quiz',
          'celebration',
          'real_life',
          'mission_complete',
        ],
      );
    });

    test('loads Mission 007 with requested rewards and flow', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      final mission = await repository.loadMission('mission_007');

      expect(mission.title, 'Yardım İsteyebilirim');
      expect(mission.learningGoal, 'Podes ajudar-me?');
      expect(mission.courageReward, 15);
      expect(mission.badge, 'Cesur Yardımcı');
      expect(
        mission.scenes.map((scene) => scene.type).toList(),
        <String>[
          'intro',
          'story',
          'dialogue',
          'practice',
          'quiz',
          'celebration',
          'real_life',
          'mission_complete',
        ],
      );
    });

    test('loads Mission 008 with requested rewards and flow', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      final mission = await repository.loadMission('mission_008');

      expect(mission.title, 'Su İsteyebilirim');
      expect(mission.learningGoal, 'Posso beber água?');
      expect(mission.courageReward, 15);
      expect(mission.badge, 'Cesur İzin');
      expect(
        mission.scenes.map((scene) => scene.type).toList(),
        <String>[
          'intro',
          'story',
          'dialogue',
          'practice',
          'quiz',
          'celebration',
          'real_life',
          'mission_complete',
        ],
      );
    });
  });
}
