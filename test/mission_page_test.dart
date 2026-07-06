import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portuguese_survivor/features/lesson/presentation/lesson_page.dart';
import 'package:portuguese_survivor/features/lesson/presentation/widgets/scene_action_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LessonPage renders mission content from data', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LessonPage(missionId: 'mission_001')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('İlk Okul Günüm'), findsOneWidget);
    expect(find.byType(SceneActionButton), findsOneWidget);
    expect(find.textContaining('okul günün'), findsOneWidget);
  });
}
