class MissionValidationHelper {
  static const Set<String> _supportedSceneTypes = <String>{
    'intro',
    'story',
    'dialogue',
    'word',
    'practice',
    'quiz',
    'celebration',
    'real_life',
    'real_life_tip',
    'realLifeTip',
    'complete',
    'mission_complete',
  };

  static void validateMissionJson(
    Map<String, dynamic> json, {
    String? sourcePath,
  }) {
    final errors = <String>[];

    void expectNonEmptyString(String field, dynamic value) {
      if (value is! String || value.trim().isEmpty) {
        errors.add('$field must be a non-empty string.');
      }
    }

    void expectNonNegativeInt(String field, dynamic value) {
      if (value is! int || value < 0) {
        errors.add('$field must be a non-negative int.');
      }
    }

    final metadata = json['metadata'];
    final goals = json['goals'];
    final rewards = json['rewards'];

    final id = (json['id'] ?? (metadata is Map<String, dynamic> ? metadata['id'] : null));
    final title = (json['title'] ?? (metadata is Map<String, dynamic> ? metadata['title'] : null));
    final description =
        (json['description'] ?? (metadata is Map<String, dynamic> ? metadata['description'] : null));
    final duration =
        (json['duration'] ?? (metadata is Map<String, dynamic> ? metadata['duration'] : null));

    final learningGoal =
        (json['learning_goal'] ?? (goals is Map<String, dynamic> ? goals['learning_goal'] : null));
    final emotionGoal =
        (json['emotion_goal'] ?? (goals is Map<String, dynamic> ? goals['emotion_goal'] : null));
    final realLifeGoal =
        (json['real_life_goal'] ?? (goals is Map<String, dynamic> ? goals['real_life_goal'] : null));

    final badge = (json['badge'] ?? (rewards is Map<String, dynamic> ? rewards['badge'] : null));
    final xp = (json['xpReward'] ?? json['xp'] ?? (rewards is Map<String, dynamic> ? rewards['xp'] : null));
    final courage =
        (json['courageReward'] ?? json['courage'] ?? (rewards is Map<String, dynamic> ? rewards['courage'] : null));

    expectNonEmptyString('id', id);
    expectNonEmptyString('title', title);
    expectNonEmptyString('description', description);

    // Keep legacy missions valid while supporting stricter factory schemas.
    if (duration != null) {
      expectNonEmptyString('duration', duration);
    }
    if (learningGoal != null) {
      expectNonEmptyString('learning_goal', learningGoal);
    }
    if (emotionGoal != null) {
      expectNonEmptyString('emotion_goal', emotionGoal);
    }
    if (realLifeGoal != null) {
      expectNonEmptyString('real_life_goal', realLifeGoal);
    }
    if (badge != null) {
      expectNonEmptyString('badge', badge);
    }
    expectNonNegativeInt('xp/xpReward', xp);
    expectNonNegativeInt('courage/courageReward', courage);

    final scenes = json['scenes'];
    if (scenes is! List || scenes.isEmpty) {
      errors.add('scenes must be a non-empty array.');
    } else {
      for (var i = 0; i < scenes.length; i++) {
        final scene = scenes[i];
        if (scene is! Map<String, dynamic>) {
          errors.add('scenes[$i] must be an object.');
          continue;
        }

        final type = scene['type'];
        if (type is! String || !_supportedSceneTypes.contains(type)) {
          errors.add(
            'scenes[$i].type must be one of: ${_supportedSceneTypes.join(', ')}.',
          );
        }

        final options = scene['options'];
        if (options != null && options is! List) {
          errors.add('scenes[$i].options must be an array when provided.');
        } else if (options is List && options.any((item) => item is! String)) {
          errors.add('scenes[$i].options must contain only strings.');
        }

        final reward = scene['reward'];
        if (reward != null && reward is! int) {
          errors.add('scenes[$i].reward must be an int when provided.');
        }

        for (final field in const <String>['title', 'body', 'prompt', 'answer', 'tip', 'imagePath', 'character', 'illustration']) {
          if (!scene.containsKey(field)) {
            continue;
          }
          final value = scene[field];
          if (value is! String) {
            errors.add('scenes[$i].$field must be a string.');
          }
        }

        if (type == 'quiz') {
          if (options is List && options.length < 2) {
            errors.add('scenes[$i] quiz must have at least 2 options.');
          }
          final answer = scene['answer'];
          if (answer is! String || answer.trim().isEmpty) {
            errors.add('scenes[$i] quiz answer must be non-empty.');
          }
          if (answer is String && options is List && options.isNotEmpty && !options.contains(answer)) {
            errors.add('scenes[$i] quiz answer must match one of options.');
          }
        }

        if (type == 'dialogue') {
          final answer = scene['answer'];
          if (answer is! String || answer.trim().isEmpty) {
            errors.add('scenes[$i] $type answer must be non-empty.');
          }
        }

        if (type == 'practice') {
          final answer = scene['answer'];
          if (answer != null && answer is! String) {
            errors.add('scenes[$i] practice answer must be a string when provided.');
          }
        }

        if (type == 'real_life' || type == 'real_life_tip' || type == 'realLifeTip') {
          final body = scene['body'];
          if (body is! String || body.trim().isEmpty) {
            errors.add('scenes[$i] $type body must be non-empty.');
          }
        }

        if (type == 'celebration' || type == 'mission_complete' || type == 'complete') {
          final body = scene['body'];
          final sceneTitle = scene['title'];
          if (sceneTitle is! String || sceneTitle.trim().isEmpty) {
            errors.add('scenes[$i] $type title must be non-empty.');
          }
          if (type == 'celebration' && (body is! String || body.trim().isEmpty)) {
            errors.add('scenes[$i] $type body must be non-empty.');
          }
        }
      }
    }

    final audio = json['audio'];
    if (audio != null && audio is! Map<String, dynamic>) {
      errors.add('audio must be an object when provided.');
    }

    final animations = json['animations'];
    if (animations != null && animations is! Map<String, dynamic>) {
      errors.add('animations must be an object when provided.');
    }

    final realLife = json['real_life'];
    if (realLife != null && realLife is! Map<String, dynamic>) {
      errors.add('real_life must be an object when provided.');
    }

    final unlockRule = json['unlock_rule'];
    if (unlockRule != null && unlockRule is! Map<String, dynamic>) {
      errors.add('unlock_rule must be an object when provided.');
    }

    if (errors.isNotEmpty) {
      final source = sourcePath ?? (id is String ? id : 'unknown_mission');
      final details = errors.map((e) => '- $e').join('\n');
      throw FormatException('Invalid mission JSON in $source\n$details');
    }
  }
}
