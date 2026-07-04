import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portuguese_survivor/features/lesson/presentation/lesson_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LessonPage renders mission content from data', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LessonPage()));
    await tester.pumpAndSettle();

    expect(find.text('Selamlaşma Macerası'), findsOneWidget);
    expect(find.text('Olá'), findsOneWidget);
    expect(find.text('Merhaba'), findsOneWidget);
  });
}
