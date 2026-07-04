import 'scene_model.dart';

class MissionModel {
  const MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.courageReward,
    required this.scenes,
  });

  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int courageReward;
  final List<SceneModel> scenes;

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      xpReward: json['xpReward'] as int? ?? 0,
      courageReward: json['courageReward'] as int? ?? 0,
      scenes: (json['scenes'] as List<dynamic>?)
              ?.map((e) => SceneModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SceneModel>[],
    );
  }
}
