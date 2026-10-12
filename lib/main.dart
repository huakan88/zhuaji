import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'data/db/app_database.dart';
import 'data/repositories/drift_care_repository.dart';
import 'services/coat_recognizer.dart';
import 'services/notification_service.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  } catch (_) {
    tz.setLocalLocation(tz.UTC);
  }

  final notifications = NotificationService();
  await notifications.init();
  final controller = AppController(
    repo: DriftCareRepository(AppDatabase.defaults()),
    notifications: notifications,
    recognizer: MlKitCoatBreedRecognizer(),
  );
  await controller.init();
  runApp(ZhuajiApp(controller: controller));
}
