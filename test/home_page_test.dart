import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portuguese_survivor/features/home/presentation/home_page.dart';

void main() {
  testWidgets('HomePage shows the main welcome and lesson content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('Merhaba, Sidelya'), findsOneWidget);
    expect(find.text('Bugün de Portekizce öğrenmeye hazır mısın?'), findsOneWidget);
    expect(find.text('Bugünkü Dersler'), findsOneWidget);
    expect(find.text('Selamlaşma'), findsOneWidget);
    expect(find.text('Rakamlar'), findsOneWidget);
    expect(find.text('Renkler'), findsOneWidget);
  });
}
