import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/health/checkup_catalog.dart';
import 'package:maokangji/domain/health/disease_catalog.dart';
import 'package:maokangji/domain/health/life_stage.dart';
import 'package:maokangji/domain/reminders/reminder_planner.dart';

void main() {
  final now = DateTime(2026, 10, 12);

  test('life stage follows birthday boundaries', () {
    expect(lifeStageFor(null, now), LifeStage.adult);
    expect(lifeStageFor(DateTime(2026, 4, 12), now), LifeStage.kitten);
    expect(lifeStageFor(DateTime(2025, 10, 13), now), LifeStage.kitten);
    expect(lifeStageFor(DateTime(2025, 10, 12), now), LifeStage.adult);
    expect(lifeStageFor(DateTime(2020, 10, 12), now), LifeStage.adult);
    expect(lifeStageFor(DateTime(2019, 10, 13), now), LifeStage.adult);
    expect(lifeStageFor(DateTime(2019, 10, 12), now), LifeStage.mature);
    expect(lifeStageFor(DateTime(2016, 10, 12), now), LifeStage.mature);
    expect(lifeStageFor(DateTime(2015, 10, 13), now), LifeStage.mature);
    expect(lifeStageFor(DateTime(2015, 10, 12), now), LifeStage.senior);
    expect(lifeStageLabel(LifeStage.senior), '老年');
  });

  test('adult domestic cat gets baseline labs without breed screens', () {
    final plan = recommendCheckups(
      birthday: DateTime(2023, 10, 12),
      breed: '中华田园猫',
      now: now,
    );
    expect(plan.stage, LifeStage.adult);
    expect(plan.birthdayMissing, isFalse);
    final names = plan.items.map((item) => item.item.name).toList();
    expect(names, contains('血常规'));
    expect(names, contains('SDMA / 肾功能'));
    expect(names, contains('疫苗'));
    expect(names, isNot(contains('心脏超声（HCM 筛查）')));
    expect(names, isNot(contains('PKD 基因或肾脏超声')));
    final vaccine = plan.items.firstWhere((item) => item.item.id == 'vaccine');
    expect(vaccine.plan.frequency, contains('1 年或 3 年'));
    expect(vaccine.item.source, contains('WSAVA'));
  });

  test('mature and senior schedules tighten, kittens skip thyroid', () {
    final mature = recommendCheckups(
      birthday: DateTime(2018, 1, 1),
      breed: '中华田园猫',
      now: now,
    );
    expect(mature.stage, LifeStage.mature);
    expect(
      mature.items.firstWhere((item) => item.item.id == 't4').plan.frequency,
      contains('7 岁'),
    );
    expect(
      mature.items.firstWhere((item) => item.item.id == 'bp').plan.intervalDays,
      180,
    );

    final senior = recommendCheckups(
      birthday: DateTime(2014, 1, 1),
      breed: null,
      now: now,
    );
    expect(senior.stage, LifeStage.senior);
    expect(
      senior.items.firstWhere((item) => item.item.id == 'exam').plan.frequency,
      contains('6 个月'),
    );

    final kitten = recommendCheckups(
      birthday: DateTime(2026, 6, 1),
      breed: '布偶',
      now: now,
    );
    expect(kitten.stage, LifeStage.kitten);
    expect(kitten.items.map((item) => item.item.id), isNot(contains('t4')));
    expect(kitten.items.map((item) => item.item.id), contains('hcm'));
  });

  test('Maine Coon and British Shorthair add the matching screens', () {
    final maine = recommendCheckups(
      birthday: DateTime(2022, 1, 1),
      breed: '缅因猫',
      now: now,
    );
    expect(maine.items.map((item) => item.item.id), contains('hcm'));
    expect(maine.items.map((item) => item.item.id), isNot(contains('pkd')));

    final british = recommendCheckups(
      birthday: DateTime(2024, 10, 12),
      breed: '英国短毛猫',
      now: now,
    );
    expect(british.stage, LifeStage.adult);
    expect(british.items.map((item) => item.item.id), contains('pkd'));
    expect(british.items.map((item) => item.item.id), isNot(contains('hcm')));

    final persian = recommendCheckups(
      birthday: DateTime(2024, 1, 1),
      breed: '波斯',
      now: now,
    );
    expect(persian.items.map((item) => item.item.id), contains('pkd'));
  });

  test('disease library covers the requested conditions and cites sources', () {
    expect(diseaseCatalog, hasLength(12));
    expect(diseaseById('ckd')?.stages, contains('IRIS 2'));
    expect(diseaseById('flutd')?.redFlags.join(), contains('尿'));
    expect(diseaseById('arthritis')?.medication, contains('人用'));
    expect(diseaseById('fip')?.medication, contains('兽医'));
    for (final disease in diseaseCatalog) {
      expect(disease.diet, isNotEmpty);
      expect(disease.water, isNotEmpty);
      expect(disease.medication, isNotEmpty);
      expect(disease.recheck, isNotEmpty);
      expect(disease.monitoring, isNotEmpty);
      expect(disease.redFlags, isNotEmpty);
      expect(disease.sources, isNotEmpty);
      expect(disease.recheckDays, greaterThan(0));
    }
  });

  test('checkup and recheck reminders use separate ids', () {
    final items = const ReminderPlanner().plan(
      now: DateTime(2026, 10, 12, 10),
      followUps: [
        FollowUpInput(
          id: 4,
          catName: '橘座',
          label: '血常规',
          dueDate: DateTime(2026, 10, 20),
          recheck: false,
        ),
        FollowUpInput(
          id: 4,
          catName: '橘座',
          label: '慢性肾病',
          dueDate: DateTime(2026, 11, 21),
          recheck: true,
        ),
      ],
    );
    expect(items.map((item) => item.id), containsAll([70000004, 71000004, 80000004, 81000004]));
    expect(items.firstWhere((item) => item.id == 81000004).body, contains('遵医嘱'));
  });
}
