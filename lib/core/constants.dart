import '../models/fasting_plan.dart';

class AppConstants {
  AppConstants._();

  static const List<FastingPlan> fastingPlans = [
    FastingPlan(
      id: '12_12',
      name: '12:12 Circadian',
      shortName: '12:12',
      fastHours: 12,
      eatHours: 12,
      description: 'Perfect for beginners. Aligns with your natural circadian rhythm.',
      emoji: '🌅',
    ),
    FastingPlan(
      id: '16_8',
      name: '16:8 Lean Gains',
      shortName: '16:8',
      fastHours: 16,
      eatHours: 8,
      description: 'The most popular plan. Fast 16 hours, eat within an 8-hour window.',
      emoji: '⚡',
    ),
    FastingPlan(
      id: '18_6',
      name: '18:6 Warrior Lite',
      shortName: '18:6',
      fastHours: 18,
      eatHours: 6,
      description: 'A step up. Greater autophagy benefits with a tighter eating window.',
      emoji: '🔥',
    ),
    FastingPlan(
      id: '20_4',
      name: '20:4 Warrior',
      shortName: '20:4',
      fastHours: 20,
      eatHours: 4,
      description: 'Advanced. Maximise fat-burning with a 4-hour eating window.',
      emoji: '⚔️',
      isPremium: true,
    ),
    FastingPlan(
      id: '23_1',
      name: '23:1 OMAD',
      shortName: 'OMAD',
      fastHours: 23,
      eatHours: 1,
      description: 'One Meal A Day. Maximum benefits for experienced fasters.',
      emoji: '🏆',
      isPremium: true,
    ),
    FastingPlan(
      id: 'custom',
      name: 'Custom Plan',
      shortName: 'Custom',
      fastHours: 16,
      eatHours: 8,
      description: 'Set your own fasting and eating windows.',
      emoji: '🎯',
      isPremium: true,
    ),
  ];

  static FastingPlan getPlanById(String id) {
    return fastingPlans.firstWhere(
      (p) => p.id == id,
      orElse: () => fastingPlans[1], // default 16:8
    );
  }
}
