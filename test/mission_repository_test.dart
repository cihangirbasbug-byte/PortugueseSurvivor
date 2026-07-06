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

    test('completing a mission unlocks the next mission', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();

      await repository.saveProgress(
        'mission_001',
        completed: true,
        xpEarned: 20,
        courageEarned: 10,
      );

      final first = await repository.loadProgress('mission_001');
      final second = await repository.loadProgress('mission_002');

      expect(first['unlocked'], true);
      expect(second['unlocked'], true);
    });
  });
}
