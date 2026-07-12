import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/animation/pico_animation_controller.dart';
import '../../../../shared/widgets/design_system/primary_button.dart';
import '../../../../shared/widgets/design_system/reward_chip.dart';
import '../../../../shared/widgets/pico_avatar.dart';
import '../../data/models/scene_model.dart';

class CelebrationScene extends StatefulWidget {
  const CelebrationScene({
    super.key,
    required this.scene,
    required this.badge,
    required this.xp,
    required this.courage,
    required this.picoAnimationController,
    required this.onNext,
  });

  final SceneModel scene;
  final String badge;
  final int xp;
  final int courage;
  final PicoAnimationController picoAnimationController;
  final VoidCallback onNext;

  @override
  State<CelebrationScene> createState() => _CelebrationSceneState();
}

class _CelebrationSceneState extends State<CelebrationScene> with TickerProviderStateMixin {
  late final AnimationController _jumpController;
  late final AnimationController _countController;
  late final AnimationController _badgeController;

  @override
  void initState() {
    super.initState();
    _jumpController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _countController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..forward();
    _badgeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _countController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _ConfettiLayer()),
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF4D6), Color(0xFFFFFDF4), Color(0xFFEAF6FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _jumpController,
                  builder: (context, child) {
                    final bounce = math.sin(_jumpController.value * math.pi) * 10;
                    return Transform.translate(offset: Offset(0, -bounce), child: child);
                  },
                  child: PicoAvatar(size: 122, controller: widget.picoAnimationController),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.scene.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF223128),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.scene.body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF495563),
                      ),
                ),
                const SizedBox(height: 12),
                ScaleTransition(
                  scale: CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE8D9A5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: Color(0xFFE4A32A), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          widget.badge.isEmpty ? 'Ilk Adim Rozeti' : widget.badge,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF7A6118),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _countController,
                  builder: (context, _) {
                    final xpValue = (widget.xp * _countController.value).round();
                    final courageValue = (widget.courage * _countController.value).round();
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        RewardChip(
                          label: '+$xpValue XP',
                          icon: Icons.auto_awesome_rounded,
                          backgroundColor: const Color(0x25F5C542),
                          foregroundColor: const Color(0xFF8A6A16),
                        ),
                        RewardChip(
                          label: '+$courageValue Courage',
                          icon: Icons.favorite_rounded,
                          backgroundColor: const Color(0x22E85F5F),
                          foregroundColor: const Color(0xFFB43F3F),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: widget.onNext,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiLayer extends StatelessWidget {
  const _ConfettiLayer();

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      const Color(0xFFFFB703),
      const Color(0xFF8ECAE6),
      const Color(0xFF52B788),
      const Color(0xFFE76F51),
    ];

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: List.generate(24, (index) {
              final left = (constraints.maxWidth / 24) * index;
              final duration = Duration(milliseconds: 1100 + (index * 35));
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: -40, end: constraints.maxHeight + 50),
                duration: duration,
                curve: Curves.easeIn,
                builder: (context, value, child) {
                  return Positioned(
                    left: left,
                    top: value,
                    child: Transform.rotate(
                      angle: (index % 8) * 0.25,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 8,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length].withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
