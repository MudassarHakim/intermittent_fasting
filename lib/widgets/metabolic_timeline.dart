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
          _AllPhasesInfo(
            currentPhase: currentPhase,
            maxHours: maxHours,
          ),
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

// ─── All Phases Info ──────────────────────────────────────────

class _AllPhasesInfo extends StatelessWidget {
  final MetabolicPhase currentPhase;
  final double maxHours;

  const _AllPhasesInfo({
    required this.currentPhase,
    required this.maxHours,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = MetabolicPhases.phases.indexOf(currentPhase);
    final visiblePhases = MetabolicPhases.phases
        .where((p) => p.startHour < maxHours)
        .toList();

    return Column(
      children: visiblePhases.asMap().entries.map((entry) {
        final index = MetabolicPhases.phases.indexOf(entry.value);
        final phase = entry.value;
        final isCurrent = index == currentIndex;
        final isPast = index < currentIndex;
        final isFuture = index > currentIndex;
        final isLast = entry.key == visiblePhases.length - 1;

        return _PhaseCard(
          phase: phase,
          isCurrent: isCurrent,
          isPast: isPast,
          isFuture: isFuture,
          isLast: isLast,
        );
      }).toList(),
    );
  }
}

// ─── Phase Card ───────────────────────────────────────────────

class _PhaseCard extends StatelessWidget {
  final MetabolicPhase phase;
  final bool isCurrent;
  final bool isPast;
  final bool isFuture;
  final bool isLast;

  const _PhaseCard({
    required this.phase,
    required this.isCurrent,
    required this.isPast,
    required this.isFuture,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final double opacity = isCurrent ? 1.0 : (isPast ? 0.5 : 0.7);
    final Color phaseColor =
        isCurrent ? phase.color : phase.color.withValues(alpha: opacity);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrent
              ? phase.color.withValues(alpha: 0.1)
              : AppTheme.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent
                ? phase.color.withValues(alpha: 0.3)
                : AppTheme.textMuted.withValues(alpha: 0.08),
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: phaseColor.withValues(alpha: isCurrent ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPast ? Icons.check_circle_rounded : phase.icon,
                size: 20,
                color: phaseColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          phase.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: phaseColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      _StatusBadge(
                        isCurrent: isCurrent,
                        isPast: isPast,
                        color: phaseColor,
                        startHour: phase.startHour,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phase.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isCurrent
                              ? AppTheme.textSecondary
                              : AppTheme.textMuted,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isCurrent;
  final bool isPast;
  final Color color;
  final int startHour;

  const _StatusBadge({
    required this.isCurrent,
    required this.isPast,
    required this.color,
    required this.startHour,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    Color bgColor;
    Color textColor;

    if (isCurrent) {
      label = 'ACTIVE';
      bgColor = color.withValues(alpha: 0.15);
      textColor = color;
    } else if (isPast) {
      label = 'DONE';
      bgColor = AppTheme.success.withValues(alpha: 0.1);
      textColor = AppTheme.success.withValues(alpha: 0.6);
    } else {
      label = '${startHour}h+';
      bgColor = AppTheme.textMuted.withValues(alpha: 0.08);
      textColor = AppTheme.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
