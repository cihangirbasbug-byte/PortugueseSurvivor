import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/mission_onboarding_service.dart';
import '../../../core/services/mission_manager.dart';
import '../../../core/services/progress_service.dart';
import '../../../shared/widgets/design_system/adventure_card.dart';
import '../../../shared/widgets/design_system/dialogue_bubble.dart';
import '../../../shared/widgets/design_system/mission_node.dart';
import '../../../shared/widgets/design_system/progress_ring.dart';
import '../../../shared/widgets/design_system/stat_card.dart';
import '../../../shared/widgets/character/character_layer.dart';
import '../../../shared/widgets/character/pico_character.dart';
import '../../lesson/data/models/mission_model.dart';
import '../../lesson/data/repositories/mission_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MissionRepository _repository = MissionRepository();
  late final MissionManager _missionManager = MissionManager(
    repository: _repository,
  );
  late final ProgressService _progressService = ProgressService(
    repository: _repository,
  );
  final MissionOnboardingService _onboardingService =
      MissionOnboardingService();

  List<MissionState> _missionStates = const <MissionState>[];
  ProgressSummary _summary = const ProgressSummary(
    totalXp: 0,
    totalCourage: 0,
    completionPercent: 0,
    badges: <String>[],
  );
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
    final bool shouldShowOnboarding = await _onboardingService.shouldShow(
      missionId,
    );

    if (!mounted) return;

    final bool? result;
    if (shouldShowOnboarding) {
      result = await context.push<bool>(
        AppRouter.onboardingLocation(missionId: missionId, entryFromHome: true),
      );
    } else {
      result = await context.push<bool>(AppRouter.missionLocation(missionId));
    }

    if (result == true) {
      await _loadHomeMissionState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedMissionCount = _missionStates
        .where((state) => state.isCompleted)
        .length;

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF6E7), Color(0xFFE8F6FF), Color(0xFFFFF9C9)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1024),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      onRefresh: _loadHomeMissionState,
                      onSettings: () => context.push(AppRouter.settingsPath),
                    ),
                    const SizedBox(height: 14),
                    const _HeroSection(),
                    const SizedBox(height: 18),
                    _SectionTitle(
                      title: 'Adventure Card',
                      subtitle: 'Bugunun aktif gorevi burada.',
                    ),
                    const SizedBox(height: 10),
                    AdventureCard(
                      title: missionForAdventure?.title ?? 'Bolum tamamlandi',
                      subtitle: missionForAdventure == null
                          ? 'Yeni maceralar yakinda.'
                          : 'Siradaki hedef: ${missionForAdventure.learningGoal}',
                      xp: missionRewardXp,
                      progress: missionProgress,
                      onPressed: missionForAdventure == null
                          ? null
                          : () => _openMission(missionForAdventure.id),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 760) {
                          return Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.auto_awesome_rounded,
                                  title: 'Toplam XP',
                                  value: _summary.totalXp,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.favorite_rounded,
                                  title: 'Toplam Cesaret',
                                  value: _summary.totalCourage,
                                  color: const Color(0xFFE4A129),
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            StatCard(
                              icon: Icons.auto_awesome_rounded,
                              title: 'Toplam XP',
                              value: _summary.totalXp,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 10),
                            StatCard(
                              icon: Icons.favorite_rounded,
                              title: 'Toplam Cesaret',
                              value: _summary.totalCourage,
                              color: const Color(0xFFE4A129),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _DailyGoalCard(
                      progress: _summary.completionPercent,
                      completed: completedMissionCount,
                      target: _missionStates.length,
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle(
                      title: 'Chapter Map',
                      subtitle:
                          'Escola da Amizade dunyasi uzerinden gorev yolu.',
                    ),
                    const SizedBox(height: 8),
                    ChapterWorldMap(
                      missionStates: _missionStates,
                      currentMissionId: missionForAdventure?.id,
                      onMissionTap: _openMission,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onRefresh, required this.onSettings});

  final VoidCallback onRefresh;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF0E8A4B), Color(0xFF48B774)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E8A4B).withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'P',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Escola da Amizade',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF233228),
            ),
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.settings_rounded),
        ),
      ],
    );
  }
}

class _HeroSection extends StatefulWidget {
  const _HeroSection();

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFECCD), Color(0xFFFFF7E6), Color(0xFFE2F3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              return Positioned(
                left: 8,
                top: 4,
                child: Opacity(
                  opacity: 0.72 + (math.sin(t * math.pi * 2) * 0.15),
                  child: Transform.scale(
                    scale: 1 + (math.sin(t * math.pi * 2) * 0.08),
                    child: child,
                  ),
                ),
              );
            },
            child: Icon(
              Icons.wb_sunny_rounded,
              color: Colors.amber.shade600,
              size: 34,
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              return Positioned(
                right: 8 + (math.sin(t * math.pi * 2) * 12),
                top: 18,
                child: child!,
              );
            },
            child: Icon(
              Icons.cloud_rounded,
              color: Colors.lightBlue.shade200,
              size: 38,
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              return Positioned(
                right: 80 + (math.cos(t * math.pi * 2) * 8),
                top: 30,
                child: Opacity(opacity: 0.7, child: child!),
              );
            },
            child: Icon(
              Icons.cloud_rounded,
              color: Colors.blue.shade100,
              size: 26,
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              return Positioned(
                left: 138 + (math.sin(t * math.pi * 2) * 18),
                top: 22,
                child: Opacity(
                  opacity: 0.62,
                  child: Icon(
                    Icons.flight_rounded,
                    color: Colors.lightBlue.shade300,
                    size: 16,
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  color: Colors.brown.shade300,
                  size: 30,
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.groups_rounded,
                  color: Colors.blueGrey.shade300,
                  size: 24,
                ),
              ],
            ),
          ),
          Positioned(
            left: 14,
            top: 44,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'First School Day • Sabah',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3A5B45),
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 720;

              final picoLayer = CharacterLayer(
                role: CharacterRole.pico,
                size: isCompact
                    ? PicoCharacter.dimensionFor(PicoCharacterSize.hero) *
                          1.0736
                    : PicoCharacter.dimensionFor(PicoCharacterSize.hero) * 1.22,
                picoSize: PicoCharacterSize.hero,
                picoAnimate: false,
                picoState: PicoCharacterState.idle,
                picoEmotion: PicoEmotion.idle,
                showPlate: false,
              );

              const speech = DialogueBubble(
                text:
                    'Bom dia! Ilk okul gunu basliyor. Sinifa birlikte varip ogretmene selam verecegiz.',
                maxLines: 5,
              );

              if (isCompact) {
                return Column(
                  children: [
                    picoLayer,
                    const SizedBox(height: 10),
                    const SizedBox(width: double.infinity, child: speech),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  picoLayer,
                  const SizedBox(width: 10),
                  const Expanded(child: speech),
                ],
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              return Positioned(
                left: 18 + (math.cos(t * math.pi * 2) * 8),
                bottom: 6,
                child: Transform.rotate(
                  angle: -0.24 + (math.sin(t * math.pi * 2) * 0.08),
                  child: Icon(
                    Icons.eco_rounded,
                    color: Colors.green.shade300,
                    size: 17,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              return Positioned(
                left: 52 + (math.sin(t * math.pi * 2) * 8),
                bottom: 10,
                child: Transform.rotate(
                  angle: 0.28 + (math.cos(t * math.pi * 2) * 0.07),
                  child: Icon(
                    Icons.eco_rounded,
                    color: Colors.lightGreen.shade400,
                    size: 15,
                  ),
                ),
              );
            },
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2A3A33),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({
    required this.progress,
    required this.completed,
    required this.target,
  });

  final double progress;
  final int completed;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFFFCEF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ProgressRing(progress: progress),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Goal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Super! $completed / $target gorev tamamlandi. Hadi devam edelim.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterWorldMap extends StatelessWidget {
  const ChapterWorldMap({
    super.key,
    required this.missionStates,
    required this.currentMissionId,
    required this.onMissionTap,
  });

  final List<MissionState> missionStates;
  final String? currentMissionId;
  final ValueChanged<String> onMissionTap;

  static const List<String> _locations = <String>[
    'School Entrance',
    'Classroom',
    'Playground',
    'Library',
    'Cafeteria',
    'Art Room',
    'Music Room',
    'Friendship Yard',
    'Town Square',
    'Festival Stage',
  ];

  @override
  Widget build(BuildContext context) {
    if (missionStates.isEmpty) {
      return const SizedBox.shrink();
    }

    final spacing = 156.0;
    final startX = 64.0;
    final width = startX * 2 + ((missionStates.length - 1) * spacing);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFCF0), Color(0xFFEFF7FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          height: 248,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, 248),
                painter: _MapDecorationPainter(
                  count: missionStates.length,
                  spacing: spacing,
                  startX: startX,
                ),
              ),
              CustomPaint(
                size: Size(width, 248),
                painter: _WalkPathPainter(
                  count: missionStates.length,
                  spacing: spacing,
                  startX: startX,
                ),
              ),
              for (var i = 0; i < missionStates.length; i++)
                Positioned(
                  left: startX + (i * spacing) - 56,
                  top: i.isEven ? 78 : 152,
                  child: Column(
                    children: [
                      Text(
                        _locations[i % _locations.length],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF52645B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      MissionNode(
                        label:
                            'M${missionStates[i].mission.id.replaceFirst('mission_', '')}',
                        subtitle: _subtitleFor(
                          missionStates[i],
                          missionStates[i].mission.id == currentMissionId,
                        ),
                        state: _stateFor(
                          missionStates[i],
                          missionStates[i].mission.id == currentMissionId,
                        ),
                        onTap: missionStates[i].isUnlocked
                            ? () => onMissionTap(missionStates[i].mission.id)
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  MissionNodeState _stateFor(MissionState state, bool isCurrent) {
    if (!state.isUnlocked) return MissionNodeState.locked;
    if (state.isCompleted) return MissionNodeState.completed;
    if (isCurrent) return MissionNodeState.current;
    return MissionNodeState.open;
  }

  String _subtitleFor(MissionState state, bool isCurrent) {
    if (!state.isUnlocked) return 'Locked';
    if (state.isCompleted) return 'Completed';
    if (isCurrent) return 'Current';
    return 'Open';
  }
}

class _WalkPathPainter extends CustomPainter {
  const _WalkPathPainter({
    required this.count,
    required this.spacing,
    required this.startX,
  });

  final int count;
  final double spacing;
  final double startX;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFD5EBC5), Color(0xFFF0E6BA), Color(0xFFD3E8FF)],
      ).createShader(Offset.zero & size);

    for (var i = 0; i < count - 1; i++) {
      final x1 = startX + (i * spacing);
      final y1 = i.isEven ? 132.0 : 204.0;
      final x2 = startX + ((i + 1) * spacing);
      final y2 = (i + 1).isEven ? 132.0 : 204.0;
      final path = Path()
        ..moveTo(x1, y1)
        ..quadraticBezierTo((x1 + x2) / 2, math.min(y1, y2) - 44, x2, y2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WalkPathPainter oldDelegate) {
    return oldDelegate.count != count;
  }
}

class _MapDecorationPainter extends CustomPainter {
  const _MapDecorationPainter({
    required this.count,
    required this.spacing,
    required this.startX,
  });

  final int count;
  final double spacing;
  final double startX;

  @override
  void paint(Canvas canvas, Size size) {
    final flower = Paint()..color = const Color(0xFFF9C87A);
    final trunk = Paint()..color = const Color(0xFF8A5B3D);
    final leaves = Paint()..color = const Color(0xFF7FC67D);
    final bench = Paint()..color = const Color(0xFFC5955E);
    final sign = Paint()..color = const Color(0xFFE7D3A9);

    for (var i = 0; i < count; i++) {
      final x = startX + (i * spacing);
      final y = i.isEven ? 132.0 : 204.0;

      canvas.drawCircle(Offset(x - 56, y + 30), 3.5, flower);
      canvas.drawCircle(Offset(x - 50, y + 25), 2.6, flower);

      canvas.drawRect(Rect.fromLTWH(x + 38, y + 18, 4, 10), trunk);
      canvas.drawCircle(Offset(x + 40, y + 15), 7, leaves);

      if (i % 3 == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - 10, y + 34, 22, 5),
            const Radius.circular(2),
          ),
          bench,
        );
      }

      if (i % 4 == 1) {
        canvas.drawRect(Rect.fromLTWH(x + 58, y + 20, 2.2, 11), trunk);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 52, y + 12, 14, 7),
            const Radius.circular(2),
          ),
          sign,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapDecorationPainter oldDelegate) {
    return oldDelegate.count != count;
  }
}
