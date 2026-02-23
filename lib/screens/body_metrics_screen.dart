import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../providers/body_metrics_provider.dart';
import '../core/utils.dart';

class BodyMetricsScreen extends ConsumerWidget {
  const BodyMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsState = ref.watch(bodyMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Body Metrics'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            // ─── Header ─────────────────────────────────────
            Text(
              'Track your progress',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // ─── Stat Cards ─────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _MetricStatCard(
                    label: 'Weight',
                    value: metricsState.latestWeight != null
                        ? '${metricsState.latestWeight!.toStringAsFixed(1)} kg'
                        : '—',
                    icon: Icons.monitor_weight_rounded,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricStatCard(
                    label: 'Body Fat',
                    value: metricsState.latestBodyFat != null
                        ? '${metricsState.latestBodyFat!.toStringAsFixed(1)}%'
                        : '—',
                    icon: Icons.pie_chart_rounded,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricStatCard(
                    label: 'Waist',
                    value: metricsState.latestWaist != null
                        ? '${metricsState.latestWaist!.toStringAsFixed(1)} cm'
                        : '—',
                    icon: Icons.straighten_rounded,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── Weight Trend Chart ─────────────────────────
            _WeightTrendChart(metrics: metricsState.metrics),
            const SizedBox(height: 24),

            // ─── Energy Level Section ───────────────────────
            _EnergyLevelSection(metrics: metricsState.metrics),
            const SizedBox(height: 24),

            // ─── Recent Entries ─────────────────────────────
            Text(
              'Recent Entries',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (metricsState.metrics.isEmpty)
              _EmptyState()
            else
              ...metricsState.metrics
                  .where((m) =>
                      m.weight != null ||
                      m.bodyFat != null ||
                      m.waistCm != null)
                  .take(10)
                  .map((m) => _RecentEntryItem(metric: m)),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogDialog(context, ref),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Log Measurement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showLogDialog(BuildContext context, WidgetRef ref) {
    final weightController = TextEditingController();
    final bodyFatController = TextEditingController();
    final waistController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Measurement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InputField(
              controller: weightController,
              label: 'Weight (kg)',
              icon: Icons.monitor_weight_rounded,
            ),
            const SizedBox(height: 12),
            _InputField(
              controller: bodyFatController,
              label: 'Body Fat (%)',
              icon: Icons.pie_chart_rounded,
            ),
            const SizedBox(height: 12),
            _InputField(
              controller: waistController,
              label: 'Waist (cm)',
              icon: Icons.straighten_rounded,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              final bodyFat = double.tryParse(bodyFatController.text);
              final waist = double.tryParse(waistController.text);

              if (weight == null && bodyFat == null && waist == null) return;

              ref.read(bodyMetricsProvider.notifier).logBodyComposition(
                    weight: weight,
                    bodyFat: bodyFat,
                    waistCm: waist,
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ─── Metric Stat Card ─────────────────────────────────────────
class _MetricStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textMuted.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weight Trend Chart ───────────────────────────────────────
class _WeightTrendChart extends StatelessWidget {
  final List metrics;

  const _WeightTrendChart({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final weightEntries = metrics
        .where((m) =>
            m.weight != null && m.date.isAfter(thirtyDaysAgo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

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
            'Weight Trend',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Last 30 days',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: weightEntries.length < 2
                ? const Center(
                    child: Text(
                      'Log at least 2 weights to see trends',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  )
                : _buildChart(weightEntries, thirtyDaysAgo),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List weightEntries, DateTime thirtyDaysAgo) {
    final spots = weightEntries.map((m) {
      final dayIndex =
          m.date.difference(thirtyDaysAgo).inHours / 24.0;
      return FlSpot(dayIndex, m.weight!);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 1;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 4).clamp(0.5, 10),
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.textMuted.withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 7,
              getTitlesWidget: (value, meta) {
                final date =
                    thirtyDaysAgo.add(Duration(hours: (value * 24).round()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('d/M').format(date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppTheme.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: AppTheme.primary,
                strokeWidth: 1.5,
                strokeColor: AppTheme.surfaceCard,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppTheme.surface,
            getTooltipItems: (spots) => spots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} kg',
                const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Energy Level Section ─────────────────────────────────────
class _EnergyLevelSection extends StatelessWidget {
  final List metrics;

  const _EnergyLevelSection({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final energyEntries = metrics
        .where((m) => m.energyLevel != null)
        .take(7)
        .toList();

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
            'Energy Levels',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Recent check-ins',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          if (energyEntries.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No energy check-ins yet',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: energyEntries.map((entry) {
                final level = entry.energyLevel!;
                final barHeight = (level / 10.0) * 60.0;
                final color = level >= 7
                    ? AppTheme.success
                    : level >= 4
                        ? AppTheme.warning
                        : AppTheme.error;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 20,
                              height: barHeight.clamp(4.0, 60.0),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('E').format(entry.date).substring(0, 2),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

// ─── Recent Entry Item ────────────────────────────────────────
class _RecentEntryItem extends StatelessWidget {
  final dynamic metric;

  const _RecentEntryItem({required this.metric});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (metric.weight != null) parts.add('${metric.weight!.toStringAsFixed(1)} kg');
    if (metric.bodyFat != null) parts.add('${metric.bodyFat!.toStringAsFixed(1)}% BF');
    if (metric.waistCm != null) parts.add('${metric.waistCm!.toStringAsFixed(1)} cm');

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
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.monitor_weight_rounded,
              size: 20,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parts.join(' · '),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppUtils.isSameDay(metric.date, DateTime.now())
                      ? 'Today · ${DateFormat('h:mm a').format(metric.date)}'
                      : DateFormat('MMM d, yyyy · h:mm a').format(metric.date),
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

// ─── Input Field ──────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted),
        prefixIcon: Icon(icon, size: 20, color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.textMuted.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.monitor_weight_rounded,
            size: 48,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'No measurements yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the button below to log your first entry',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}
