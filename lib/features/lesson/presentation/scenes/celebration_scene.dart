import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/animation/pico_animation_controller.dart';
import '../../../../shared/widgets/character/pico_character.dart';
import '../../../../shared/widgets/design_system/primary_button.dart';
import '../../../../shared/widgets/design_system/reward_chip.dart';
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

class _CelebrationSceneState extends State<CelebrationScene>
    with TickerProviderStateMixin {
  late final AnimationController _jumpController;
  late final AnimationController _countController;
  late final AnimationController _badgeController;
  late final AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _countController.dispose();
    _badgeController.dispose();
    _sparkleController.dispose();
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
                colors: [
                  Color(0xFFFFF4D6),
                  Color(0xFFFFFDF4),
                  Color(0xFFEAF6FF),
                ],
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
                    final bounce =
                        math.sin(_jumpController.value * math.pi) * 16;
                    return Transform.translate(
                      offset: Offset(0, -bounce),
                      child: child,
                    );
                  },
                  child: PicoCharacter(
                    size: PicoCharacterSize.large,
                    customSize: 136,
                    state: PicoCharacterState.celebrating,
                    emotion: PicoEmotion.excited,
                    controller: widget.picoAnimationController,
                  ),
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
                AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, child) {
                    final glow = 0.2 + (_sparkleController.value * 0.35);
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFF5C85C,
                            ).withValues(alpha: glow),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _badgeController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFE8D9A5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: Color(0xFFE4A32A),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.badge.isEmpty
                                ? 'Ilk Adim Rozeti'
                                : widget.badge,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF7A6118),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _countController,
                  builder: (context, _) {
                    final xpValue = (widget.xp * _countController.value)
                        .round();
                    final courageValue =
                        (widget.courage * _countController.value).round();
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Wrap(
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
                      ),
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

class _ConfettiLayer extends StatefulWidget {
  const _ConfettiLayer();

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      const Color(0xFFFFB703),
      const Color(0xFF8ECAE6),
      const Color(0xFF52B788),
      const Color(0xFFE76F51),
    ];

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final progress = _controller.value;
              return Stack(
                children: [
                  for (var index = 0; index < 34; index++)
                    Positioned(
                      left: ((constraints.maxWidth + 80) / 34) * index,
                      top:
                          -50 +
                          ((constraints.maxHeight + 140) *
                              ((progress + (index * 0.035)) % 1)),
                      child: Transform.rotate(
                        angle: (progress * math.pi * 4) + (index * 0.21),
                        child: Container(
                          width: 7 + (index % 3),
                          height: 10 + (index % 4),
                          decoration: BoxDecoration(
                            color: colors[index % colors.length].withValues(
                              alpha: 0.74,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  for (var star = 0; star < 16; star++)
                    Positioned(
                      left:
                          (constraints.maxWidth / 16) * star +
                          ((star % 2 == 0 ? 1 : -1) * progress * 10),
                      top:
                          12 +
                          ((star % 6) * 16) +
                          (math.sin((progress * math.pi * 2) + star) * 16),
                      child: Icon(
                        Icons.star_rounded,
                        color: const Color(
                          0xFFFFD86B,
                        ).withValues(alpha: 0.35 + ((star % 4) * 0.12)),
                        size: 8 + (star % 5).toDouble(),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
