import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../core/utils.dart';
import '../models/fasting_session.dart';

class FastingShareCard extends StatelessWidget {
  final FastingSession session;
  final int streak;

  const FastingShareCard({
    super.key,
    required this.session,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timer_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Fasting Timer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Completion badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppTheme.success,
                ),
                SizedBox(width: 6),
                Text(
                  'Fast Completed!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Plan name
          Text(
            '${session.planName} Plan',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Duration
          Text(
            AppUtils.formatDurationShort(session.elapsed),
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
            ),
          ),
          const SizedBox(height: 20),

          // Streak & Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ShareStatChip(
                emoji: '🔥',
                label: '$streak day streak',
              ),
              const SizedBox(width: 12),
              _ShareStatChip(
                emoji: '⏱',
                label: '${session.fastHours}h fasted',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fasting window
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _WindowIndicator(
                  color: AppTheme.fasting,
                  label: 'Started',
                  time: _formatTime(session.startTime),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                ),
                _WindowIndicator(
                  color: AppTheme.eating,
                  label: 'Ended',
                  time: _formatTime(session.actualEndTime ?? DateTime.now()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour > 12 ? time.hour - 12 : time.hour;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

class _ShareStatChip extends StatelessWidget {
  final String emoji;
  final String label;

  const _ShareStatChip({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowIndicator extends StatelessWidget {
  final Color color;
  final String label;
  final String time;

  const _WindowIndicator({
    required this.color,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
