import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminders/reminder_planner.dart';

abstract class ReminderNotifier {
  Future<void> init();
  Future<void> requestPermissions();
  Future<void> replaceAll(List<PlannedNotification> items);
}

class NoopNotificationService implements ReminderNotifier {
  @override
  Future<void> init() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> replaceAll(List<PlannedNotification> items) async {}
}

class NotificationService implements ReminderNotifier {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  var _ready = false;

  @override
  Future<void> init() async {
    const android = AndroidInitializationSettings('ic_stat_paw');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    _ready = true;
  }

  @override
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> replaceAll(List<PlannedNotification> items) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    final soonest = [...items]..sort((a, b) => a.when.compareTo(b.when));
    for (final item in soonest.take(60)) {
      try {
        await _plugin.zonedSchedule(
          id: item.id,
          title: item.title,
          body: item.body,
          scheduledDate: tz.TZDateTime.from(item.when, tz.local),
          notificationDetails: _details(item.channel),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: item.channel.name,
          matchDateTimeComponents: item.repeatsDaily
              ? DateTimeComponents.time
              : null,
        );
      } catch (error, stack) {
        debugPrint('通知安排失败：$error\n$stack');
      }
    }
  }

  NotificationDetails _details(ReminderChannel channel) {
    final (id, name) = switch (channel) {
      ReminderChannel.health => ('zhuaji_health', '健康提醒'),
      ReminderChannel.feeding => ('zhuaji_feeding', '喂养提醒'),
      ReminderChannel.food => ('zhuaji_food', '粮仓提醒'),
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(
        id,
        name,
        channelDescription: '爪记的$name',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }
}
