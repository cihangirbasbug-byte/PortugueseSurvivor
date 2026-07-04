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
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 4),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merhaba Sidelya 👋',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bugünkü görevin seni bekliyor!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Center(
                            child: Text('🦜', style: TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Pico\n',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                TextSpan(
                                  text: '"Bugün sadece 3 dakikalık bir görevimiz var."',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                  const SizedBox(height: 20),
                  const ContinueLessonCard(
                    title: 'Devam Et',
                    subtitle: 'Merhaba demeyi öğren',
                    progress: 0.68,
                    xp: 20,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Bugünkü Görevler',
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
        ),
      ),
    );
  }
}