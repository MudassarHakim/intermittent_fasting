import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fasting_plan.dart';
import '../models/fasting_session.dart';
import '../core/utils.dart';
import '../services/storage_service.dart';
import 'history_provider.dart';

// ─── Timer State ──────────────────────────────────────────────
class TimerState {
  final FastingSession? activeSession;
  final bool isRunning;
  final Duration remaining;
  final Duration elapsed;
  final double progress;
  final bool justCompleted;

  const TimerState({
    this.activeSession,
    this.isRunning = false,
    this.remaining = Duration.zero,
    this.elapsed = Duration.zero,
    this.progress = 0.0,
    this.justCompleted = false,
  });

  TimerState copyWith({
    FastingSession? activeSession,
    bool? isRunning,
    Duration? remaining,
    Duration? elapsed,
    double? progress,
    bool? justCompleted,
  }) {
    return TimerState(
      activeSession: activeSession ?? this.activeSession,
      isRunning: isRunning ?? this.isRunning,
      remaining: remaining ?? this.remaining,
      elapsed: elapsed ?? this.elapsed,
      progress: progress ?? this.progress,
      justCompleted: justCompleted ?? this.justCompleted,
    );
  }
}

// ─── Timer Notifier ───────────────────────────────────────────
class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier(this._ref) : super(const TimerState()) {
    _restoreSession();
  }

  final Ref _ref;
  Timer? _ticker;

  void _restoreSession() {
    final session = StorageService.getActiveSession();
    if (session != null && session.isActive) {
      state = TimerState(
        activeSession: session,
        isRunning: true,
        remaining: session.remaining,
        elapsed: session.elapsed,
        progress: session.progress,
      );
      _startTicker();
    }
  }

  void startFast(FastingPlan plan) {
    _ticker?.cancel();

    final now = DateTime.now();
    final session = FastingSession(
      id: AppUtils.generateId(),
      planId: plan.id,
      planName: plan.shortName,
      fastHours: plan.fastHours,
      startTime: now,
      targetEndTime: now.add(plan.fastDuration),
    );

    StorageService.saveActiveSession(session);

    state = TimerState(
      activeSession: session,
      isRunning: true,
      remaining: session.remaining,
      elapsed: session.elapsed,
      progress: session.progress,
    );

    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final session = state.activeSession;
    if (session == null) return;

    if (session.hasReachedTarget && !state.justCompleted) {
      _completeFast();
      return;
    }

    state = state.copyWith(
      remaining: session.remaining,
      elapsed: session.elapsed,
      progress: session.progress,
    );
  }

  void _completeFast() {
    final session = state.activeSession;
    if (session == null) return;

    session.complete();
    StorageService.clearActiveSession();
    _ref.read(historyProvider.notifier).addSession(session);

    state = state.copyWith(
      activeSession: session,
      isRunning: false,
      remaining: Duration.zero,
      elapsed: session.elapsed,
      progress: 1.0,
      justCompleted: true,
    );

    _ticker?.cancel();
  }

  void cancelFast() {
    final session = state.activeSession;
    if (session == null) return;

    session.cancel();
    StorageService.clearActiveSession();
    _ref.read(historyProvider.notifier).addSession(session);

    _ticker?.cancel();
    state = const TimerState();
  }

  void dismissCompletion() {
    state = const TimerState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

// ─── Provider ─────────────────────────────────────────────────
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});
