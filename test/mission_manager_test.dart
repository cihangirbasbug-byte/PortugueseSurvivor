import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portuguese_survivor/core/services/mission_manager.dart';
import 'package:portuguese_survivor/core/services/progress_service.dart';
import 'package:portuguese_survivor/features/lesson/data/repositories/mission_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MissionManager', () {
    test('loads chapter mission states', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();
      final manager = MissionManager(repository: repository);

      final states = await manager.loadMissionStates('chapter_01');

      expect(states, isNotEmpty);
      expect(states.first.mission.id, 'mission_001');
      expect(states.first.isUnlocked, true);
    });

    test('completing mission unlocks next mission automatically', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();
      final manager = MissionManager(repository: repository);

      final mission = await manager.loadMission('mission_001');
      await manager.completeMission(mission);
      final currentMission = await manager.currentMission('chapter_01');

      final firstProgress = await repository.loadProgress('mission_001');
      final secondProgress = await repository.loadProgress('mission_002');

      expect(firstProgress['completed'], true);
      expect(secondProgress['unlocked'], true);
      expect(currentMission?.id, 'mission_002');
    });

    test('completing Mission 002 unlocks Mission 003 and Mission 004 follows', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();
      final manager = MissionManager(repository: repository);

      final mission1 = await manager.loadMission('mission_001');
      await manager.completeMission(mission1);

      final mission2 = await manager.loadMission('mission_002');
      await manager.completeMission(mission2);

      final currentAfterMission2 = await manager.currentMission('chapter_01');
      expect(currentAfterMission2?.id, 'mission_003');

      final mission3 = await manager.loadMission('mission_003');
      await manager.completeMission(mission3);

      final progress4 = await repository.loadProgress('mission_004');
      expect(progress4['unlocked'], true);
    });

    test('Mission 005 unlocks Mission 006 and Mission 006 unlocks Mission 007', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();
      final manager = MissionManager(repository: repository);

      final mission5 = await manager.loadMission('mission_005');
      await manager.completeMission(mission5);

      final progress6 = await repository.loadProgress('mission_006');
      expect(progress6['unlocked'], true);

      final mission6 = await manager.loadMission('mission_006');
      await manager.completeMission(mission6);

      final progress7 = await repository.loadProgress('mission_007');
      expect(progress7['unlocked'], true);
    });

    test('Mission 007 completion saves rewards/progress and unlocks Mission 008', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();
      final manager = MissionManager(repository: repository);
      final progressService = ProgressService(repository: repository);

      final mission6 = await manager.loadMission('mission_006');
      await manager.completeMission(mission6);

      final progress7Before = await repository.loadProgress('mission_007');
      expect(progress7Before['unlocked'], true);

      final mission7 = await manager.loadMission('mission_007');
      await manager.completeMission(mission7);

      final progress7After = await repository.loadProgress('mission_007');
      expect(progress7After['completed'], true);
      expect(progress7After['xpEarned'], 20);
      expect(progress7After['courageEarned'], 15);

      final progress8 = await repository.loadProgress('mission_008');
      expect(progress8['unlocked'], true);

      final states = await manager.loadMissionStates('chapter_01');
      final mission7State = states.firstWhere((state) => state.mission.id == 'mission_007');
      expect(mission7State.progress, 1.0);

      final summary = await progressService.summarizeChapter('chapter_01');
      expect(summary.badges, contains('Cesur Yardımcı'));
    });

    test('Mission 008 completion saves rewards/progress and unlocks Mission 009', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = MissionRepository();
      final manager = MissionManager(repository: repository);
      final progressService = ProgressService(repository: repository);

      final mission7 = await manager.loadMission('mission_007');
      await manager.completeMission(mission7);

      final progress8Before = await repository.loadProgress('mission_008');
      expect(progress8Before['unlocked'], true);

      final mission8 = await manager.loadMission('mission_008');
      await manager.completeMission(mission8);

      final progress8After = await repository.loadProgress('mission_008');
      expect(progress8After['completed'], true);
      expect(progress8After['xpEarned'], 20);
      expect(progress8After['courageEarned'], 15);

      final progress9 = await repository.loadProgress('mission_009');
      expect(progress9['unlocked'], true);

      final states = await manager.loadMissionStates('chapter_01');
      final mission8State = states.firstWhere((state) => state.mission.id == 'mission_008');
      expect(mission8State.progress, 1.0);

      final summary = await progressService.summarizeChapter('chapter_01');
      expect(summary.badges, contains('Cesur İzin'));
    });
  });
}
