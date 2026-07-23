import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portuguese_survivor/app/app.dart';
import 'package:portuguese_survivor/app/router/app_router.dart';
import 'package:portuguese_survivor/features/lesson/presentation/lesson_page.dart';

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

  testWidgets('first launch opens onboarding after splash', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const PortugueseSurvivorApp());
    await _pumpFor(tester, const Duration(seconds: 2, milliseconds: 50));
    await _pumpFor(tester, const Duration(milliseconds: 700));

    expect(
      find.text(
        'Olá! Eu sou a Teacher Sofia. Hoje vamos aprender português juntos.',
      ),
      findsOneWidget,
    );
    expect(find.text('Escola da Amizade'), findsNothing);
  });

  testWidgets('returning launch skips onboarding and opens home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding_mission_001_done': true,
    });

    await tester.pumpWidget(const PortugueseSurvivorApp());
    await _pumpFor(tester, const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Adventure Card'), findsOneWidget);
    expect(find.text('Chapter Map'), findsOneWidget);
  });

  testWidgets('settings navigation opens settings and back returns home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding_mission_001_done': true,
    });

    final router = AppRouter.createRouter(initialLocation: AppRouter.homePath);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await _pumpFor(tester, const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, AppRouter.settingsPath);
    expect(find.text('Ayarlar'), findsOneWidget);
    expect(
      find.text('Uygulama ayarlari yakinda buraya gelecek.'),
      findsOneWidget,
    );

    expect(router.canPop(), isTrue);
    router.pop();
    await tester.pump(const Duration(milliseconds: 500));

    expect(router.state.uri.path, AppRouter.homePath);
    expect(find.text('Adventure Card'), findsOneWidget);
  });

  testWidgets('mission route uses mission id parameter', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding_mission_001_done': true,
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: AppRouter.createRouter(
          initialLocation: '/mission/mission_001',
        ),
      ),
    );
    await tester.pump();

    final lessonPage = tester.widget<LessonPage>(find.byType(LessonPage));
    expect(lessonPage.missionId, 'mission_001');
  });
}
