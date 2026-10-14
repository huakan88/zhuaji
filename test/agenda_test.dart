import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/care/agenda.dart';
import 'package:maokangji/domain/models.dart';

void main() {
  final today = DateTime(2026, 10, 12, 10);
  final cat = CatProfile(
    id: 1,
    name: '橘座',
    sex: CatSex.unknown,
    neutered: true,
    goal: CareGoal.maintain,
    notes: '',
    isSample: false,
    createdAt: DateTime(2026, 1, 1),
  );

  FoodProduct food({required String spec}) => FoodProduct(
    id: 3,
    brand: '山野',
    name: '冻干双拼',
    spec: spec,
    foodForm: FoodForm.dry,
    storageMethod: '',
    afterOpenDays: 30,
    isSample: false,
    isCustom: true,
  );

  test('puts the next 30 days on one calendar and parks overdue on today', () {
    final items = buildAgenda(
      now: today,
      cats: [cat],
      vaccines: [
        VaccineRecord(
          id: 4,
          catId: 1,
          name: '猫三联',
          givenOn: DateTime(2025, 10, 1),
          notes: '',
          nextDue: DateTime(2026, 10, 30),
        ),
        VaccineRecord(
          id: 5,
          catId: 1,
          name: '狂犬',
          givenOn: DateTime(2025, 1, 1),
          notes: '',
          nextDue: DateTime(2026, 10, 1),
        ),
      ],
      deworms: [
        DewormRecord(
          id: 6,
          catId: 1,
          kind: DewormKind.external,
          product: '体外',
          givenOn: DateTime(2026, 9, 1),
          notes: '',
          nextDue: DateTime(2026, 10, 18),
        ),
      ],
      checkups: [
        CheckupRecord(
          id: 7,
          catId: 1,
          itemId: 'exam',
          result: '',
          nextDue: DateTime(2026, 12, 1),
        ),
      ],
      conditions: [
        ConditionRecord(
          id: 8,
          catId: 1,
          diseaseId: 'ckd',
          diagnosedOn: DateTime(2026, 1, 1),
          stageLabel: '',
          note: '',
          nextRecheck: DateTime(2026, 10, 20),
        ),
      ],
      pantry: [
        PantryEntry(
          item: PantryItem(
            id: 9,
            productId: 3,
            dateSource: DateSource.manual,
            expiryDate: DateTime(2026, 11, 1),
            openedAt: DateTime(2026, 9, 30),
            afterOpenDays: 30,
            dailyGrams: 80,
          ),
          product: food(spec: '1.5kg'),
        ),
      ],
    );

    AgendaItem? named(AgendaKind kind) {
      for (final item in items) {
        if (item.kind == kind) return item;
      }
      return null;
    }

    final shot = items.where((item) => item.recordId == 4).single;
    expect(shot.day, DateTime(2026, 10, 30));
    expect(shot.detail, '橘座 · 猫三联');
    final overdue = items.where((item) => item.recordId == 5).single;
    expect(overdue.day, DateTime(2026, 10, 12));
    expect(overdue.overdue, isTrue);
    expect(named(AgendaKind.deworm)?.day, DateTime(2026, 10, 18));
    expect(named(AgendaKind.checkup), isNull);
    expect(named(AgendaKind.recheck)?.title, '复诊');
    expect(named(AgendaKind.expiry)?.day, DateTime(2026, 11, 1));
    expect(named(AgendaKind.opened)?.day, DateTime(2026, 10, 30));
    expect(named(AgendaKind.restock)?.day, DateTime(2026, 10, 18));
    expect(named(AgendaKind.restock)?.route, '/bag?id=9');

    final copy = homeWidgetCopy(now: today, items: items);
    expect(copy.todayLines.join('\n'), contains('狂犬'));
    expect(copy.nextLine, contains('10月18日'));
    expect(copy.route, '/bag?id=9');
  });

  test('a restock snooze moves the dot, and an ack hides the food date', () {
    final entry = PantryEntry(
      item: PantryItem(
        id: 9,
        productId: 3,
        dateSource: DateSource.manual,
        expiryDate: DateTime(2026, 10, 20),
        dailyGrams: 50,
      ),
      product: food(spec: '85g'),
    );
    final snoozed = buildAgenda(
      now: today,
      cats: [cat],
      vaccines: const [],
      deworms: const [],
      checkups: const [],
      conditions: const [],
      pantry: [entry],
      stockSnooze: {9: DateTime(2026, 10, 19)},
    );
    expect(
      snoozed.where((item) => item.kind == AgendaKind.restock).single.day,
      DateTime(2026, 10, 19),
    );

    final hidden = buildAgenda(
      now: today,
      cats: [cat],
      vaccines: const [],
      deworms: const [],
      checkups: const [],
      conditions: const [],
      pantry: [entry],
      ackedPantryKeys: {'9|${DateTime(2026, 10, 20).millisecondsSinceEpoch}|0'},
    );
    expect(hidden.where((item) => item.kind == AgendaKind.expiry), isEmpty);
    expect(hidden.where((item) => item.kind == AgendaKind.restock), isNotEmpty);
  });
}