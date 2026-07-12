import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

class MissionNode extends StatefulWidget {
  const MissionNode({
    super.key,
    required this.label,
    required this.subtitle,
    required this.state,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final MissionNodeState state;
  final VoidCallback? onTap;

  @override
  State<MissionNode> createState() => _MissionNodeStateState();
}

class _MissionNodeStateState extends State<MissionNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.state == MissionNodeState.current) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MissionNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == MissionNodeState.current && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (widget.state != MissionNodeState.current && _pulse.isAnimating) {
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
    final (Color fill, IconData icon, Color iconColor) = switch (widget.state) {
      MissionNodeState.completed => (
        const Color(0xFF1FA35E),
        Icons.check_rounded,
        Colors.white,
      ),
      MissionNodeState.current => (
        const Color(0xFFFFC73B),
        Icons.play_arrow_rounded,
        Colors.white,
      ),
      MissionNodeState.locked => (
        const Color(0xFFB6BDC3),
        Icons.lock_rounded,
        Colors.white,
      ),
      MissionNodeState.open => (
        Colors.white,
        Icons.flag_rounded,
        const Color(0xFF0E8A4B),
      ),
    };

    final size = widget.state == MissionNodeState.current ? 80.0 : 70.0;

    return SizedBox(
      width: size + 44,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              final scale = widget.state == MissionNodeState.current
                  ? 1 + (_pulse.value * 0.08)
                  : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: widget.state == MissionNodeState.locked
                  ? null
                  : widget.onTap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fill,
                  border: Border.all(
                    color: widget.state == MissionNodeState.current
                        ? const Color(0xFFF8E2A0)
                        : Colors.white,
                    width: 4,
                  ),
                  boxShadow: AppShadows.soft,
                ),
                child: Icon(icon, color: iconColor, size: 33),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF23422F),
            ),
          ),
          Text(
            widget.subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

enum MissionNodeState { completed, current, locked, open }
