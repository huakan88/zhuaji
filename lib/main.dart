import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/consent_launch.dart';
import 'data/db/app_database.dart';
import 'data/repositories/drift_care_repository.dart';
import 'services/cloud/cloud_bridge.dart';
import 'services/coat_recognizer.dart';
import 'services/notification_service.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('界面错误：${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('未捕获的错误：$error\n$stack');
    return true;
  };

  final notifications = NotificationService();
  final repo = DriftCareRepository(AppDatabase.defaults());
  final controller = AppController(
    repo: repo,
    notifications: notifications,
    recognizer: const ColorCoatRecognizer(),
  );
  final plan = planLaunch(await repo.setting('privacyConsent'));
  if (!plan.showConsent) {
    controller.privacyChoice = plan.initNotifications
        ? PrivacyChoice.accepted
        : PrivacyChoice.basic;
  }
  var servicesStarted = false;
  Future<void> startFullServices() async {
    if (servicesStarted) return;
    servicesStarted = true;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    try {
      await notifications.init();
    } catch (error, stack) {
      debugPrint('通知初始化失败，记录仍会保存：$error\n$stack');
    }
    notifications.onDone = (key) async {
      final text = await controller.completeFromNotification(key);
      zhuajiMessenger.currentState?.showSnackBar(
        SnackBar(
          content: Text(text ?? '这条提醒的记录已经不在了'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    };
    await CloudBridge(
      config: AppConfig.fromEnvironment(),
      repo: repo,
    ).syncQuietly();
  }

  controller.onFullAccess = startFullServices;
  runApp(ZhuajiApp(controller: controller));
  if (plan.showConsent) return;
  try {
    if (plan.initNotifications) await startFullServices();
    await controller.init();
  } catch (error, stack) {
    debugPrint('启动没有完成：$error\n$stack');
    controller.failStart('本地数据没有打开，可以点重试');
  }
}
