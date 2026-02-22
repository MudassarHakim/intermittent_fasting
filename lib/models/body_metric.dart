class BodyMetric {
  final String id;
  final DateTime date;
  final double? weight;
  final double? bodyFat;
  final double? waistCm;
  final int? energyLevel;
  final String? mealNote;
  final List<String> mealTags;

  BodyMetric({
    required this.id,
    required this.date,
    this.weight,
    this.bodyFat,
    this.waistCm,
    this.energyLevel,
    this.mealNote,
    this.mealTags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'weight': weight,
        'bodyFat': bodyFat,
        'waistCm': waistCm,
        'energyLevel': energyLevel,
        'mealNote': mealNote,
        'mealTags': mealTags,
      };

  factory BodyMetric.fromJson(Map<String, dynamic> json) => BodyMetric(
        id: json['id'],
        date: DateTime.parse(json['date']),
        weight: json['weight']?.toDouble(),
        bodyFat: json['bodyFat']?.toDouble(),
        waistCm: json['waistCm']?.toDouble(),
        energyLevel: json['energyLevel'],
        mealNote: json['mealNote'],
        mealTags: List<String>.from(json['mealTags'] ?? []),
      );
}
