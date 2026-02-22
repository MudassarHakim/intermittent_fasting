class FastingPlan {
  final String id;
  final String name;
  final String shortName;
  final int fastHours;
  final int eatHours;
  final String description;
  final String emoji;
  final bool isPremium;

  const FastingPlan({
    required this.id,
    required this.name,
    required this.shortName,
    required this.fastHours,
    required this.eatHours,
    required this.description,
    required this.emoji,
    this.isPremium = false,
  });

  Duration get fastDuration => Duration(hours: fastHours);
  Duration get eatDuration => Duration(hours: eatHours);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'fastHours': fastHours,
        'eatHours': eatHours,
        'description': description,
        'emoji': emoji,
        'isPremium': isPremium,
      };

  factory FastingPlan.fromJson(Map<String, dynamic> json) => FastingPlan(
        id: json['id'],
        name: json['name'],
        shortName: json['shortName'],
        fastHours: json['fastHours'],
        eatHours: json['eatHours'],
        description: json['description'],
        emoji: json['emoji'],
        isPremium: json['isPremium'] ?? false,
      );
}
