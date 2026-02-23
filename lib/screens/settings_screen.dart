import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/theme.dart';
import '../providers/ramadan_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/history_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Customize your experience',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),

            // ─── Premium Banner ────────────────────────────
            if (!settings.isPremium)
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('👑', style: TextStyle(fontSize: 28)),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upgrade to Premium',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Unlock all plans, stats & widgets',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // IAP placeholder
                          _showIAPDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'View Plans',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ─── Preferences ───────────────────────────────
            const _SectionTitle(title: 'Preferences'),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              subtitle: 'Get reminded when your fast ends',
              trailing: Switch(
                value: settings.notificationsEnabled,
                onChanged: (_) {
                  ref.read(settingsProvider.notifier).toggleNotifications();
                },
                activeThumbColor: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            // ─── Rewarded Ad Placeholder ────────────────────
            _SettingsTile(
              icon: Icons.play_circle_filled_rounded,
              title: 'Watch Ad to Unlock Plan',
              subtitle: 'Get free access to one premium plan',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.success,
                  ),
                ),
              ),
              onTap: () {
                // Rewarded ad placeholder
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rewarded ad placeholder — would show ad here'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ─── Science & Insights ────────────────────────
            const _SectionTitle(title: 'Science & Insights'),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.science_rounded,
              title: 'Metabolic Phases',
              subtitle: 'Show metabolic phase timeline on timer',
              trailing: Switch(
                value: settings.showMetabolicPhases,
                onChanged: (_) {
                  ref.read(settingsProvider.notifier).toggleMetabolicPhases();
                },
                activeThumbColor: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.emoji_events_rounded,
              title: 'Milestone Alerts',
              subtitle: 'Notify at metabolic milestones during fasts',
              trailing: Switch(
                value: settings.milestoneNotifications,
                onChanged: (_) {
                  ref
                      .read(settingsProvider.notifier)
                      .toggleMilestoneNotifications();
                },
                activeThumbColor: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            _RamadanModeTile(
              isEnabled: settings.ramadanModeEnabled,
              onToggle: () async {
                if (!settings.ramadanModeEnabled) {
                  await ref.read(ramadanProvider.notifier).loadTimes();
                  final state = ref.read(ramadanProvider);
                  if (state.error != null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error!)),
                      );
                    }
                    return;
                  }
                }
                ref.read(settingsProvider.notifier).toggleRamadanMode();
              },
            ),
            const SizedBox(height: 24),

            // ─── Fasting Goal ──────────────────────────────
            const _SectionTitle(title: 'Fasting Goal'),
            const SizedBox(height: 12),

            _GoalSelector(
              currentGoal: settings.fastingGoal,
              onGoalChanged: (goal) {
                ref.read(settingsProvider.notifier).setFastingGoal(goal);
              },
            ),
            const SizedBox(height: 24),

            // ─── Tracking ──────────────────────────────────
            const _SectionTitle(title: 'Tracking'),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.monitor_weight_rounded,
              title: 'Body Metrics',
              subtitle: 'Track weight, body fat, and measurements',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
              ),
              onTap: () => context.push('/body-metrics'),
            ),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.restaurant_menu_rounded,
              title: 'Meal Journal',
              subtitle: 'Log post-fast meals and quality',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
              ),
              onTap: () => context.push('/meal-journal'),
            ),
            const SizedBox(height: 24),

            // ─── Data ──────────────────────────────────────
            const _SectionTitle(title: 'Data'),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.delete_outline_rounded,
              title: 'Clear History',
              subtitle: 'Remove all fasting records',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
              ),
              onTap: () => _showClearDialog(context, ref),
            ),
            const SizedBox(height: 24),

            // ─── About ─────────────────────────────────────
            const _SectionTitle(title: 'About'),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.health_and_safety_rounded,
              title: 'Health Disclaimer',
              subtitle: 'View our health and safety notice',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppTheme.surfaceCard,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Health Disclaimer',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        const Text(
                          'This app is for informational and tracking purposes only. '
                          'It does not provide medical advice, diagnosis, or treatment. '
                          'Always consult a healthcare professional before starting any fasting regimen.',
                          style: TextStyle(
                              color: AppTheme.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got It'),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            const _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'Version',
              subtitle: '1.0.0',
              trailing: SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.code_rounded,
              title: 'Created by Mudassar Hakim',
              subtitle: 'mudassarhakim.com',
              trailing: const Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: AppTheme.textMuted,
              ),
              onTap: () {
                _launchUrl('https://mudassarhakim.com');
              },
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              trailing: const Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: AppTheme.textMuted,
              ),
              onTap: () {
                // Open privacy policy
              },
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.star_rounded,
              title: 'Rate the App',
              subtitle: 'Help us with a review!',
              trailing: const Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: AppTheme.textMuted,
              ),
              onTap: () {
                // Open store listing
              },
            ),
            const SizedBox(height: 40),

            // Remove Ads button
            if (!settings.isPremium)
              OutlinedButton.icon(
                onPressed: () => _showIAPDialog(context),
                icon: const Icon(Icons.block_rounded),
                label: const Text('Remove Ads'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  side: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showIAPDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('👑 Premium Plans'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IAPOption(
              title: 'Monthly',
              price: '\$2.99/mo',
              isPopular: false,
            ),
            SizedBox(height: 8),
            _IAPOption(
              title: 'Yearly',
              price: '\$19.99/yr',
              isPopular: true,
            ),
            SizedBox(height: 8),
            _IAPOption(
              title: 'Lifetime',
              price: '\$49.99',
              isPopular: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History?'),
        content: const Text(
          'This will permanently delete all your fasting records. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppTheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ─── IAP Option ───────────────────────────────────────────────
class _IAPOption extends StatelessWidget {
  final String title;
  final String price;
  final bool isPopular;

  const _IAPOption({
    required this.title,
    required this.price,
    required this.isPopular,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPopular
            ? AppTheme.primary.withValues(alpha: 0.1)
            : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPopular
              ? AppTheme.primary.withValues(alpha: 0.4)
              : AppTheme.textMuted.withValues(alpha: 0.1),
          width: isPopular ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (isPopular) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'BEST VALUE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isPopular ? AppTheme.primary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Goal Selector ──────────────────────────────────────────
class _GoalSelector extends StatelessWidget {
  final String currentGoal;
  final ValueChanged<String> onGoalChanged;

  const _GoalSelector({
    required this.currentGoal,
    required this.onGoalChanged,
  });

  static const _goals = [
    {'id': 'fat_loss', 'label': 'Fat Loss', 'icon': Icons.whatshot_rounded},
    {
      'id': 'metabolic_health',
      'label': 'Metabolic Health',
      'icon': Icons.favorite_rounded,
    },
    {
      'id': 'autophagy',
      'label': 'Autophagy',
      'icon': Icons.auto_fix_high_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _goals.map((goal) {
        final isSelected = currentGoal == goal['id'];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: goal != _goals.last ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => onGoalChanged(goal['id'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.12)
                      : AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.5)
                        : AppTheme.textMuted.withValues(alpha: 0.1),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      goal['icon'] as IconData,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textMuted,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      goal['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Ramadan Mode Tile ────────────────────────────────────────
class _RamadanModeTile extends ConsumerWidget {
  final bool isEnabled;
  final VoidCallback onToggle;

  const _RamadanModeTile({
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ramadanState = ref.watch(ramadanProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: isEnabled
            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppTheme.primary.withValues(alpha: 0.12)
                      : AppTheme.textMuted.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.mosque_rounded,
                  color: isEnabled ? AppTheme.primary : AppTheme.textMuted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ramadan Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnabled
                          ? 'Fajr to Maghrib based on location'
                          : 'Auto-calculate fasting windows',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (ramadanState.isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch(
                  value: isEnabled,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: AppTheme.primary,
                ),
            ],
          ),
          if (isEnabled && ramadanState.times != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TimeColumn(
                      label: 'Suhoor Ends',
                      time: _formatTime(ramadanState.times!.suhoorEnd),
                      icon: Icons.wb_twilight_rounded,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.textMuted.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _TimeColumn(
                      label: 'Iftar Starts',
                      time: _formatTime(ramadanState.times!.iftarStart),
                      icon: Icons.nights_stay_rounded,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.textMuted.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _TimeColumn(
                      label: 'Duration',
                      time: '${ramadanState.times!.fastingDuration.inHours}h ${ramadanState.times!.fastingDuration.inMinutes.remainder(60)}m',
                      icon: Icons.timer_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;

  const _TimeColumn({
    required this.label,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
