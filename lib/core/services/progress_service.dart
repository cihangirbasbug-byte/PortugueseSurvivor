import '../../features/lesson/data/models/mission_model.dart';
import '../../features/lesson/data/repositories/mission_repository.dart';

class ProgressSummary {
  const ProgressSummary({
    required this.totalXp,
    required this.totalCourage,
    required this.completionPercent,
    required this.badges,
  });

  final int totalXp;
  final int totalCourage;
  final double completionPercent;
  final List<String> badges;
}

class ProgressService {
  ProgressService({MissionRepository? repository})
      : _repository = repository ?? MissionRepository();

  final MissionRepository _repository;

  Future<ProgressSummary> summarizeChapter(String chapterId) async {
    final missions = await _repository.loadChapterMissions(chapterId);

    var totalXp = 0;
    var totalCourage = 0;
    var completedCount = 0;
    final badges = <String>[];

    for (final mission in missions) {
      final progress = await _repository.loadProgress(mission.id);
      final completed = progress['completed'] as bool? ?? false;

      totalXp += (progress['xpEarned'] as int?) ?? 0;
      totalCourage += (progress['courageEarned'] as int?) ?? 0;

      if (completed) {
        completedCount += 1;
        if (mission.badge.isNotEmpty) {
          badges.add(mission.badge);
        }
      }
    }

    final completionPercent = missions.isEmpty ? 0.0 : completedCount / missions.length;

    return ProgressSummary(
      totalXp: totalXp,
      totalCourage: totalCourage,
      completionPercent: completionPercent,
      badges: badges,
    );
  }

  double missionProgressFromState(MissionModel mission, Map<String, dynamic> progressState) {
    final completed = progressState['completed'] as bool? ?? false;
    if (completed) {
      return 1.0;
    }

    final xpEarned = progressState['xpEarned'] as int? ?? 0;
    if (mission.xpReward <= 0) {
      return 0.0;
    }

    return (xpEarned / mission.xpReward).clamp(0.0, 1.0);
  }
}
