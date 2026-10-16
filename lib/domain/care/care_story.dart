import '../dates.dart';
import '../health/checkup_catalog.dart';
import '../health/disease_catalog.dart';
import '../health/lab_catalog.dart';
import '../models.dart';

enum CareKind { vaccine, deworm, visit, checkup, weight }

class CareEvent {
  const CareEvent({
    required this.on,
    required this.kind,
    required this.title,
    required this.detail,
  });

  final DateTime on;
  final CareKind kind;
  final String title;
  final String detail;
}

/// What already happened to one cat, newest first.
List<CareEvent> recentCare({
  required int catId,
  required List<VaccineRecord> vaccines,
  required List<DewormRecord> deworms,
  required List<VetRecord> visits,
  required List<CheckupRecord> checkups,
  required List<WeightRecord> weights,
  required DateTime now,
  int limit = 4,
}) {
  final today = dateOnly(now);
  final events = <CareEvent>[
    for (final item in vaccines)
      if (item.catId == catId)
        CareEvent(
          on: dateOnly(item.givenOn),
          kind: CareKind.vaccine,
          title: '疫苗',
          detail: item.name,
        ),
    for (final item in deworms)
      if (item.catId == catId)
        CareEvent(
          on: dateOnly(item.givenOn),
          kind: CareKind.deworm,
          title: '驱虫',
          detail: item.product,
        ),
    for (final item in visits)
      if (item.catId == catId)
        CareEvent(
          on: dateOnly(item.visitedOn),
          kind: CareKind.visit,
          title: '就医',
          detail: item.reason,
        ),
    for (final item in checkups)
      if (item.catId == catId && item.completedOn != null)
        CareEvent(
          on: dateOnly(item.completedOn!),
          kind: CareKind.checkup,
          title: '体检',
          detail: checkupById(item.itemId)?.name ?? item.itemId,
        ),
  ];
  final catWeights = [
    for (final item in weights)
      if (item.catId == catId) item,
  ]..sort((a, b) => a.loggedOn.compareTo(b.loggedOn));
  if (catWeights.isNotEmpty) {
    final last = catWeights.last;
    events.add(
      CareEvent(
        on: dateOnly(last.loggedOn),
        kind: CareKind.weight,
        title: '称重',
        detail: '${last.weightKg.toStringAsFixed(2)} kg',
      ),
    );
  }
  final past = events.where((event) => !event.on.isAfter(today)).toList()
    ..sort((a, b) => b.on.compareTo(a.on));
  return past.take(limit).toList();
}

/// Plain text a vet or boarder can read in a chat window.
String vetCard({
  required CatProfile cat,
  required List<VaccineRecord> vaccines,
  required List<DewormRecord> deworms,
  required List<VetRecord> visits,
  required List<WeightRecord> weights,
  required List<ConditionRecord> conditions,
  required DateTime now,
  List<LabReport> labs = const [],
  List<FoodProduct> foods = const [],
}) {
  String day(DateTime date) =>
      '${date.year}-${_two(date.month)}-${_two(date.day)}';

  final lines = <String>['${cat.name} 的健康卡'];
  final about = <String>[
    if (cat.breed != null && cat.breed!.isNotEmpty) cat.breed!,
    if (cat.birthday != null) '生日 ${day(cat.birthday!)}',
    cat.neutered ? '已绝育' : '未绝育',
  ];
  lines.add(about.join(' · '));

  final catWeights = [
    for (final item in weights)
      if (item.catId == cat.id) item,
  ]..sort((a, b) => a.loggedOn.compareTo(b.loggedOn));
  if (catWeights.isNotEmpty) {
    final last = catWeights.last;
    final first = catWeights.first;
    final delta = last.weightKg - first.weightKg;
    final sign = delta >= 0 ? '+' : '-';
    final range = catWeights.length > 1
        ? '（${day(first.loggedOn)} 起 $sign${delta.abs().toStringAsFixed(2)} kg）'
        : '';
    lines.add(
      '体重 ${last.weightKg.toStringAsFixed(2)} kg，${day(last.loggedOn)}$range',
    );
  }

  final shots = [
    for (final item in vaccines)
      if (item.catId == cat.id) item,
  ]..sort((a, b) => b.givenOn.compareTo(a.givenOn));
  for (final item in shots.take(3)) {
    final batch = item.batch == null || item.batch!.trim().isEmpty
        ? ''
        : '，批号 ${item.batch!.trim()}';
    final next = item.nextDue == null ? '' : '，下次 ${day(item.nextDue!)}';
    lines.add('疫苗 ${item.name}：${day(item.givenOn)}$batch$next');
  }

  final worms = [
    for (final item in deworms)
      if (item.catId == cat.id) item,
  ]..sort((a, b) => b.givenOn.compareTo(a.givenOn));
  for (final item in worms.take(2)) {
    final kind = item.kind == DewormKind.internal ? '体内' : '体外';
    lines.add('驱虫 $kind ${item.product}：${day(item.givenOn)}');
  }

  for (final item in conditions.where((item) => item.catId == cat.id)) {
    final name = diseaseById(item.diseaseId)?.name ?? item.diseaseId;
    final stage = item.stageLabel.isEmpty ? '' : '（${item.stageLabel}）';
    lines.add('在管理：$name$stage');
  }

  final seen = [
    for (final item in visits)
      if (item.catId == cat.id) item,
  ]..sort((a, b) => b.visitedOn.compareTo(a.visitedOn));
  if (seen.isNotEmpty) {
    final last = seen.first;
    final where = last.clinic == null || last.clinic!.isEmpty
        ? ''
        : ' · ${last.clinic}';
    lines.add('上次就医：${day(last.visitedOn)} ${last.reason}$where');
  }

  final catLabs = [
    for (final report in labs)
      if (report.catId == cat.id) report,
  ]..sort((a, b) => b.takenOn.compareTo(a.takenOn));
  for (final report in catLabs.take(2)) {
    final bits = <String>[];
    for (final value in report.values) {
      final reading = readLabValue(value);
      if (reading == null || bits.length >= 3) continue;
      bits.add('${value.code} ${reading.flagLabel}');
    }
    final summary = bits.isEmpty ? '已存档' : bits.join('，');
    lines.add('化验 ${day(report.takenOn)} ${report.kindTitle}：$summary');
  }

  final custom = [
    for (final food in foods)
      if (food.isCustom) food,
  ];
  for (final food in custom.take(3)) {
    final spec = food.spec.trim().isEmpty ? '' : ' ${food.spec.trim()}';
    lines.add('自定义猫粮：${food.brand} ${food.name}$spec');
  }

  lines.add('由花爪整理于 ${day(dateOnly(now))}，仅供参考，请遵医嘱。');
  return lines.join('\n');
}

String _two(int value) => value.toString().padLeft(2, '0');
