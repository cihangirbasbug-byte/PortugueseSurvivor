import 'package:flutter_test/flutter_test.dart';
import 'package:portuguese_survivor/features/lesson/data/repositories/mission_validation_helper.dart';

void main() {
  group('MissionValidationHelper', () {
    test('accepts a valid mission payload', () {
      final valid = <String, dynamic>{
        'id': 'mission_001',
        'title': 'Test Mission',
        'description': 'desc',
        'duration': '3 minutes',
        'learning_goal': 'goal',
        'emotion_goal': 'emotion',
        'real_life_goal': 'real life',
        'badge': 'Starter',
        'xp': 20,
        'courage': 10,
        'scenes': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'intro',
            'title': 'Intro',
            'body': 'Body',
            'prompt': 'Start',
            'answer': '',
            'options': <String>[],
            'reward': 0,
            'tip': '',
            'imagePath': '',
            'character': 'Pico',
            'illustration': '',
          },
          <String, dynamic>{
            'type': 'quiz',
            'title': 'Quiz',
            'body': '',
            'prompt': 'Prompt',
            'answer': 'Olá!',
            'options': <String>['Olá!', 'Tchau!'],
            'reward': 20,
            'tip': '',
            'imagePath': '',
            'character': '',
            'illustration': '',
          },
        ],
      };

      expect(
        () => MissionValidationHelper.validateMissionJson(valid, sourcePath: 'test/valid'),
        returnsNormally,
      );
    });

    test('throws developer-friendly error for invalid payload', () {
      final invalid = <String, dynamic>{
        'id': '',
        'title': '',
        'description': '',
        'duration': '',
        'learning_goal': '',
        'emotion_goal': '',
        'real_life_goal': '',
        'badge': '',
        'xp': -1,
        'courage': -1,
        'scenes': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'quiz',
            'title': '',
            'body': '',
            'prompt': '',
            'answer': 'Olá!',
            'options': <String>['Tchau!'],
            'reward': 'bad',
            'tip': '',
            'imagePath': '',
            'character': '',
            'illustration': '',
          },
        ],
      };

      expect(
        () => MissionValidationHelper.validateMissionJson(invalid, sourcePath: 'test/invalid'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Invalid mission JSON in test/invalid'),
          ),
        ),
      );
    });
  });
}
