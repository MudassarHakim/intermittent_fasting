class FastingSession {
  final String id;
  final String planId;
  final String planName;
  final int fastHours;
  final DateTime startTime;
  final DateTime targetEndTime;
  DateTime? actualEndTime;
  bool isCompleted;
  bool wasCancelled;

  FastingSession({
    required this.id,
    required this.planId,
    required this.planName,
    required this.fastHours,
    required this.startTime,
    required this.targetEndTime,
    this.actualEndTime,
    this.isCompleted = false,
    this.wasCancelled = false,
  });

  Duration get targetDuration => targetEndTime.difference(startTime);

  Duration get elapsed {
    final end = actualEndTime ?? DateTime.now();
    return end.difference(startTime);
  }

  Duration get remaining {
    final diff = targetEndTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  double get progress {
    final total = targetDuration.inSeconds;
    if (total == 0) return 1.0;
    final done = elapsed.inSeconds;
    return (done / total).clamp(0.0, 1.0);
  }

  bool get isActive => !isCompleted && !wasCancelled && actualEndTime == null;

  bool get hasReachedTarget => DateTime.now().isAfter(targetEndTime);

  void complete() {
    actualEndTime = DateTime.now();
    isCompleted = true;
  }

  void cancel() {
    actualEndTime = DateTime.now();
    wasCancelled = true;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'planName': planName,
        'fastHours': fastHours,
        'startTime': startTime.toIso8601String(),
        'targetEndTime': targetEndTime.toIso8601String(),
        'actualEndTime': actualEndTime?.toIso8601String(),
        'isCompleted': isCompleted,
        'wasCancelled': wasCancelled,
      };

  factory FastingSession.fromJson(Map<String, dynamic> json) => FastingSession(
        id: json['id'],
        planId: json['planId'],
        planName: json['planName'],
        fastHours: json['fastHours'],
        startTime: DateTime.parse(json['startTime']),
        targetEndTime: DateTime.parse(json['targetEndTime']),
        actualEndTime: json['actualEndTime'] != null
            ? DateTime.parse(json['actualEndTime'])
            : null,
        isCompleted: json['isCompleted'] ?? false,
        wasCancelled: json['wasCancelled'] ?? false,
      );
}
