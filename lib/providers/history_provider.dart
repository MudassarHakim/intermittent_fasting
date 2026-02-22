import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fasting_session.dart';
import '../services/storage_service.dart';
import '../core/utils.dart';

// ─── History State ────────────────────────────────────────────
class HistoryState {
  final List<FastingSession> sessions;
  final int currentStreak;
  final int longestStreak;
  final int totalFasts;
  final Duration totalFastingTime;
  final Duration averageFastDuration;

  const HistoryState({
    this.sessions = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalFasts = 0,
    this.totalFastingTime = Duration.zero,
    this.averageFastDuration = Duration.zero,
  });
}

// ─── History Notifier ─────────────────────────────────────────
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState()) {
    _loadHistory();
  }

  void _loadHistory() {
    final sessions = StorageService.getHistory();
    _updateState(sessions);
  }

  void addSession(FastingSession session) {
    StorageService.addToHistory(session);
    final sessions = StorageService.getHistory();
    _updateState(sessions);
  }

  void clearHistory() {
    StorageService.clearHistory();
    state = const HistoryState();
  }

  void _updateState(List<FastingSession> sessions) {
    final completed = sessions.where((s) => s.isCompleted).toList();

    final completionDates = completed.map((s) => s.startTime).toList();
    final currentStreak = AppUtils.calculateStreak(completionDates);

    int longestStreak = currentStreak;
    // Calculate longest streak
    if (completionDates.length > 1) {
      final sorted = List<DateTime>.from(completionDates)
        ..sort((a, b) => b.compareTo(a));
      int tempStreak = 1;
      for (int i = 1; i < sorted.length; i++) {
        final diff = DateTime(sorted[i - 1].year, sorted[i - 1].month, sorted[i - 1].day)
            .difference(DateTime(sorted[i].year, sorted[i].month, sorted[i].day))
            .inDays;
        if (diff <= 1) {
          tempStreak++;
          if (tempStreak > longestStreak) longestStreak = tempStreak;
        } else {
          tempStreak = 1;
        }
      }
    }

    final totalTime = completed.fold<Duration>(
      Duration.zero,
      (total, s) => total + s.elapsed,
    );

    final avgDuration = completed.isEmpty
        ? Duration.zero
        : Duration(seconds: totalTime.inSeconds ~/ completed.length);

    state = HistoryState(
      sessions: sessions,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalFasts: completed.length,
      totalFastingTime: totalTime,
      averageFastDuration: avgDuration,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────
final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});
