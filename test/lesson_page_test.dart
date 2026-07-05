import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portuguese_survivor/features/lesson/presentation/lesson_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LessonPage shows the first school day intro content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LessonPage()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Merhaba!'), findsOneWidget);
    expect(find.text('Başlayalım'), findsOneWidget);
  });
}
