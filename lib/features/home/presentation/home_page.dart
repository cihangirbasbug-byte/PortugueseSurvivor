import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'widgets/continue_lesson_card.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/heart_card.dart';
import 'widgets/lesson_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/xp_card.dart';

const String testVersion = 'HOME V2';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Portekizli Hayatta Kal'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba, Sidelya',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bugün de Portekizce öğrenmeye hazır mısın?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 700) {
                    return const Row(
                      children: [
                        Expanded(child: HeartCard(hearts: 5)),
                        SizedBox(width: 12),
                        Expanded(child: StreakCard(days: 12)),
                        SizedBox(width: 12),
                        Expanded(child: XpCard(xp: 1250)),
                      ],
                    );
                  }

                  return const Column(
                    children: [
                      HeartCard(hearts: 5),
                      SizedBox(height: 12),
                      StreakCard(days: 12),
                      SizedBox(height: 12),
                      XpCard(xp: 1250),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const DailyGoalCard(
                progress: 0.72,
                completed: 18,
                target: 25,
              ),
              const SizedBox(height: 16),
              const ContinueLessonCard(
                title: 'Devam Et',
                subtitle: 'Merhaba demeyi öğren',
                progress: 0.68,
                xp: 20,
              ),
              const SizedBox(height: 24),
              Text(
                'Bugünkü Dersler',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const LessonCard(
                title: 'Selamlaşma',
                subtitle: 'Merhaba demeyi öğren',
                xp: 20,
                difficulty: 'Başlangıç',
                progress: 0.85,
                icon: Icons.waving_hand_rounded,
                accentColor: Color(0xFF0E8A4B),
              ),
              const SizedBox(height: 12),
              const LessonCard(
                title: 'Rakamlar',
                subtitle: '1’den 20’ye kadar say',
                xp: 25,
                difficulty: 'Kolay',
                progress: 0.62,
                icon: Icons.numbers_rounded,
                accentColor: Color(0xFFF5C542),
              ),
              const SizedBox(height: 12),
              const LessonCard(
                title: 'Renkler',
                subtitle: 'Temel renk kelimelerini öğren',
                xp: 30,
                difficulty: 'Pratik',
                progress: 0.48,
                icon: Icons.palette_rounded,
                accentColor: Color(0xFF7C4DFF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}