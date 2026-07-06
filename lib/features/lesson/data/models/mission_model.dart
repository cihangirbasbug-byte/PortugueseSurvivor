import 'scene_model.dart';

class MissionModel {
  const MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.xpReward,
    required this.courageReward,
    required this.badge,
    required this.emotionGoal,
    required this.learningGoal,
    required this.realLifeGoal,
    required this.scenes,
  });

  final String id;
  final String title;
  final String description;
  final String duration;
  final int xpReward;
  final int courageReward;
  final String badge;
  final String emotionGoal;
  final String learningGoal;
  final String realLifeGoal;
  final List<SceneModel> scenes;

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      xpReward: (json['xpReward'] as int?) ?? (json['xp'] as int?) ?? 0,
      courageReward: (json['courageReward'] as int?) ?? (json['courage'] as int?) ?? 0,
      badge: json['badge'] as String? ?? '',
      emotionGoal: (json['emotion_goal'] as String?) ?? (json['emotionGoal'] as String?) ?? '',
      learningGoal: (json['learning_goal'] as String?) ?? (json['learningGoal'] as String?) ?? '',
      realLifeGoal: (json['real_life_goal'] as String?) ?? (json['realLifeGoal'] as String?) ?? '',
      scenes: (json['scenes'] as List<dynamic>?)
              ?.map((e) => SceneModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SceneModel>[],
    );
  }
}
