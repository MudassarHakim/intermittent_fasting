import 'package:flutter/material.dart';
import '../app/theme.dart';

class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: streak > 0
            ? const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF4444)],
              )
            : null,
        color: streak == 0 ? AppTheme.surfaceCard : null,
        borderRadius: BorderRadius.circular(30),
        boxShadow: streak > 0
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            streak > 0 ? '🔥' : '💤',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            streak > 0 ? '$streak day streak!' : 'No streak yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: streak > 0 ? Colors.white : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
