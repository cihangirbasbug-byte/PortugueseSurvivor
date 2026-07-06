import '../../features/lesson/data/models/mission_model.dart';
import '../../features/lesson/data/repositories/mission_repository.dart';
import 'progress_service.dart';

class MissionState {
  const MissionState({
    required this.mission,
    required this.isUnlocked,
    required this.isCompleted,
    required this.progress,
  });

  final MissionModel mission;
  final bool isUnlocked;
  final bool isCompleted;
  final double progress;
}

class MissionManager {
  MissionManager({
    MissionRepository? repository,
    ProgressService? progressService,
  }) : _repository = repository ?? MissionRepository() {
    _progressService = progressService ?? ProgressService(repository: _repository);
  }

  final MissionRepository _repository;
  late final ProgressService _progressService;

  Future<MissionModel> loadMission(String missionId) async {
    final chapterId = await _repository.findMissionChapter(missionId);
    return _repository.loadMission(missionId, chapterId: chapterId);
  }

  Future<List<MissionModel>> loadChapterMissions(String chapterId) {
    return _repository.loadChapterMissions(chapterId);
  }

  Future<List<MissionState>> loadMissionStates(String chapterId) async {
    final missions = await _repository.loadChapterMissions(chapterId);
    final states = <MissionState>[];

    for (final mission in missions) {
      final progress = await _repository.loadProgress(mission.id);
      final completed = progress['completed'] as bool? ?? false;
      final unlocked = progress['unlocked'] as bool? ?? mission.id == 'mission_001';
      states.add(
        MissionState(
          mission: mission,
          isUnlocked: unlocked,
          isCompleted: completed,
          progress: _progressService.missionProgressFromState(mission, progress),
        ),
      );
    }

    return states;
  }

  Future<MissionModel?> currentMission(String chapterId) async {
    final states = await loadMissionStates(chapterId);
    for (final state in states) {
      if (state.isUnlocked && !state.isCompleted) {
        return state.mission;
      }
    }
    return states.isEmpty ? null : states.last.mission;
  }

  Future<void> completeMission(MissionModel mission) async {
    await _repository.saveProgress(
      mission.id,
      completed: true,
      xpEarned: mission.xpReward,
      courageEarned: mission.courageReward,
    );

    await _repository.setMissionUnlocked(mission.id, true);

    final nextId = _nextMissionId(mission.id);
    if (nextId != null) {
      await _repository.setMissionUnlocked(nextId, true);
    }
  }

  String? _nextMissionId(String missionId) {
    final match = RegExp(r'^mission_(\d{3})$').firstMatch(missionId);
    if (match == null) return null;

    final current = int.tryParse(match.group(1)!);
    if (current == null) return null;

    final next = current + 1;
    return 'mission_${next.toString().padLeft(3, '0')}';
  }
}
