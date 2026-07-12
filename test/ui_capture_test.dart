import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portuguese_survivor/features/home/presentation/home_page.dart';
import 'package:portuguese_survivor/features/lesson/presentation/lesson_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpFor(
  WidgetTester tester,
  Duration duration, {
  Duration step = const Duration(milliseconds: 16),
}) async {
  var elapsed = Duration.zero;
  while (elapsed < duration) {
    await tester.pump(step);
    elapsed += step;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture home screen ui', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await _pumpFor(tester, const Duration(milliseconds: 1200));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../docs/home_screen_p01b.png'),
    );
  });

  testWidgets('capture lesson screen ui', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: LessonPage(missionId: 'mission_001')));

    // Allow async mission loading to complete without waiting on endless animations.
    await _pumpFor(tester, const Duration(seconds: 3));

    await _pumpFor(tester, const Duration(milliseconds: 600));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../docs/lesson_screen_p01b.png'),
    );
  });
}
