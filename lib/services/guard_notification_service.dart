import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Static service that manages the single daily GUARD payment reminder
/// notification. Schedules or cancels using flutter_local_notifications.
///
/// The notification fires once per day at the user-configured time if there
/// are any unpaid active (non-silenced) guarded payments. Silenced payments
/// do not count toward the notification trigger.
class GuardNotificationService {
  static const _channelId = 'guard_reminders';
  static const _notificationId = 0;
  static const _prefHour = 'guard_notify_hour';
  static const _prefMinute = 'guard_notify_minute';
  static const _defaultHour = 9;
  static const _defaultMinute = 0;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _timeZonesInitialized = false;

  static Future<void> initialize() async {
    if (!_timeZonesInitialized) {
      try {
        tz.initializeTimeZones();
        final localTz = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(localTz.identifier));
        _timeZonesInitialized = true;
      } catch (_) {
        // Timezone lookup failed (unsupported device or bad identifier).
        // Notifications will use UTC as a fallback; no crash.
      }
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await _plugin.initialize(initSettings);

    // Request Android 13+ notification permission silently on init.
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<int> getSavedHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefHour) ?? _defaultHour;
  }

  static Future<int> getSavedMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefMinute) ?? _defaultMinute;
  }

  static Future<void> saveTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHour, hour);
    await prefs.setInt(_prefMinute, minute);
  }

  /// Cancels any scheduled GUARD notification.
  static Future<void> cancelAll() async {
    await _plugin.cancel(_notificationId);
  }

  /// Schedules (or cancels) the daily notification based on [unpaidCount].
  ///
  /// If [unpaidCount] is 0, the notification is cancelled.
  /// Otherwise schedules a daily repeating notification at [hour]:[minute].
  static Future<void> scheduleDaily(
      int hour, int minute, int unpaidCount) async {
    try {
      if (unpaidCount == 0) {
        await cancelAll();
        return;
      }

      final body = unpaidCount == 1
          ? '1 guarded payment not confirmed'
          : '$unpaidCount guarded payments not confirmed';

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        'Guard Reminders',
        channelDescription: 'Daily reminders for unconfirmed guarded payments',
        importance: Importance.high,
        priority: Priority.high,
        enableLights: true,
        icon: 'notification_icon',
        largeIcon: const DrawableResourceAndroidBitmap('notification_icon'),
      );
      const darwinDetails = DarwinNotificationDetails();
      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final scheduledDate = _nextInstanceOfTime(hour, minute);

      await _plugin.zonedSchedule(
        _notificationId,
        'GUARD: Payment reminder',
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Exact-alarm permission not granted — notification skipped silently.
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
