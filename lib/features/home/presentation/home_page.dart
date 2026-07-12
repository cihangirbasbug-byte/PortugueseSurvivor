import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/mission_manager.dart';
import '../../../core/services/progress_service.dart';
import '../../../shared/widgets/pico_avatar.dart';
import '../../lesson/data/models/mission_model.dart';
import '../../lesson/data/repositories/mission_repository.dart';
import '../../lesson/presentation/lesson_page.dart';

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

  static const String _chapterId = 'chapter_01';

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
    final completedMissionCount = _missionStates.where((state) => state.isCompleted).length;

    MissionState? nextPlayableState;
    for (final state in _missionStates) {
      if (state.isUnlocked && !state.isCompleted) {
        nextPlayableState = state;
        break;
      }
    }

    final missionForAdventure = nextPlayableState?.mission ?? _currentMission;
    final missionProgress = nextPlayableState?.progress ?? 1.0;
    final missionRewardXp = missionForAdventure?.xpReward ?? 20;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 4),
              width: 44,
              height: 44,
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
            constraints: const BoxConstraints(maxWidth: 980),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HomeHeroCard(),
                  const SizedBox(height: 18),
                  const _SectionTitle(
                    title: 'Bugunun Macerasi',
                    subtitle: 'Siradaki oynanabilir gorev burada.',
                  ),
                  const SizedBox(height: 12),
                  _AdventureCard(
                    title: missionForAdventure?.title ?? 'Bolum tamamlandi',
                    subtitle: missionForAdventure != null
                        ? 'Siradaki hedef: ${missionForAdventure.learningGoal}'
                        : 'Yeni maceralar icin yakinda tekrar gel.',
                    xp: missionRewardXp,
                    progress: missionProgress,
                    onPressed: missionForAdventure == null
                        ? null
                        : () => _openMission(missionForAdventure.id),
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 760) {
                        return Row(
                          children: [
                            Expanded(
                              child: _AnimatedStatCard(
                                icon: Icons.bolt_rounded,
                                title: 'Toplam XP',
                                value: _summary.totalXp,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AnimatedStatCard(
                                icon: Icons.favorite_rounded,
                                title: 'Toplam Cesaret',
                                value: _summary.totalCourage,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _AnimatedStatCard(
                            icon: Icons.bolt_rounded,
                            title: 'Toplam XP',
                            value: _summary.totalXp,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          _AnimatedStatCard(
                            icon: Icons.favorite_rounded,
                            title: 'Toplam Cesaret',
                            value: _summary.totalCourage,
                            color: Colors.orange.shade700,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _DailyGoalRingCard(
                    progress: _summary.completionPercent,
                    completed: completedMissionCount,
                    target: _missionStates.length,
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle(
                    title: 'Gorev Yolu',
                    subtitle: 'Tamamlanan, aktif ve kilitli gorevler.',
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _MissionPath(
                      key: ValueKey<String>(
                        '${_missionStates.length}-${missionForAdventure?.id}-$completedMissionCount',
                      ),
                      missionStates: _missionStates,
                      currentMissionId: missionForAdventure?.id,
                      onMissionTap: _openMission,
                    ),
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

class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFEFD8), Color(0xFFFFF8EC), Color(0xFFEFF8FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 10,
            child: Icon(Icons.wb_sunny_rounded, color: Colors.orange.shade300, size: 32),
          ),
          Positioned(
            right: 12,
            bottom: 8,
            child: Icon(Icons.school_rounded, color: Colors.blueGrey.shade300, size: 34),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const PicoAvatar(size: 130, animate: true),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gunaydin!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bugun yeni bir Portekiz macerasi bizi bekliyor!',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade700,
                              height: 1.3,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _AdventureCard extends StatelessWidget {
  const _AdventureCard({
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.progress,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final int xp;
  final double progress;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1553D7), Color(0xFF2D78FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D78FF).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '+$xp XP',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.3,
                ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: safeProgress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 9,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('Basla'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E5CF0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  const _AnimatedStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 26, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: value.toDouble()),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, _) {
                    return Text(
                      animatedValue.round().toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalRingCard extends StatelessWidget {
  const _DailyGoalRingCard({
    required this.progress,
    required this.completed,
    required this.target,
  });

  final double progress;
  final int completed;
  final int target;

  @override
  Widget build(BuildContext context) {
    final safeValue = progress.clamp(0.0, 1.0);
    final percent = (safeValue * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 8,
                  color: Colors.grey.shade200,
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: safeValue),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      color: AppColors.primary,
                    );
                  },
                ),
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gunun Hedefi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Harika gidiyorsun. $completed / $target gorevi tamamladin.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionPath extends StatelessWidget {
  const _MissionPath({
    super.key,
    required this.missionStates,
    required this.currentMissionId,
    required this.onMissionTap,
  });

  final List<MissionState> missionStates;
  final String? currentMissionId;
  final ValueChanged<String> onMissionTap;

  @override
  Widget build(BuildContext context) {
    if (missionStates.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 188,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: missionStates.length,
        separatorBuilder: (context, index) => Center(
          child: Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        itemBuilder: (context, index) {
          final state = missionStates[index];
          final mission = state.mission;
          final isCurrent = mission.id == currentMissionId && !state.isCompleted;
          final isLocked = !state.isUnlocked;

          final nodeColor = isLocked
              ? Colors.grey.shade400
              : (state.isCompleted
                  ? AppColors.primary
                  : (isCurrent ? const Color(0xFF2D78FF) : Colors.white));

          final icon = isLocked
              ? Icons.lock_rounded
              : (state.isCompleted ? Icons.star_rounded : Icons.play_arrow_rounded);

          final iconColor = isLocked || state.isCompleted || isCurrent
              ? Colors.white
              : const Color(0xFF2D78FF);

          final textColor = isLocked ? Colors.grey.shade600 : AppColors.text;
          final nodeSize = isCurrent ? 74.0 : 60.0;
          final borderColor = isCurrent
              ? const Color(0xFF2D78FF).withValues(alpha: 0.35)
              : Colors.grey.shade300;

          final topOffset = index.isEven ? 8.0 : 30.0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(top: topOffset),
            width: 110,
            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: isLocked ? null : () => onMissionTap(mission.id),
                  child: Container(
                    width: nodeSize,
                    height: nodeSize,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: isCurrent ? 32 : 26,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'M${mission.id.replaceFirst('mission_', '')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLocked ? 'Kilitli' : (state.isCompleted ? 'Tamamlandi' : (isCurrent ? 'Aktif' : 'Acik')),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
