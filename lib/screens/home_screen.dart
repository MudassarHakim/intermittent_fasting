import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../providers/timer_provider.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/health_disclaimer.dart';
import '../widgets/insight_card.dart';
import '../widgets/plan_card.dart';
import '../widgets/streak_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final timerState = ref.watch(timerProvider);
    final history = ref.watch(historyProvider);

    if (!settings.hasAcceptedDisclaimer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HealthDisclaimer.show(context, () {
          ref.read(settingsProvider.notifier).acceptDisclaimer();
        });
      });
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppUtils.getGreeting(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to fast? 💪',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 16),
                    StreakBadge(streak: history.currentStreak),
                  ],
                ),
              ),
            ),

            // ─── Active Fast Banner ─────────────────────────
            if (timerState.isRunning)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: GestureDetector(
                    onTap: () => context.go('/timer'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.timer_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fast in Progress',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${AppUtils.formatDuration(timerState.remaining)} remaining',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ─── Daily Insight ───────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: InsightCard(),
              ),
            ),

            // ─── Section Title ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Text(
                  'Choose Your Plan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),

            // ─── Plan Cards ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final plan = AppConstants.fastingPlans[index];
                    final isSelected = plan.id == settings.selectedPlanId;
                    final isLocked = plan.isPremium && !settings.isPremium;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PlanCard(
                        plan: plan,
                        isSelected: isSelected,
                        isLocked: isLocked,
                        onTap: () {
                          if (isLocked) {
                            _showPremiumDialog(context);
                            return;
                          }
                          ref.read(settingsProvider.notifier).updatePlan(plan.id);
                        },
                      ),
                    );
                  },
                  childCount: AppConstants.fastingPlans.length,
                ),
              ),
            ),

            // ─── Start Fast Button ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: _StartFastButton(
                  isActive: timerState.isRunning,
                  onPressed: () {
                    if (timerState.isRunning) {
                      context.go('/timer');
                    } else {
                      final plan = AppConstants.getPlanById(settings.selectedPlanId);
                      ref.read(timerProvider.notifier).startFast(plan);
                      context.go('/timer');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🔒 Premium Plan'),
        content: const Text(
          'Unlock advanced fasting plans, detailed stats, widgets, and remove ads with Premium.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // IAP integration placeholder
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class _StartFastButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;

  const _StartFastButton({
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.successGradient : AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppTheme.secondary : AppTheme.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.visibility_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              isActive ? 'View Active Fast' : 'Start Fasting',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
