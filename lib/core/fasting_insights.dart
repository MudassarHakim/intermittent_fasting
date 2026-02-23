class FastingInsight {
  final String title;
  final String body;
  final String source;
  final List<String> goals;

  const FastingInsight({
    required this.title,
    required this.body,
    this.source = 'Lessan & Ali, Nutrients 2019',
    this.goals = const ['fat_loss', 'metabolic_health', 'autophagy'],
  });
}

class FastingInsights {
  FastingInsights._();

  static const List<FastingInsight> insights = [
    FastingInsight(
      title: 'Fuel Source Transition',
      body: 'Research suggests your body shifts from carbohydrate to lipid metabolism as fasting duration increases.',
      goals: ['fat_loss', 'metabolic_health'],
    ),
    FastingInsight(
      title: 'Lipid Profile Benefits',
      body: 'Studies indicate intermittent fasting may be associated with improved cholesterol and triglyceride levels.',
      goals: ['metabolic_health'],
    ),
    FastingInsight(
      title: 'Insulin Sensitivity',
      body: 'Fasting periods may help improve insulin sensitivity and glucose regulation over time.',
      goals: ['metabolic_health'],
    ),
    FastingInsight(
      title: 'Preserve Lean Mass',
      body: 'Research shows fasting may reduce body fat while preserving lean muscle mass when combined with adequate nutrition.',
      goals: ['fat_loss'],
    ),
    FastingInsight(
      title: 'Circadian Rhythm',
      body: 'Fasting influences your body\'s hormonal rhythms, including cortisol, leptin, and ghrelin cycles.',
      goals: ['metabolic_health', 'autophagy'],
    ),
    FastingInsight(
      title: 'Cellular Maintenance',
      body: 'Some studies suggest extended fasting periods may upregulate autophagy, a cellular cleanup process.',
      goals: ['autophagy'],
    ),
    FastingInsight(
      title: 'Metabolic Rate',
      body: 'Research indicates resting metabolic rate remains largely unchanged during intermittent fasting.',
      goals: ['fat_loss', 'metabolic_health'],
    ),
    FastingInsight(
      title: 'Glycogen Cycles',
      body: 'During fasting, your liver glycogen undergoes cycles of depletion and repletion, influencing energy availability.',
      goals: ['fat_loss', 'metabolic_health'],
    ),
    FastingInsight(
      title: 'Hydration Matters',
      body: 'Staying well hydrated during eating windows is important for supporting metabolic processes during fasts.',
      goals: ['fat_loss', 'metabolic_health', 'autophagy'],
    ),
    FastingInsight(
      title: 'Meal Quality Counts',
      body: 'The quality of food during eating windows is crucial for maximizing the benefits of your fasting regimen.',
      goals: ['fat_loss', 'metabolic_health'],
    ),
    FastingInsight(
      title: 'Evening Activity',
      body: 'Studies show that physical activity levels often increase in the evening during fasting periods.',
      goals: ['fat_loss'],
    ),
    FastingInsight(
      title: 'Consistency Is Key',
      body: 'Research suggests metabolic adaptation and benefits improve with consistent, regular fasting practice.',
      goals: ['fat_loss', 'metabolic_health', 'autophagy'],
    ),
    FastingInsight(
      title: 'Individual Variability',
      body: 'Metabolic responses to fasting vary between individuals. Listen to your body and adjust accordingly.',
      goals: ['fat_loss', 'metabolic_health', 'autophagy'],
    ),
    FastingInsight(
      title: 'Cardiovascular Health',
      body: 'Some research associates intermittent fasting with improved cardiovascular health markers.',
      goals: ['metabolic_health'],
    ),
    FastingInsight(
      title: 'Inflammation Reduction',
      body: 'Studies suggest intermittent fasting may help reduce markers of inflammation over time.',
      goals: ['autophagy', 'metabolic_health'],
    ),
  ];

  static FastingInsight getInsightOfTheDay({String? goal}) {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;

    if (goal != null) {
      final filtered = insights.where((i) => i.goals.contains(goal)).toList();
      if (filtered.isNotEmpty) {
        return filtered[dayOfYear % filtered.length];
      }
    }

    return insights[dayOfYear % insights.length];
  }
}
