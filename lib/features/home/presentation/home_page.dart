import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../lesson/data/models/mission_model.dart';
import '../../lesson/data/repositories/mission_repository.dart';
import '../../lesson/presentation/lesson_page.dart';
import 'widgets/continue_lesson_card.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/heart_card.dart';
import 'widgets/lesson_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/xp_card.dart';

const String testVersion = 'HOME V2';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MissionRepository _missionRepository = MissionRepository();

  MissionModel? _firstMission;
  bool _missionCompleted = false;
  int _missionXpEarned = 0;
  bool _isLoadingMission = true;

  static const int _baseXp = 1250;

  @override
  void initState() {
    super.initState();
    _loadHomeMissionState();
  }

  Future<void> _loadHomeMissionState() async {
    final mission = await _missionRepository.loadMission('mission_001');
    final progress = await _missionRepository.loadProgress(mission.id);

    if (!mounted) return;
    setState(() {
      _firstMission = mission;
      _missionCompleted = progress['completed'] as bool? ?? false;
      _missionXpEarned = progress['xpEarned'] as int? ?? 0;
      _isLoadingMission = false;
    });
  }

  Future<void> _openMission001() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LessonPage(missionId: 'mission_001'),
      ),
    );

    if (result == true) {
      await _loadHomeMissionState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mission = _firstMission;
    final missionXp = mission?.xpReward ?? 20;
    final missionProgress = mission == null
        ? 0.0
        : (_missionXpEarned / mission.xpReward).clamp(0.0, 1.0);
    final completedMissionCount = _missionCompleted ? 1 : 0;

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
                        return Row(
                          children: [
                            const Expanded(child: HeartCard(hearts: 5)),
                            const SizedBox(width: 12),
                            const Expanded(child: StreakCard(days: 12)),
                            const SizedBox(width: 12),
                            Expanded(child: XpCard(xp: _baseXp + _missionXpEarned)),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          const HeartCard(hearts: 5),
                          const SizedBox(height: 12),
                          const StreakCard(days: 12),
                          const SizedBox(height: 12),
                          XpCard(xp: _baseXp + _missionXpEarned),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  DailyGoalCard(
                    progress: completedMissionCount / 1,
                    completed: completedMissionCount,
                    target: 1,
                  ),
                  const SizedBox(height: 20),
                  ContinueLessonCard(
                    title: 'Devam Et',
                    subtitle: mission?.learningGoal ?? 'Görev yükleniyor...',
                    progress: missionProgress,
                    xp: missionXp,
                    missionId: mission?.id ?? 'mission_001',
                    onMissionCompleted: _loadHomeMissionState,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Bugünkü Görevler',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LessonCard(
                    title: 'Selamlaşma',
                    subtitle: mission?.learningGoal ?? 'Görev yükleniyor...',
                    xp: missionXp,
                    difficulty: 'Başlangıç',
                    progress: missionProgress,
                    icon: Icons.waving_hand_rounded,
                    accentColor: const Color(0xFF0E8A4B),
                    onTap: _openMission001,
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
                  if (_isLoadingMission) const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}