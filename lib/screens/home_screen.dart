import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../models/fasting_plan.dart';
import '../providers/ramadan_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ramadan_service.dart';
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: InsightCard(goal: settings.fastingGoal),
              ),
            ),

            // ─── Ramadan Mode Banner ────────────────────────
            if (settings.ramadanModeEnabled)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: _RamadanBanner(ref: ref),
                ),
              ),

            // ─── Section Title ──────────────────────────────
            if (!settings.ramadanModeEnabled)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: Text(
                    'Choose Your Plan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),

            // ─── Goal Recommendation Banner ────────────────
            if (!settings.ramadanModeEnabled)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.success.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates_rounded,
                          size: 18,
                          color: AppTheme.success.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppConstants.goalDescriptions[settings.fastingGoal] ??
                                '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ─── Plan Cards ─────────────────────────────────
            if (!settings.ramadanModeEnabled)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final plan = AppConstants.fastingPlans[index];
                      final isSelected = plan.id == settings.selectedPlanId;
                      final isRecommended = AppConstants.isPlanRecommendedForGoal(
                        plan.id,
                        settings.fastingGoal,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PlanCard(
                          plan: plan,
                          isSelected: isSelected,
                          isLocked: false,
                          isRecommended: isRecommended,
                          onTap: () {
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
                  isRamadanMode: settings.ramadanModeEnabled,
                  onPressed: () async {
                    if (timerState.isRunning) {
                      context.go('/timer');
                    } else if (settings.ramadanModeEnabled) {
                      var ramadanState = ref.read(ramadanProvider);
                      
                      // Load times if not already loaded
                      if (ramadanState.times == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Getting prayer times for your location...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        await ref.read(ramadanProvider.notifier).loadTimes();
                        ramadanState = ref.read(ramadanProvider);
                      }
                      
                      if (ramadanState.times != null) {
                        final times = ramadanState.times!;
                        final ramadanPlan = FastingPlan(
                          id: 'ramadan',
                          name: 'Ramadan Fast',
                          shortName: 'Ramadan',
                          fastHours: times.fastingDuration.inHours,
                          eatHours: 24 - times.fastingDuration.inHours,
                          description: 'Fajr to Maghrib',
                          emoji: '🌙',
                        );
                        ref.read(timerProvider.notifier).startFast(ramadanPlan);
                        if (context.mounted) context.go('/timer');
                      } else if (ramadanState.error != null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ramadanState.error!),
                              backgroundColor: AppTheme.error,
                            ),
                          );
                        }
                      }
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

}

class _StartFastButton extends StatelessWidget {
  final bool isActive;
  final bool isRamadanMode;
  final VoidCallback onPressed;

  const _StartFastButton({
    required this.isActive,
    this.isRamadanMode = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isActive
        ? AppTheme.successGradient
        : (isRamadanMode
            ? const LinearGradient(
                colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
              )
            : AppTheme.primaryGradient);

    final buttonColor = isActive
        ? AppTheme.secondary
        : (isRamadanMode ? const Color(0xFF2D5A87) : AppTheme.primary);

    final buttonText = isActive
        ? 'View Active Fast'
        : (isRamadanMode ? 'Start Ramadan Fast' : 'Start Fasting');

    final buttonIcon = isActive
        ? Icons.visibility_rounded
        : (isRamadanMode ? Icons.mosque_rounded : Icons.play_arrow_rounded);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(buttonIcon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              buttonText,
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

// ─── Ramadan Banner ───────────────────────────────────────────
class _RamadanBanner extends StatelessWidget {
  final WidgetRef ref;

  const _RamadanBanner({required this.ref});

  @override
  Widget build(BuildContext context) {
    final ramadanState = ref.watch(ramadanProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ramadan Mode Active 🌙',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Fasting from Fajr to Maghrib',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (ramadanState.isLoading) ...[
            const SizedBox(height: 16),
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
            ),
          ] else if (ramadanState.times != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _RamadanTimeColumn(
                      label: 'Suhoor Ends',
                      time: RamadanService.formatTime(ramadanState.times!.suhoorEnd),
                      icon: Icons.wb_twilight_rounded,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.white24,
                  ),
                  Expanded(
                    child: _RamadanTimeColumn(
                      label: 'Iftar Starts',
                      time: RamadanService.formatTime(ramadanState.times!.iftarStart),
                      icon: Icons.nights_stay_rounded,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.white24,
                  ),
                  Expanded(
                    child: _RamadanTimeColumn(
                      label: 'Duration',
                      time:
                          '${ramadanState.times!.fastingDuration.inHours}h ${ramadanState.times!.fastingDuration.inMinutes.remainder(60)}m',
                      icon: Icons.timer_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (ramadanState.error != null) ...[
            const SizedBox(height: 16),
            Text(
              ramadanState.error!,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RamadanTimeColumn extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;

  const _RamadanTimeColumn({
    required this.label,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(height: 6),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}
