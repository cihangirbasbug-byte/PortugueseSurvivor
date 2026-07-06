import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portuguese_survivor/features/lesson/presentation/lesson_page.dart';
import 'package:portuguese_survivor/features/lesson/presentation/widgets/scene_action_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LessonPage shows the first school day intro content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LessonPage(missionId: 'mission_001')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('İlk Okul Günüm'), findsOneWidget);
    expect(find.byType(SceneActionButton), findsOneWidget);
    expect(find.textContaining('Kuş sesleri'), findsOneWidget);
  });
}
