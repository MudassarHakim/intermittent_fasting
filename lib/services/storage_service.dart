import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/body_metric.dart';
import '../models/fasting_session.dart';
import '../models/user_settings.dart';

class StorageService {
  static late Box _settingsBox;
  static late Box _sessionsBox;
  static late Box _activeBox;
  static late Box _metricsBox;

  static const String _settingsBoxName = 'settings';
  static const String _sessionsBoxName = 'sessions';
  static const String _activeBoxName = 'active_session';
  static const String _metricsBoxName = 'body_metrics';

  static Future<void> init() async {
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _sessionsBox = await Hive.openBox(_sessionsBoxName);
    _activeBox = await Hive.openBox(_activeBoxName);
    _metricsBox = await Hive.openBox(_metricsBoxName);
  }

  // ─── User Settings ─────────────────────────────────────────
  static UserSettings getSettings() {
    final data = _settingsBox.get('user_settings');
    if (data == null) return UserSettings();
    return UserSettings.fromJson(Map<String, dynamic>.from(jsonDecode(data)));
  }

  static Future<void> saveSettings(UserSettings settings) async {
    await _settingsBox.put('user_settings', jsonEncode(settings.toJson()));
  }

  // ─── Active Session ────────────────────────────────────────
  static FastingSession? getActiveSession() {
    final data = _activeBox.get('current_session');
    if (data == null) return null;
    return FastingSession.fromJson(Map<String, dynamic>.from(jsonDecode(data)));
  }

  static Future<void> saveActiveSession(FastingSession session) async {
    await _activeBox.put('current_session', jsonEncode(session.toJson()));
  }

  static Future<void> clearActiveSession() async {
    await _activeBox.delete('current_session');
  }

  // ─── Session History ───────────────────────────────────────
  static List<FastingSession> getHistory() {
    final data = _sessionsBox.get('history');
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list
        .map((e) => FastingSession.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> addToHistory(FastingSession session) async {
    final history = getHistory();
    history.insert(0, session);
    // Keep only last 365 sessions
    if (history.length > 365) {
      history.removeRange(365, history.length);
    }
    await _sessionsBox.put('history', jsonEncode(history.map((e) => e.toJson()).toList()));
  }

  static Future<void> clearHistory() async {
    await _sessionsBox.delete('history');
  }

  // ─── Body Metrics ──────────────────────────────────────────
  static List<BodyMetric> getBodyMetrics() {
    final data = _metricsBox.get('metrics');
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list
        .map((e) => BodyMetric.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> addBodyMetric(BodyMetric metric) async {
    final metrics = getBodyMetrics();
    metrics.insert(0, metric);
    if (metrics.length > 365) {
      metrics.removeRange(365, metrics.length);
    }
    await _metricsBox.put(
        'metrics', jsonEncode(metrics.map((e) => e.toJson()).toList()));
  }

  static Future<void> clearBodyMetrics() async {
    await _metricsBox.delete('metrics');
  }
}
