import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../core/utils.dart';
import '../providers/history_provider.dart';
import '../widgets/stat_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Journey',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your fasting progress',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            // ─── Stats Grid ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      title: 'Current Streak',
                      value: '${history.currentStreak}',
                      icon: Icons.local_fire_department_rounded,
                      iconColor: const Color(0xFFFF6B35),
                    ),
                    StatCard(
                      title: 'Longest Streak',
                      value: '${history.longestStreak}',
                      icon: Icons.emoji_events_rounded,
                      iconColor: AppTheme.warning,
                    ),
                    StatCard(
                      title: 'Total Fasts',
                      value: '${history.totalFasts}',
                      icon: Icons.check_circle_rounded,
                      iconColor: AppTheme.success,
                    ),
                    StatCard(
                      title: 'Avg Duration',
                      value: AppUtils.formatDurationShort(history.averageFastDuration),
                      icon: Icons.schedule_rounded,
                      iconColor: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),

            // ─── Calendar Heatmap ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: _WeeklyHeatmap(
                  sessions: history.sessions,
                ),
              ),
            ),

            // ─── Section Title ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Fasts',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${history.sessions.length} total',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Fast Log List ──────────────────────────────
            if (history.sessions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        size: 48,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No fasts yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start your first fast to see your history',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final session = history.sessions[index];
                      return _FastLogItem(
                        planName: session.planName,
                        date: session.startTime,
                        duration: session.elapsed,
                        isCompleted: session.isCompleted,
                        wasCancelled: session.wasCancelled,
                      );
                    },
                    childCount: history.sessions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Weekly Heatmap ───────────────────────────────────────────
class _WeeklyHeatmap extends StatelessWidget {
  final List sessions;

  const _WeeklyHeatmap({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

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
          Text(
            'This Week',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayOffset = today.weekday - 1; // Monday = 0
              final date = today.subtract(Duration(days: dayOffset - index));
              final isToday = AppUtils.isSameDay(date, today);
              final hasFast = sessions.any(
                (s) => s.isCompleted && AppUtils.isSameDay(s.startTime, date),
              );
              final isFuture = date.isAfter(today);

              return Column(
                children: [
                  Text(
                    weekDays[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isToday ? AppTheme.primary : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: hasFast
                          ? AppTheme.success.withValues(alpha: 0.2)
                          : isToday
                              ? AppTheme.primary.withValues(alpha: 0.1)
                              : isFuture
                                  ? Colors.transparent
                                  : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: isToday
                          ? Border.all(color: AppTheme.primary, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: hasFast
                          ? const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: AppTheme.success,
                            )
                          : Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isFuture
                                    ? AppTheme.textMuted.withValues(alpha: 0.3)
                                    : AppTheme.textSecondary,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Fast Log Item ────────────────────────────────────────────
class _FastLogItem extends StatelessWidget {
  final String planName;
  final DateTime date;
  final Duration duration;
  final bool isCompleted;
  final bool wasCancelled;

  const _FastLogItem({
    required this.planName,
    required this.date,
    required this.duration,
    required this.isCompleted,
    required this.wasCancelled,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isCompleted
        ? AppTheme.success
        : wasCancelled
            ? AppTheme.error
            : AppTheme.warning;

    final statusText = isCompleted
        ? 'Completed'
        : wasCancelled
            ? 'Cancelled'
            : 'In Progress';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.textMuted.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : wasCancelled
                      ? Icons.cancel_rounded
                      : Icons.timer_rounded,
              size: 20,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      planName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM d, yyyy · h:mm a').format(date)} · ${AppUtils.formatDurationShort(duration)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
