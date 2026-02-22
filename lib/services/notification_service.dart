import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  static Future<void> scheduleFastComplete({
    required DateTime completionTime,
    required String planName,
  }) async {
    final difference = completionTime.difference(DateTime.now());
    if (difference.isNegative) return;

    final tzCompletionTime = tz.TZDateTime.from(completionTime, tz.local);

    await _plugin.zonedSchedule(
      0,
      '🎉 Fast Complete!',
      'Your $planName fast is done. Great job!',
      tzCompletionTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fasting_timer',
          'Fasting Timer',
          channelDescription: 'Notifications for fasting timer completion',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
