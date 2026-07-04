class SceneModel {
  const SceneModel({
    required this.type,
    required this.title,
    required this.body,
    required this.prompt,
    required this.answer,
    required this.options,
    required this.reward,
    required this.tip,
    required this.imagePath,
  });

  final String type;
  final String title;
  final String body;
  final String prompt;
  final String answer;
  final List<String> options;
  final int reward;
  final String tip;
  final String imagePath;

  factory SceneModel.fromJson(Map<String, dynamic> json) {
    return SceneModel(
      type: json['type'] as String? ?? 'intro',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      reward: json['reward'] as int? ?? 0,
      tip: json['tip'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
    );
  }
}
