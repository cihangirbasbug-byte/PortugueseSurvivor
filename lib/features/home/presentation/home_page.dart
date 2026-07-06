import 'package:flutter/material.dart';

import '../../../core/services/mission_manager.dart';
import '../../../core/services/progress_service.dart';
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
  final MissionRepository _repository = MissionRepository();
  late final MissionManager _missionManager = MissionManager(repository: _repository);
  late final ProgressService _progressService = ProgressService(repository: _repository);

  List<MissionState> _missionStates = const <MissionState>[];
  ProgressSummary _summary =
      const ProgressSummary(totalXp: 0, totalCourage: 0, completionPercent: 0, badges: <String>[]);
  MissionModel? _currentMission;
  bool _isLoadingMission = true;
  static const String _chapterId = 'chapter_01';

  static const int _baseXp = 1250;

  @override
  void initState() {
    super.initState();
    _loadHomeMissionState();
  }

  Future<void> _loadHomeMissionState() async {
    final states = await _missionManager.loadMissionStates(_chapterId);
    final summary = await _progressService.summarizeChapter(_chapterId);
    final currentMission = await _missionManager.currentMission(_chapterId);

    if (!mounted) return;
    setState(() {
      _missionStates = states;
      _summary = summary;
      _currentMission = currentMission;
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
    final completedMissionCount =
      _missionStates.where((state) => state.isCompleted).length;
    final totalEarnedXp = _summary.totalXp;
    final currentMission = _currentMission;
    MissionState? currentMissionState;
    for (final state in _missionStates) {
      if (currentMission != null && state.mission.id == currentMission.id) {
        currentMissionState = state;
        break;
      }
    }
    final currentMissionProgress = currentMissionState?.progress ?? 0.0;
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
                    progress: _summary.completionPercent,
                    completed: completedMissionCount,
                    target: _missionStates.isEmpty ? 0 : _missionStates.length,
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
    if (_missionStates.isEmpty) {
      return const <Widget>[];
    }

    final widgets = <Widget>[];
    for (var i = 0; i < _missionStates.length; i++) {
      final state = _missionStates[i];
      final mission = state.mission;
      final completed = state.isCompleted;
      final unlocked = state.isUnlocked;
      final isCurrent = mission.id == currentMissionId;

      widgets.add(
        LessonCard(
          title: '${i + 1}. ${mission.title}',
          subtitle: mission.learningGoal,
          xp: mission.xpReward,
          difficulty: 'Bölüm 1',
          progress: state.progress,
          icon: Icons.menu_book_rounded,
          accentColor: AppColors.primary,
          isLocked: !unlocked,
          isCompleted: completed,
          isCurrent: isCurrent,
          onTap: unlocked ? () => _openMission(mission.id) : null,
        ),
      );

      if (i != _missionStates.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }

    return widgets;
  }
}