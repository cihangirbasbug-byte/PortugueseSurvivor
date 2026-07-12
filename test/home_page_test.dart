import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portuguese_survivor/features/home/presentation/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('HomePage shows the main welcome and lesson content', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.textContaining('Bom dia!'), findsOneWidget);
    expect(find.text('Adventure Card'), findsOneWidget);
    expect(find.text('Daily Goal'), findsOneWidget);
    expect(find.text('Chapter Map'), findsOneWidget);
    expect(find.text('Basla'), findsOneWidget);
  });
}
