import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portuguese_survivor/core/animation/pico_animation_controller.dart';
import 'package:portuguese_survivor/features/home/presentation/home_page.dart';
import 'package:portuguese_survivor/features/lesson/data/models/scene_model.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/celebration_scene.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/dialogue_scene.dart';
import 'package:portuguese_survivor/features/lesson/presentation/scenes/intro_scene.dart';
import 'package:portuguese_survivor/features/onboarding/presentation/onboarding_page.dart';

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

  testWidgets('home screen is visible', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await _pumpFor(tester, const Duration(seconds: 3));

    expect(find.text('Adventure Card'), findsOneWidget);
  });

  testWidgets('lesson intro is visible', (tester) async {
    final controller = PicoAnimationController();
    addTearDown(controller.dispose);

    const scene = SceneModel(
      type: 'intro',
      title: 'Pico ao teu lado',
      body: 'Hoje vais começar com confiança.',
      prompt: 'Continuar',
      answer: '',
      options: <String>[],
      reward: 0,
      tip: '',
      imagePath: '',
      character: 'Pico',
      illustration: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IntroScene(
            scene: scene,
            showBubble: true,
            picoAnimationController: controller,
            onNext: () {},
          ),
        ),
      ),
    );
    await _pumpFor(tester, const Duration(milliseconds: 900));

    expect(find.textContaining('Hoje vais começar com confiança.'), findsOneWidget);
  });

  testWidgets('dialogue screen is visible', (tester) async {
    const scene = SceneModel(
      type: 'dialogue',
      title: 'Diálogo',
      body: 'A professora cumprimenta-te.',
      prompt: 'Responder',
      answer: 'Olá!',
      options: <String>[],
      reward: 0,
      tip: '',
      imagePath: '',
      character: 'Teacher Sofia',
      illustration: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DialogueScene(
            scene: scene,
            onNext: () {},
          ),
        ),
      ),
    );
    await _pumpFor(tester, const Duration(milliseconds: 900));

    expect(find.text('Diálogo'), findsOneWidget);
  });

  testWidgets('celebration screen is visible', (tester) async {
    final controller = PicoAnimationController();
    addTearDown(controller.dispose);

    const scene = SceneModel(
      type: 'celebration',
      title: 'Missão Concluída',
      body: 'Excelente trabalho!',
      prompt: '',
      answer: '',
      options: <String>[],
      reward: 20,
      tip: '',
      imagePath: '',
      character: 'Pico',
      illustration: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CelebrationScene(
            scene: scene,
            badge: 'Primeiro Passo',
            xp: 20,
            courage: 10,
            picoAnimationController: controller,
            onNext: () {},
          ),
        ),
      ),
    );
    await _pumpFor(tester, const Duration(milliseconds: 1000));

    expect(find.text('Missão Concluída'), findsOneWidget);
  });

  testWidgets('teacher sofia onboarding flow reaches mission start', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingPage(missionId: 'mission_001', entryFromHome: true),
      ),
    );

    await _pumpFor(tester, const Duration(milliseconds: 700));
    expect(find.textContaining('Bem-vindo à Escola da Amizade'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await _pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.text('Olá!'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await _pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.text('Como te chamas?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Inês');
    await _pumpFor(tester, const Duration(milliseconds: 300));
    await tester.tap(find.text('Confirmar nome'));
    await _pumpFor(tester, const Duration(milliseconds: 500));

    expect(find.textContaining('Prazer em conhecer-te, Inês!'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await _pumpFor(tester, const Duration(milliseconds: 500));

    expect(find.textContaining('Missão 001'), findsOneWidget);
    expect(find.text('+20 XP'), findsOneWidget);
    expect(find.text('+10 Courage'), findsOneWidget);

    expect(find.text('Começar missão'), findsOneWidget);
  });
}
