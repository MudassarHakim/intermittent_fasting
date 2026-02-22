import 'package:flutter/material.dart';
import '../app/theme.dart';

class MetabolicPhase {
  final String name;
  final String description;
  final int startHour;
  final Color color;
  final IconData icon;

  const MetabolicPhase({
    required this.name,
    required this.description,
    required this.startHour,
    required this.color,
    required this.icon,
  });
}

class MetabolicPhases {
  MetabolicPhases._();

  static const List<MetabolicPhase> phases = [
    MetabolicPhase(
      name: 'Fed State',
      description: 'Your body is digesting and absorbing nutrients. Insulin levels are elevated.',
      startHour: 0,
      color: AppTheme.eating,
      icon: Icons.restaurant_rounded,
    ),
    MetabolicPhase(
      name: 'Early Fasting',
      description: 'Blood sugar normalizes. Your body begins using stored glycogen for energy.',
      startHour: 4,
      color: AppTheme.warning,
      icon: Icons.trending_down_rounded,
    ),
    MetabolicPhase(
      name: 'Glycogen Depletion',
      description: 'Liver glycogen stores are depleting. Your body is transitioning to fat oxidation.',
      startHour: 8,
      color: Color(0xFFFF8C42),
      icon: Icons.local_fire_department_rounded,
    ),
    MetabolicPhase(
      name: 'Fat Burning',
      description: 'Research suggests your body is now primarily using lipids for fuel.',
      startHour: 12,
      color: AppTheme.fasting,
      icon: Icons.whatshot_rounded,
    ),
    MetabolicPhase(
      name: 'Deep Ketosis',
      description: 'Studies indicate enhanced fat oxidation and ketone body production may occur.',
      startHour: 18,
      color: AppTheme.primary,
      icon: Icons.bolt_rounded,
    ),
    MetabolicPhase(
      name: 'Autophagy Zone',
      description: 'Some research suggests cellular maintenance processes may be upregulated.',
      startHour: 24,
      color: AppTheme.accent,
      icon: Icons.auto_fix_high_rounded,
    ),
  ];

  static MetabolicPhase getCurrentPhase(Duration elapsed) {
    final hours = elapsed.inHours;
    MetabolicPhase current = phases.first;
    for (final phase in phases) {
      if (hours >= phase.startHour) {
        current = phase;
      }
    }
    return current;
  }

  static double getPhaseProgress(Duration elapsed) {
    final hours = elapsed.inMinutes / 60.0;
    final current = getCurrentPhase(elapsed);
    final currentIndex = phases.indexOf(current);
    final nextIndex = currentIndex + 1;

    if (nextIndex >= phases.length) return 1.0;

    final nextPhase = phases[nextIndex];
    final phaseSpan = nextPhase.startHour - current.startHour;
    if (phaseSpan == 0) return 1.0;

    return ((hours - current.startHour) / phaseSpan).clamp(0.0, 1.0);
  }
}
