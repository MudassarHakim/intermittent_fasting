import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../core/metabolic_phases.dart';

// ─── Metabolic Timeline Widget ────────────────────────────────

class MetabolicTimeline extends StatelessWidget {
  final Duration elapsed;
  final int targetHours;

  const MetabolicTimeline({
    super.key,
    required this.elapsed,
    required this.targetHours,
  });

  @override
  Widget build(BuildContext context) {
    final currentPhase = MetabolicPhases.getCurrentPhase(elapsed);
    final elapsedHours = elapsed.inMinutes / 60.0;
    final maxHours = targetHours.clamp(1, 168).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.textMuted.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                size: 18,
                color: AppTheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Metabolic Timeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _TimelineBar(
            elapsedHours: elapsedHours,
            maxHours: maxHours,
          ),
          const SizedBox(height: 12),
          _TimelineLabels(maxHours: maxHours),
          const SizedBox(height: 20),
          _CurrentPhaseInfo(phase: currentPhase),
        ],
      ),
    );
  }
}

// ─── Timeline Bar ─────────────────────────────────────────────

class _TimelineBar extends StatelessWidget {
  final double elapsedHours;
  final double maxHours;

  const _TimelineBar({
    required this.elapsedHours,
    required this.maxHours,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final progressFraction = (elapsedHours / maxHours).clamp(0.0, 1.0);
        final dotPosition = progressFraction * totalWidth;

        return SizedBox(
          height: 40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: _ZoneSegments(
                  totalWidth: totalWidth,
                  maxHours: maxHours,
                ),
              ),
              Positioned(
                top: 2,
                left: (dotPosition - 10).clamp(0, totalWidth - 20),
                child: _ProgressDot(
                  color: MetabolicPhases.getCurrentPhase(
                    Duration(minutes: (elapsedHours * 60).round()),
                  ).color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Zone Segments ────────────────────────────────────────────

class _ZoneSegments extends StatelessWidget {
  final double totalWidth;
  final double maxHours;

  const _ZoneSegments({
    required this.totalWidth,
    required this.maxHours,
  });

  @override
  Widget build(BuildContext context) {
    const phases = MetabolicPhases.phases;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 16,
        width: totalWidth,
        child: Row(
          children: List.generate(phases.length, (i) {
            final phase = phases[i];
            final nextStart = i + 1 < phases.length
                ? phases[i + 1].startHour.toDouble()
                : maxHours;
            final segmentStart = phase.startHour.toDouble();

            if (segmentStart >= maxHours) return const SizedBox.shrink();

            final segmentEnd = nextStart.clamp(segmentStart, maxHours);
            final segmentFraction =
                (segmentEnd - segmentStart) / maxHours;

            if (segmentFraction <= 0) return const SizedBox.shrink();

            return Expanded(
              flex: ((segmentEnd - segmentStart) * 100).round().clamp(1, 10000),
              child: Container(
                decoration: BoxDecoration(
                  color: phase.color.withValues(alpha: 0.35),
                  border: i > 0
                      ? Border(
                          left: BorderSide(
                            color: AppTheme.surfaceCard.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                        )
                      : null,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Progress Dot ─────────────────────────────────────────────

class _ProgressDot extends StatelessWidget {
  final Color color;

  const _ProgressDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.surfaceCard,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ─── Timeline Labels ──────────────────────────────────────────

class _TimelineLabels extends StatelessWidget {
  final double maxHours;

  const _TimelineLabels({required this.maxHours});

  @override
  Widget build(BuildContext context) {
    final labelHours = <int>[];
    final step = maxHours <= 12
        ? 4
        : maxHours <= 24
            ? 6
            : 12;
    for (int h = 0; h <= maxHours.ceil(); h += step) {
      labelHours.add(h);
    }
    if (labelHours.last < maxHours.ceil()) {
      labelHours.add(maxHours.ceil());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labelHours.map((h) {
        return Text(
          '${h}h',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
          ),
        );
      }).toList(),
    );
  }
}

// ─── Current Phase Info ───────────────────────────────────────

class _CurrentPhaseInfo extends StatelessWidget {
  final MetabolicPhase phase;

  const _CurrentPhaseInfo({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: phase.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: phase.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: phase.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              phase.icon,
              size: 20,
              color: phase.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: phase.color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  phase.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.4,
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
