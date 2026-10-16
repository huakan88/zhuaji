import '../dates.dart';
import '../food/stock.dart';
import '../health/checkup_catalog.dart';
import '../health/disease_catalog.dart';
import '../models.dart';

/// How many calendar days, today included.
const agendaSpanDays = 30;

enum AgendaKind { vaccine, deworm, checkup, expiry, opened, restock, recheck }

class AgendaItem {
  const AgendaItem({
    required this.kind,
    required this.day,
    required this.title,
    required this.detail,
    required this.recordId,
    required this.route,
    this.overdue = false,
  });

  final AgendaKind kind;
  final DateTime day;
  final String title;
  final String detail;
  final int recordId;
  final String route;
  final bool overdue;
}

class HomeWidgetCopy {
  const HomeWidgetCopy({
    required this.todayLines,
    required this.nextLine,
    required this.route,
  });

  final List<String> todayLines;
  final String nextLine;
  final String route;

  Map<String, Object> toJson({String appearance = 'system'}) => {
    'today': todayLines,
    'next': nextLine,
    'route': route,
    'appearance': appearance,
  };
}

/// Vaccines, deworming, checkups, food dates, restock and rechecks
/// that fall on the next [agendaSpanDays] days. Overdue items sit on today.
List<AgendaItem> buildAgenda({
  required DateTime now,
  required List<CatProfile> cats,
  required List<VaccineRecord> vaccines,
  required List<DewormRecord> deworms,
  required List<CheckupRecord> checkups,
  required List<ConditionRecord> conditions,
  required List<PantryEntry> pantry,
  Set<String> ackedPantryKeys = const {},
  Map<int, DateTime> stockSnooze = const {},
}) {
  final today = dateOnly(now);
  final last = today.add(const Duration(days: agendaSpanDays - 1));
  final items = <AgendaItem>[];

  void place({
    required DateTime due,
    required AgendaKind kind,
    required String title,
    required String detail,
    required int recordId,
    required String route,
    DateTime? snooze,
  }) {
    final held = snooze == null ? null : dateOnly(snooze);
    late final DateTime day;
    var overdue = false;
    if (held != null && !held.isBefore(today)) {
      if (held.isAfter(last)) return;
      day = held;
    } else {
      final target = dateOnly(due);
      if (target.isAfter(last)) return;
      if (target.isBefore(today)) {
        day = today;
        overdue = true;
      } else {
        day = target;
      }
    }
    items.add(
      AgendaItem(
        kind: kind,
        day: day,
        title: title,
        detail: detail,
        recordId: recordId,
        route: route,
        overdue: overdue,
      ),
    );
  }

  String who(int catId) {
    for (final cat in cats) {
      if (cat.id == catId) return cat.name;
    }
    return '猫咪';
  }

  for (final item in vaccines) {
    final due = item.nextDue;
    if (due == null) continue;
    place(
      due: due,
      kind: AgendaKind.vaccine,
      title: '疫苗',
      detail: '${who(item.catId)} · ${item.name}',
      recordId: item.id,
      route: '/vaccines',
    );
  }
  for (final item in deworms) {
    final due = item.nextDue;
    if (due == null) continue;
    place(
      due: due,
      kind: AgendaKind.deworm,
      title: '驱虫',
      detail: '${who(item.catId)} · ${item.product}',
      recordId: item.id,
      route: '/deworms',
    );
  }
  for (final item in checkups) {
    final due = item.nextDue;
    if (due == null) continue;
    final name = checkupById(item.itemId)?.name ?? item.itemId;
    place(
      due: due,
      kind: AgendaKind.checkup,
      title: '体检',
      detail: '${who(item.catId)} · $name',
      recordId: item.id,
      route: '/checkups',
    );
  }
  for (final item in conditions) {
    final due = item.nextRecheck;
    if (due == null) continue;
    final name = diseaseById(item.diseaseId)?.name ?? item.diseaseId;
    place(
      due: due,
      kind: AgendaKind.recheck,
      title: '复诊',
      detail: '${who(item.catId)} · $name',
      recordId: item.id,
      route: '/disease?id=${Uri.encodeComponent(item.diseaseId)}',
    );
  }
  for (final entry in pantry) {
    final name = entry.product.name;
    final bag = '/bag?id=${entry.item.id}';
    final hidden = ackedPantryKeys.contains(pantryAckKey(entry));
    if (!hidden && entry.item.expiryDate != null) {
      place(
        due: entry.item.expiryDate!,
        kind: AgendaKind.expiry,
        title: '粮到期',
        detail: name,
        recordId: entry.item.id,
        route: bag,
      );
    }
    final useBy = openedUseBy(entry);
    if (!hidden && useBy != null) {
      place(
        due: useBy,
        kind: AgendaKind.opened,
        title: '开封粮',
        detail: name,
        recordId: entry.item.id,
        route: bag,
      );
    }
    final estimate = estimateStock(
      spec: entry.product.spec,
      dailyGrams: entry.item.dailyGrams,
      openedAt: entry.item.openedAt,
      today: today,
    );
    final runOut = estimate.runOutOn;
    if (estimate.low && runOut != null) {
      place(
        due: runOut,
        kind: AgendaKind.restock,
        title: '补货',
        detail: name,
        recordId: entry.item.id,
        route: bag,
        snooze: stockSnooze[entry.item.id],
      );
    }
  }

  items.sort((a, b) {
    final byDay = a.day.compareTo(b.day);
    if (byDay != 0) return byDay;
    return a.title.compareTo(b.title);
  });
  return items;
}

List<AgendaItem> agendaOn(List<AgendaItem> items, DateTime day) {
  final target = dateOnly(day);
  return [
    for (final item in items)
      if (dateOnly(item.day) == target) item,
  ];
}

HomeWidgetCopy homeWidgetCopy({
  required DateTime now,
  required List<AgendaItem> items,
}) {
  final today = dateOnly(now);
  final todays = [
    for (final item in items)
      if (dateOnly(item.day) == today) item,
  ];
  final lines = [for (final item in todays.take(4)) agendaLine(item)];
  final future = [
    for (final item in items)
      if (dateOnly(item.day).isAfter(today)) item,
  ]..sort((a, b) => a.day.compareTo(b.day));
  final next = future.isEmpty ? null : future.first;
  return HomeWidgetCopy(
    todayLines: lines.isEmpty ? const ['今天没什么要办'] : lines,
    nextLine: next == null
        ? '30 天内没有更晚的提醒'
        : '${next.day.month}月${next.day.day}日 ${agendaLine(next)}',
    route: next?.route ?? (todays.isEmpty ? '/calendar' : todays.first.route),
  );
}

String agendaLine(AgendaItem item) => '${item.title} ${item.detail}';
