class AppUtils {
  AppUtils._();

  /// Format Duration to HH:MM:SS
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format Duration to short form like "16h 30m"
  static String formatDurationShort(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  /// Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Calculate streak from list of completion dates
  static int calculateStreak(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return 0;

    final sorted = List<DateTime>.from(completionDates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (final date in sorted) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final checkOnly = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final diff = checkOnly.difference(dateOnly).inDays;

      if (diff == 0 || diff == 1) {
        streak++;
        checkDate = dateOnly;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Check if two dates are the same calendar day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
