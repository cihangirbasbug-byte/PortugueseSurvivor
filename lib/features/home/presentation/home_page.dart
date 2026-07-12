import 'dart:math' as math;

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
      backgroundColor: const Color(0xFFFFF9E8),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF9E8), Color(0xFFEAF6FF), Color(0xFFFFF8CD)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopHeader(onRefresh: _loadHomeMissionState),
                    const SizedBox(height: 14),
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
                      onPressed: missionForAdventure == null ? null : () => _openMission(missionForAdventure.id),
                    ),
                    const SizedBox(height: 18),
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
                                  color: const Color(0xFFE5A52A),
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
                              color: const Color(0xFFE5A52A),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 8),
                    _MissionPath(
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

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Color(0xFF0E8A4B), Color(0xFF40B86C)]),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E8A4B).withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'P',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Portekizli Hayatta Kal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_rounded),
        ),
      ],
    );
  }
}

class _HomeHeroCard extends StatefulWidget {
  const _HomeHeroCard();

  @override
  State<_HomeHeroCard> createState() => _HomeHeroCardState();
}

class _HomeHeroCardState extends State<_HomeHeroCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF2D7), Color(0xFFFFFBEA), Color(0xFFE8F7FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 6,
            top: 6,
            child: Icon(Icons.wb_sunny_rounded, color: Colors.amber.shade600, size: 28),
          ),
          Positioned(
            right: 10,
            top: 14,
            child: Icon(Icons.cloud_rounded, color: Colors.blue.shade200, size: 34),
          ),
          Positioned(
            right: 6,
            bottom: 4,
            child: Row(
              children: [
                Icon(Icons.school_rounded, color: Colors.brown.shade300, size: 28),
                const SizedBox(width: 3),
                Icon(Icons.groups_rounded, color: Colors.blueGrey.shade300, size: 22),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  final floatY = math.sin(t * math.pi * 2) * 5;
                  final breathScale = 1 + (math.sin(t * math.pi * 2) * 0.03);
                  return Transform.translate(
                    offset: Offset(0, floatY),
                    child: Transform.scale(scale: breathScale, child: child),
                  );
                },
                child: const PicoAvatar(size: 190, animate: true),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE6F2EA), width: 1.2),
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
                      const SizedBox(height: 4),
                      Text(
                        'Bugun yeni bir Portekiz macerasi bizi bekliyor!',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade700,
                              height: 1.35,
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF23422F),
              ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E8A4B), Color(0xFF4DB777)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E8A4B).withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
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
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.3,
                ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: safeProgress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.28),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF106A3D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.rocket_launch_rounded),
                  SizedBox(width: 8),
                  Text('Basla', style: TextStyle(fontWeight: FontWeight.w700)),
                ],
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
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFFFEF9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: value.toDouble()),
                  duration: const Duration(milliseconds: 720),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, _) {
                    return Text(
                      animatedValue.round().toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF23422F),
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
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Colors.white, Color(0xFFFFFDF6)]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Harika gidiyorsun. $completed / $target gorevi tamamladin.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
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
    required this.missionStates,
    required this.currentMissionId,
    required this.onMissionTap,
  });

  final List<MissionState> missionStates;
  final String? currentMissionId;
  final ValueChanged<String> onMissionTap;

  @override
  Widget build(BuildContext context) {
    if (missionStates.isEmpty) return const SizedBox.shrink();

    final spacing = 130.0;
    final startX = 58.0;
    final width = startX * 2 + ((missionStates.length - 1) * spacing);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        height: 230,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(width, 230),
              painter: _AdventurePathPainter(
                count: missionStates.length,
                spacing: spacing,
                startX: startX,
              ),
            ),
            for (var i = 0; i < missionStates.length; i++)
              _MissionNode(
                state: missionStates[i],
                x: startX + (i * spacing),
                y: i.isEven ? 78 : 142,
                isCurrent: missionStates[i].mission.id == currentMissionId && !missionStates[i].isCompleted,
                onTap: onMissionTap,
              ),
          ],
        ),
      ),
    );
  }
}

class _AdventurePathPainter extends CustomPainter {
  const _AdventurePathPainter({
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
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFD8ECCE), Color(0xFFECE7C9)],
      ).createShader(Offset.zero & size);

    for (var i = 0; i < count - 1; i++) {
      final x1 = startX + (i * spacing);
      final y1 = i.isEven ? 78.0 : 142.0;
      final x2 = startX + ((i + 1) * spacing);
      final y2 = (i + 1).isEven ? 78.0 : 142.0;
      final control = Offset((x1 + x2) / 2, (math.min(y1, y2) - 36));

      final path = Path()
        ..moveTo(x1, y1)
        ..quadraticBezierTo(control.dx, control.dy, x2, y2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AdventurePathPainter oldDelegate) {
    return oldDelegate.count != count;
  }
}

class _MissionNode extends StatefulWidget {
  const _MissionNode({
    required this.state,
    required this.x,
    required this.y,
    required this.isCurrent,
    required this.onTap,
  });

  final MissionState state;
  final double x;
  final double y;
  final bool isCurrent;
  final ValueChanged<String> onTap;

  @override
  State<_MissionNode> createState() => _MissionNodeState();
}

class _MissionNodeState extends State<_MissionNode> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    if (widget.isCurrent) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _MissionNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isCurrent && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.state.mission;
    final isLocked = !widget.state.isUnlocked;

    Color fill;
    IconData icon;
    String subtitle;

    if (isLocked) {
      fill = const Color(0xFFB5BBC0);
      icon = Icons.lock_rounded;
      subtitle = 'Kilitli';
    } else if (widget.state.isCompleted) {
      fill = const Color(0xFF1FA35E);
      icon = Icons.check_rounded;
      subtitle = 'Tamamlandi';
    } else if (widget.isCurrent) {
      fill = const Color(0xFFFFC73B);
      icon = Icons.play_arrow_rounded;
      subtitle = 'Aktif';
    } else {
      fill = Colors.white;
      icon = Icons.flag_rounded;
      subtitle = 'Acik';
    }

    final nodeSize = widget.isCurrent ? 82.0 : 72.0;

    return Positioned(
      left: widget.x - (nodeSize / 2),
      top: widget.y - (nodeSize / 2),
      child: SizedBox(
        width: nodeSize + 44,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                final scale = widget.isCurrent ? 1 + (_pulse.value * 0.08) : 1.0;
                return Transform.scale(scale: scale, child: child);
              },
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: isLocked ? null : () => widget.onTap(mission.id),
                child: Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fill,
                    border: Border.all(
                      color: widget.isCurrent ? const Color(0xFFF9E29D) : Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: (isLocked || widget.state.isCompleted || widget.isCurrent)
                        ? Colors.white
                        : AppColors.primary,
                    size: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'M${mission.id.replaceFirst('mission_', '')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF23422F),
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
