import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portuguese_survivor/features/lesson/presentation/lesson_page.dart';

void main() {
  testWidgets('LessonPage shows the first word card content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LessonPage()));

    expect(find.text('Öğrenmeye Başla'), findsOneWidget);
    expect(find.text('Olá'), findsOneWidget);
    expect(find.text('Merhaba'), findsOneWidget);
    expect(find.text('Devam'), findsOneWidget);
  });
}
