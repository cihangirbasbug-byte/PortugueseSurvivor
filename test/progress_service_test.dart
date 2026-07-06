import 'package:flutter_test/flutter_test.dart';
import 'package:portuguese_survivor/core/services/progress_service.dart';
import 'package:portuguese_survivor/features/lesson/data/models/mission_model.dart';
import 'package:portuguese_survivor/features/lesson/data/models/scene_model.dart';
import 'package:portuguese_survivor/features/lesson/data/repositories/mission_repository.dart';

class _FakeMissionRepository extends MissionRepository {
  _FakeMissionRepository(this._missions, this._progressByMissionId);

  final List<MissionModel> _missions;
  final Map<String, Map<String, dynamic>> _progressByMissionId;

  @override
  Future<List<MissionModel>> loadChapterMissions(String chapterId) async {
    return _missions;
  }

  @override
  Future<Map<String, dynamic>> loadProgress(String missionId) async {
    return _progressByMissionId[missionId] ??
        {
          'completed': false,
          'xpEarned': 0,
          'courageEarned': 0,
          'unlocked': false,
        };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressService', () {
    test('summarizes xp, courage, completion percent, and badges', () async {
      const mission001 = MissionModel(
        id: 'mission_001',
        title: 'İlk Okul Günüm',
        description: '',
        duration: '3 minutes',
        xpReward: 20,
        courageReward: 10,
        badge: 'İlk Adım',
        emotionGoal: '',
        learningGoal: '',
        realLifeGoal: '',
        scenes: <SceneModel>[],
      );
      const mission002 = MissionModel(
        id: 'mission_002',
        title: 'Benim Adım',
        description: '',
        duration: '3 minutes',
        xpReward: 20,
        courageReward: 10,
        badge: 'Kendimi Tanıttım',
        emotionGoal: '',
        learningGoal: '',
        realLifeGoal: '',
        scenes: <SceneModel>[],
      );

      final repository = _FakeMissionRepository(
        const <MissionModel>[mission001, mission002],
        <String, Map<String, dynamic>>{
          'mission_001': {
            'completed': true,
            'xpEarned': 20,
            'courageEarned': 10,
            'unlocked': true,
          },
          'mission_002': {
            'completed': true,
            'xpEarned': 20,
            'courageEarned': 10,
            'unlocked': true,
          },
        },
      );
      final progressService = ProgressService(repository: repository);

      final summary = await progressService.summarizeChapter('chapter_01');

      expect(summary.totalXp, 40);
      expect(summary.totalCourage, 20);
      expect(summary.completionPercent, 1.0);
      expect(summary.badges, contains(mission001.badge));
      expect(summary.badges, contains(mission002.badge));
    });
  });
}
