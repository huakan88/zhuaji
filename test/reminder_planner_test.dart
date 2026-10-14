import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/reminders/reminder_planner.dart';

void main() {
  const planner = ReminderPlanner();
  final now = DateTime(2026, 10, 12, 10);

  PlannedNotification? byId(List<PlannedNotification> items, int id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  test('expiry schedules 30 days, 7 days and the expiry morning', () {
    final items = planner.plan(
      now: now,
      expiries: [
        ExpiryInput(
          id: 4,
          productName: '皇家室内成猫粮',
          expiryDate: DateTime(2026, 11, 21),
        ),
      ],
    );
    expect(byId(items, 30000004)?.when, DateTime(2026, 10, 22, 9));
    expect(byId(items, 31000004)?.when, DateTime(2026, 11, 14, 9));
    expect(byId(items, 32000004)?.when, DateTime(2026, 11, 21, 9));
    expect(items, hasLength(3));
  });

  test('drops expiry reminders that are already past', () {
    final inTenDays = planner.plan(
      now: now,
      expiries: [
        ExpiryInput(
          id: 1,
          productName: '干粮',
          expiryDate: DateTime(2026, 10, 22),
        ),
      ],
    );
    expect(byId(inTenDays, 30000001), isNull);
    expect(byId(inTenDays, 31000001)?.when, DateTime(2026, 10, 15, 9));
    expect(byId(inTenDays, 32000001)?.when, DateTime(2026, 10, 22, 9));

    final inThreeDays = planner.plan(
      now: now,
      expiries: [
        ExpiryInput(
          id: 2,
          productName: '干粮',
          expiryDate: DateTime(2026, 10, 15),
        ),
      ],
    );
    expect(inThreeDays.map((item) => item.id), [32000002]);

    final yesterday = planner.plan(
      now: now,
      expiries: [
        ExpiryInput(
          id: 3,
          productName: '干粮',
          expiryDate: DateTime(2026, 10, 11),
        ),
      ],
    );
    expect(yesterday, isEmpty);
  });

  test('vaccine and deworm use a 7-day lead and the due morning', () {
    final items = planner.plan(
      now: now,
      dues: [
        DueInput(
          id: 8,
          catName: '橘座',
          label: '猫三联',
          dueDate: DateTime(2026, 10, 22),
          vaccine: true,
        ),
        DueInput(
          id: 9,
          catName: '橘座',
          label: '体内驱虫',
          dueDate: DateTime(2026, 10, 14),
          vaccine: false,
        ),
      ],
    );
    expect(byId(items, 10000008)?.when, DateTime(2026, 10, 15, 9));
    expect(byId(items, 11000008)?.when, DateTime(2026, 10, 22, 9));
    expect(byId(items, 20000009), isNull);
    expect(byId(items, 21000009)?.when, DateTime(2026, 10, 14, 9));
    expect(byId(items, 11000008)?.body, contains('不能代替兽医'));
  });

  test(
    'opened food uses a 7-day lead for long windows and 1 day for wet food',
    () {
      final dry = planner.plan(
        now: now,
        opened: [
          OpenedInput(
            id: 5,
            productName: '干粮',
            openedAt: DateTime(2026, 10, 12, 8),
            afterOpenDays: 42,
          ),
        ],
      );
      expect(byId(dry, 40000005)?.when, DateTime(2026, 11, 16, 9));
      expect(byId(dry, 42000005)?.when, DateTime(2026, 11, 23, 9));

      final wet = planner.plan(
        now: now,
        opened: [
          OpenedInput(
            id: 6,
            productName: '罐头',
            openedAt: DateTime(2026, 10, 12, 8),
            afterOpenDays: 2,
          ),
        ],
      );
      expect(byId(wet, 41000006)?.when, DateTime(2026, 10, 13, 9));
      expect(byId(wet, 42000006)?.when, DateTime(2026, 10, 14, 9));
    },
  );

  test('restock reminds 7 days ahead, and a snooze only keeps that morning', () {
    final items = planner.plan(
      now: now,
      stocks: [
        StockInput(
          id: 8,
          productName: '室内成猫全价粮',
          runOut: DateTime(2026, 10, 20),
        ),
      ],
    );
    expect(byId(items, 50000008)?.when, DateTime(2026, 10, 13, 9));
    expect(byId(items, 51000008)?.body, contains('今天会吃完'));
    final snoozed = planner.plan(
      now: now,
      stocks: [
        StockInput(
          id: 8,
          productName: '室内成猫全价粮',
          runOut: DateTime(2026, 10, 19),
          snoozed: true,
        ),
      ],
    );
    expect(byId(snoozed, 50000008), isNull);
    expect(byId(snoozed, 51000008)?.when, DateTime(2026, 10, 19, 9));
  });
}
