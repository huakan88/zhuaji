import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/theme/app_tokens.dart';
import '../domain/reminders/reminder_planner.dart';

/// Action id of the 「已完成」 button on due reminders.
const doneActionId = 'done';

/// iOS notification category that shows the same 「已完成」 button.
const doneCategoryId = 'zhuaji_done';

abstract class ReminderNotifier {
  Future<void> init();

  /// Called with [PlannedNotification.doneKey] when 「已完成」 is tapped.
  /// Taps that arrive before a handler is set are kept and replayed.
  set onDone(Future<void> Function(String doneKey)? handler);
  Future<void> requestPermissions({bool askExactAlarm = true});
  Future<void> replaceAll(List<PlannedNotification> items);
}

class NoopNotificationService implements ReminderNotifier {
  @override
  Future<void> init() async {}

  @override
  set onDone(Future<void> Function(String doneKey)? handler) {}

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
  Future<void> Function(String doneKey)? _onDone;
  final _pending = <String>[];

  @override
  set onDone(Future<void> Function(String doneKey)? handler) {
    _onDone = handler;
    if (handler == null) return;
    final waiting = [..._pending];
    _pending.clear();
    for (final key in waiting) {
      handler(key);
    }
  }

  void _respond(NotificationResponse response) {
    final key = response.payload;
    if (response.actionId != doneActionId || key == null) return;
    final handler = _onDone;
    if (handler == null) {
      _pending.add(key);
    } else {
      handler(key);
    }
  }

  @override
  Future<void> init() async {
    const android = AndroidInitializationSettings('ic_stat_paw');
    final ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          doneCategoryId,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(
              doneActionId,
              '已完成',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
        ),
      ],
    );
    await _plugin.initialize(
      settings: InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _respond,
    );
    _ready = true;
    try {
      final launch = await _plugin.getNotificationAppLaunchDetails();
      final response = launch?.notificationResponse;
      if (launch?.didNotificationLaunchApp == true && response != null) {
        _respond(response);
      }
    } catch (error, stack) {
      debugPrint('读取通知启动信息失败：$error\n$stack');
    }
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
        notificationDetails: _details(item.channel, done: item.doneKey != null),
        androidScheduleMode: mode,
        payload: item.doneKey ?? item.channel.name,
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

  NotificationDetails _details(ReminderChannel channel, {bool done = false}) {
    final (id, name) = switch (channel) {
      ReminderChannel.health => ('zhuaji_health', '健康提醒'),
      ReminderChannel.food => ('zhuaji_food', '粮仓提醒'),
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(
        id,
        name,
        channelDescription: '肉垫本的$name',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        color: AppColors.light.brand,
        actions: done
            ? const [
                AndroidNotificationAction(
                  doneActionId,
                  '已完成',
                  showsUserInterface: true,
                ),
              ]
            : null,
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: done ? doneCategoryId : null,
      ),
    );
  }
}
