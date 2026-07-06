import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portuguese_survivor/features/home/presentation/home_page.dart';

void main() {
  testWidgets('HomePage shows the main welcome and lesson content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    expect(find.text('Merhaba Sidelya 👋'), findsOneWidget);
    expect(find.text('Bugünkü görevin seni bekliyor!'), findsOneWidget);
    expect(find.text('Bugünkü Görevler'), findsOneWidget);
    expect(find.text('Devam Et'), findsOneWidget);
    expect(find.text('Devam'), findsOneWidget);
  });
}
