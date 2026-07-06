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

  List<MissionModel> _missions = const <MissionModel>[];
  Map<String, Map<String, dynamic>> _progressByMission = const <String, Map<String, dynamic>>{};
  bool _isLoadingMission = true;

  static const int _baseXp = 1250;

  @override
  void initState() {
    super.initState();
    _loadHomeMissionState();
  }

  Future<void> _loadHomeMissionState() async {
    final missions = await _missionRepository.loadChapter01Missions();
    final progressEntries = await Future.wait(
      missions.map((mission) async {
        final progress = await _missionRepository.loadProgress(mission.id);
        return MapEntry(mission.id, progress);
      }),
    );

    if (!mounted) return;
    setState(() {
      _missions = missions;
      _progressByMission = {
        for (final entry in progressEntries) entry.key: entry.value,
      };
      _isLoadingMission = false;
    });
  }

  Future<void> _openMission(String missionId) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonPage(missionId: missionId),
      ),
    );

    if (result == true) {
      await _loadHomeMissionState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedMissionCount = _missions
        .where((mission) => (_progressByMission[mission.id]?['completed'] as bool?) ?? false)
        .length;
    final totalEarnedXp = _missions.fold<int>(
      0,
      (sum, mission) => sum + ((_progressByMission[mission.id]?['xpEarned'] as int?) ?? 0),
    );
    final currentMission = _resolveCurrentMission();
    final currentMissionProgress = currentMission == null
        ? 0.0
        : _missionProgress(currentMission);
    final currentMissionXp = currentMission?.xpReward ?? 20;

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
                            Expanded(child: XpCard(xp: _baseXp + totalEarnedXp)),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          const HeartCard(hearts: 5),
                          const SizedBox(height: 12),
                          const StreakCard(days: 12),
                          const SizedBox(height: 12),
                          XpCard(xp: _baseXp + totalEarnedXp),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  DailyGoalCard(
                    progress: _missions.isEmpty ? 0 : completedMissionCount / _missions.length,
                    completed: completedMissionCount,
                    target: _missions.isEmpty ? 10 : _missions.length,
                  ),
                  const SizedBox(height: 20),
                  ContinueLessonCard(
                    title: 'Devam Et',
                    subtitle: currentMission?.learningGoal ?? 'Görev yükleniyor...',
                    progress: currentMissionProgress,
                    xp: currentMissionXp,
                    missionId: currentMission?.id ?? 'mission_001',
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
                  ..._buildMissionCards(currentMission?.id),
                  if (_isLoadingMission) const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMissionCards(String? currentMissionId) {
    if (_missions.isEmpty) {
      return const <Widget>[];
    }

    final widgets = <Widget>[];
    for (var i = 0; i < _missions.length; i++) {
      final mission = _missions[i];
      final progress = _progressByMission[mission.id] ?? const <String, dynamic>{};
      final completed = progress['completed'] as bool? ?? false;
      final unlocked = progress['unlocked'] as bool? ?? mission.id == 'mission_001';
      final isCurrent = mission.id == currentMissionId;

      widgets.add(
        LessonCard(
          title: '${i + 1}. ${mission.title}',
          subtitle: mission.learningGoal,
          xp: mission.xpReward,
          difficulty: 'Bölüm 1',
          progress: _missionProgress(mission),
          icon: Icons.menu_book_rounded,
          accentColor: AppColors.primary,
          isLocked: !unlocked,
          isCompleted: completed,
          isCurrent: isCurrent,
          onTap: unlocked ? () => _openMission(mission.id) : null,
        ),
      );

      if (i != _missions.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }

    return widgets;
  }

  MissionModel? _resolveCurrentMission() {
    if (_missions.isEmpty) return null;

    for (final mission in _missions) {
      final progress = _progressByMission[mission.id] ?? const <String, dynamic>{};
      final unlocked = progress['unlocked'] as bool? ?? mission.id == 'mission_001';
      final completed = progress['completed'] as bool? ?? false;
      if (unlocked && !completed) {
        return mission;
      }
    }

    return _missions.last;
  }

  double _missionProgress(MissionModel mission) {
    final progress = _progressByMission[mission.id] ?? const <String, dynamic>{};
    final completed = progress['completed'] as bool? ?? false;
    if (completed) return 1.0;

    final xpEarned = progress['xpEarned'] as int? ?? 0;
    if (mission.xpReward <= 0) return 0.0;
    return (xpEarned / mission.xpReward).clamp(0.0, 1.0);
  }
}