import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminders/reminder_planner.dart';

abstract class ReminderNotifier {
  Future<void> init();
  Future<void> requestPermissions({bool askExactAlarm = true});
  Future<void> replaceAll(List<PlannedNotification> items);
}

class NoopNotificationService implements ReminderNotifier {
  @override
  Future<void> init() async {}

  @override
  Future<void> requestPermissions({bool askExactAlarm = true}) async {}

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

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> requestPermissions({bool askExactAlarm = true}) async {
    await _android?.requestNotificationsPermission();
    final exact = await _android?.canScheduleExactNotifications();
    if (askExactAlarm && exact == false) {
      await _android?.requestExactAlarmsPermission();
    }
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> replaceAll(List<PlannedNotification> items) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (error, stack) {
      debugPrint('清除旧提醒失败，继续安排新的：$error\n$stack');
    }
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    final mode = exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    final soonest = schedulable(items, DateTime.now());
    for (final item in soonest) {
      final scheduled = await _schedule(item, mode);
      if (!scheduled && mode != AndroidScheduleMode.inexactAllowWhileIdle) {
        await _schedule(item, AndroidScheduleMode.inexactAllowWhileIdle);
      }
    }
  }

  Future<bool> _schedule(
    PlannedNotification item,
    AndroidScheduleMode mode,
  ) async {
    try {
      await _plugin.zonedSchedule(
        id: item.id,
        title: item.title,
        body: item.body,
        scheduledDate: tz.TZDateTime.from(item.when, tz.local),
        notificationDetails: _details(item.channel),
        androidScheduleMode: mode,
        payload: item.channel.name,
        matchDateTimeComponents: item.repeatsDaily
            ? DateTimeComponents.time
            : null,
      );
      return true;
    } catch (error, stack) {
      debugPrint('通知安排失败：$error\n$stack');
      return false;
    }
  }

  NotificationDetails _details(ReminderChannel channel) {
    final (id, name) = switch (channel) {
      ReminderChannel.health => ('zhuaji_health', '健康提醒'),
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
