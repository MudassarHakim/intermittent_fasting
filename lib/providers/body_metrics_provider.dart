import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils.dart';
import '../models/body_metric.dart';
import '../services/storage_service.dart';

class BodyMetricsState {
  final List<BodyMetric> metrics;
  final double? latestWeight;
  final double? latestBodyFat;
  final double? latestWaist;
  final double? weightTrend;

  BodyMetricsState({
    this.metrics = const [],
    this.latestWeight,
    this.latestBodyFat,
    this.latestWaist,
    this.weightTrend,
  });
}

class BodyMetricsNotifier extends StateNotifier<BodyMetricsState> {
  BodyMetricsNotifier() : super(BodyMetricsState()) {
    _load();
  }

  void _load() {
    final metrics = StorageService.getBodyMetrics();
    _updateState(metrics);
  }

  Future<void> addMetric(BodyMetric metric) async {
    await StorageService.addBodyMetric(metric);
    final metrics = StorageService.getBodyMetrics();
    _updateState(metrics);
  }

  Future<void> logWeight(double weight) async {
    final metric = BodyMetric(
      id: AppUtils.generateId(),
      date: DateTime.now(),
      weight: weight,
    );
    await addMetric(metric);
  }

  Future<void> logBodyComposition({
    double? weight,
    double? bodyFat,
    double? waistCm,
  }) async {
    final metric = BodyMetric(
      id: AppUtils.generateId(),
      date: DateTime.now(),
      weight: weight,
      bodyFat: bodyFat,
      waistCm: waistCm,
    );
    await addMetric(metric);
  }

  Future<void> logEnergyLevel(int level) async {
    final metric = BodyMetric(
      id: AppUtils.generateId(),
      date: DateTime.now(),
      energyLevel: level,
    );
    await addMetric(metric);
  }

  Future<void> logMeal({String? note, List<String> tags = const []}) async {
    final metric = BodyMetric(
      id: AppUtils.generateId(),
      date: DateTime.now(),
      mealNote: note,
      mealTags: tags,
    );
    await addMetric(metric);
  }

  void _updateState(List<BodyMetric> metrics) {
    final weights = metrics.where((m) => m.weight != null).toList();
    final bodyFats = metrics.where((m) => m.bodyFat != null).toList();
    final waists = metrics.where((m) => m.waistCm != null).toList();

    double? trend;
    if (weights.length >= 2) {
      trend = weights.first.weight! - weights[1].weight!;
    }

    state = BodyMetricsState(
      metrics: metrics,
      latestWeight: weights.isNotEmpty ? weights.first.weight : null,
      latestBodyFat: bodyFats.isNotEmpty ? bodyFats.first.bodyFat : null,
      latestWaist: waists.isNotEmpty ? waists.first.waistCm : null,
      weightTrend: trend,
    );
  }

  Future<void> clear() async {
    await StorageService.clearBodyMetrics();
    state = BodyMetricsState();
  }
}

final bodyMetricsProvider =
    StateNotifierProvider<BodyMetricsNotifier, BodyMetricsState>(
  (ref) => BodyMetricsNotifier(),
);
