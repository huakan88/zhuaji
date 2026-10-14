import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/app.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/reminders/reminder_planner.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';

class _Recorder extends NoopNotificationService {
  List<PlannedNotification> last = [];

  @override
  Future<void> replaceAll(List<PlannedNotification> items) async {
    last = items;
  }
}

void main() {
  final now = DateTime(2026, 10, 12, 10);

  test('vaccine and deworm reminders carry a 已完成 key, food does not', () {
    final plan = const ReminderPlanner().plan(
      now: now,
      dues: [
        DueInput(
          id: 7,
          catName: '橘座',
          label: '猫三联',
          dueDate: DateTime(2026, 11, 1),
          vaccine: true,
        ),
        DueInput(
          id: 9,
          catName: '橘座',
          label: '体内驱虫',
          dueDate: DateTime(2026, 11, 1),
          vaccine: false,
        ),
      ],
      expiries: [
        ExpiryInput(
          id: 3,
          productName: '干粮',
          expiryDate: DateTime(2026, 11, 1),
        ),
      ],
    );
    final keys = {
      for (final item in plan)
        if (item.channel == ReminderChannel.health) item.doneKey,
    };
    expect(keys, {'vaccine:7', 'deworm:9'});
    expect(
      plan
          .where((item) => item.channel == ReminderChannel.food)
          .every((item) => item.doneKey == null),
      isTrue,
    );
  });

  test('done keys round-trip and reject junk', () {
    final key = DoneKey.parse('deworm:12')!;
    expect(key.vaccine, isFalse);
    expect(key.recordId, 12);
    expect(DoneKey.parse(key.value)!.recordId, 12);
    expect(DoneKey.parse('vaccine:x'), isNull);
    expect(DoneKey.parse('food:1'), isNull);
    expect(DoneKey.parse('health'), isNull);
    expect(DoneKey.parse(null), isNull);
  });

  group('completeFromNotification', () {
    late AppDatabase database;
    late AppController controller;
    late _Recorder notifier;

    setUp(() async {
      database = AppDatabase.memory();
      notifier = _Recorder();
      controller = AppController(
        repo: DriftCareRepository(database),
        notifications: notifier,
        recognizer: const MockCoatBreedRecognizer(),
        clock: () => now,
      );
      await controller.init();
    });

    tearDown(() => database.close());

    test('marks the vaccine done today and moves the reminder', () async {
      final shot = controller.vaccines.firstWhere(
        (item) => item.nextDue != null,
      );
      final key = notifier.last
          .firstWhere((item) => item.doneKey == 'vaccine:${shot.id}')
          .doneKey;
      final text = await controller.completeFromNotification(key);
      expect(text, contains('记下了'));
      final after = controller.vaccines.singleWhere(
        (item) => item.id == shot.id,
      );
      expect(after.givenOn, DateTime(2026, 10, 12));
      expect(after.nextDue!.isAfter(shot.nextDue!), isTrue);
    });

    test('marks a deworm dose done with the 90-day follow-up', () async {
      final worm = controller.deworms.firstWhere(
        (item) => item.nextDue != null,
      );
      await controller.completeFromNotification('deworm:${worm.id}');
      final after = controller.deworms.singleWhere(
        (item) => item.id == worm.id,
      );
      expect(after.givenOn, DateTime(2026, 10, 12));
      expect(after.nextDue, DateTime(2027, 1, 10));
    });

    test('a deleted record is a quiet no-op', () async {
      expect(await controller.completeFromNotification('vaccine:99999'), null);
      expect(await controller.completeFromNotification('junk'), null);
    });
  });

  test('long-press shortcuts open weight, deworm and scan', () {
    expect(appShortcuts.map((item) => item.title), ['称体重', '记驱虫', '扫粮']);
    expect(shortcutRoute('weight'), '/weight');
    expect(shortcutRoute('deworm'), '/deworms');
    expect(shortcutRoute('scan'), '/scan');
    expect(shortcutRoute('nope'), isNull);
  });
}
