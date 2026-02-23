import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../app/theme.dart';
import '../core/utils.dart';
import '../providers/timer_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/circular_progress.dart';
import '../widgets/fasting_share_card.dart';
import '../core/constants.dart';
import '../core/metabolic_phases.dart';
import '../providers/settings_provider.dart';
import '../widgets/metabolic_timeline.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  late ConfettiController _confettiController;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final history = ref.watch(historyProvider);

    // Trigger confetti on completion
    ref.listen<TimerState>(timerProvider, (previous, next) {
      if (next.justCompleted && !(previous?.justCompleted ?? false)) {
        _confettiController.play();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            if (timerState.justCompleted)
              _CompletionView(
                session: timerState.activeSession!,
                streak: history.currentStreak,
                screenshotController: _screenshotController,
                onDismiss: () {
                  ref.read(timerProvider.notifier).dismissCompletion();
                },
                onShare: () => _shareCard(context, timerState, history.currentStreak),
              )
            else if (timerState.isRunning)
              _ActiveTimerView(
                timerState: timerState,
                showMetabolicPhases: ref.watch(settingsProvider).showMetabolicPhases,
                fastingGoal: ref.watch(settingsProvider).fastingGoal,
                onCancel: () => _showCancelDialog(context, ref),
              )
            else
              _IdleView(),

            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppTheme.primary,
                  AppTheme.secondary,
                  AppTheme.accent,
                  AppTheme.warning,
                  AppTheme.success,
                ],
                numberOfParticles: 30,
                gravity: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareCard(BuildContext context, TimerState timerState, int streak) async {
    try {
      final widget = MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Scaffold(
          backgroundColor: AppTheme.background,
          body: Center(
            child: FastingShareCard(
              session: timerState.activeSession!,
              streak: streak,
            ),
          ),
        ),
      );

      final image = await _screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 100),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/fasting_card.png');
      await file.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Just completed my ${timerState.activeSession!.planName} fast! 🎉💪',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share: $e')),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Fast Early?'),
        content: const Text(
          'Your progress will be saved but this fast won\'t count as completed.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Going 💪'),
          ),
          TextButton(
            onPressed: () {
              ref.read(timerProvider.notifier).cancelFast();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('End Fast'),
          ),
        ],
      ),
    );
  }
}

// ─── Active Timer View ────────────────────────────────────────
class _ActiveTimerView extends StatelessWidget {
  final TimerState timerState;
  final bool showMetabolicPhases;
  final String fastingGoal;
  final VoidCallback onCancel;

  const _ActiveTimerView({
    required this.timerState,
    required this.showMetabolicPhases,
    required this.fastingGoal,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final session = timerState.activeSession!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Plan label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.fasting.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.fasting,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Fasting · ${session.planName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.fasting,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Circular progress
          CircularProgress(
            progress: timerState.progress,
            size: 240,
            strokeWidth: 14,
            gradientColors: const [
              AppTheme.primary,
              AppTheme.accent,
              AppTheme.secondary,
            ],
            child: Builder(
              builder: (context) {
                final phase = MetabolicPhases.getCurrentPhase(timerState.elapsed);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppUtils.formatDuration(timerState.remaining),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'remaining',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    if (showMetabolicPhases) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: phase.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              phase.icon,
                              size: 14,
                              color: phase.color,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              phase.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: phase.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          Text(
            '${AppUtils.formatDurationShort(timerState.elapsed)} elapsed · ${(timerState.progress * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Metabolic Timeline ─────────────────────────
          if (showMetabolicPhases) ...[
            MetabolicTimeline(
              elapsed: timerState.elapsed,
              targetHours: session.fastHours,
            ),
            const SizedBox(height: 24),
          ],

          // ─── Goal Tip ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.textMuted.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getGoalIcon(fastingGoal),
                    size: 18,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGoalLabel(fastingGoal),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppConstants.goalTimerTips[fastingGoal] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // End Fast button
          OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.stop_rounded),
            label: const Text('End Fast'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.error,
              side: BorderSide(color: AppTheme.error.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'fat_loss':
        return Icons.whatshot_rounded;
      case 'autophagy':
        return Icons.auto_fix_high_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }

  String _getGoalLabel(String goal) {
    switch (goal) {
      case 'fat_loss':
        return 'FAT LOSS TIP';
      case 'autophagy':
        return 'AUTOPHAGY TIP';
      default:
        return 'HEALTH TIP';
    }
  }
}

// ─── Completion View ──────────────────────────────────────────
class _CompletionView extends StatelessWidget {
  final dynamic session;
  final int streak;
  final ScreenshotController screenshotController;
  final VoidCallback onDismiss;
  final VoidCallback onShare;

  const _CompletionView({
    required this.session,
    required this.streak,
    required this.screenshotController,
    required this.onDismiss,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            '🎉',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            'Fast Complete!',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Amazing work! You did it! 💪',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          // Share card preview
          Screenshot(
            controller: screenshotController,
            child: FastingShareCard(session: session, streak: streak),
          ),
          const SizedBox(height: 32),

          // Ad placeholder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.textMuted.withValues(alpha: 0.1),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.ad_units_rounded,
                  color: AppTheme.textMuted,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Interstitial Ad Placeholder',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Share button
          GestureDetector(
            onTap: onShare,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Share Your Achievement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Done button
          TextButton(
            onPressed: onDismiss,
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 16),

          // Registration prompt
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.person_add_rounded,
                  color: AppTheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a free account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sync your progress across devices',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/register');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Register Now'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Idle View ────────────────────────────────────────────────
class _IdleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceCard,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timer_outlined,
                size: 64,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Fast',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a plan and start fasting from the Home tab.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
