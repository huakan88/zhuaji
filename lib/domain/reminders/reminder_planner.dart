import '../dates.dart';

enum ReminderChannel { health, food }

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
    required this.channel,
    this.repeatsDaily = false,
    this.doneKey,
  });

  final int id;
  final DateTime when;
  final String title;
  final String body;
  final ReminderChannel channel;
  final bool repeatsDaily;

  /// Set when the notification can offer 「已完成」; see [DoneKey].
  final String? doneKey;
}

/// What a 「已完成」 tap on a notification should mark done.
class DoneKey {
  const DoneKey({required this.vaccine, required this.recordId});

  final bool vaccine;
  final int recordId;

  String get value => '${vaccine ? 'vaccine' : 'deworm'}:$recordId';

  static DoneKey? parse(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final id = int.tryParse(parts[1]);
    if (id == null) return null;
    return switch (parts[0]) {
      'vaccine' => DoneKey(vaccine: true, recordId: id),
      'deworm' => DoneKey(vaccine: false, recordId: id),
      _ => null,
    };
  }
}

class DueInput {
  const DueInput({
    required this.id,
    required this.catName,
    required this.label,
    required this.dueDate,
    required this.vaccine,
  });

  final int id;
  final String catName;
  final String label;
  final DateTime dueDate;
  final bool vaccine;
}

class ExpiryInput {
  const ExpiryInput({
    required this.id,
    required this.productName,
    required this.expiryDate,
  });

  final int id;
  final String productName;
  final DateTime expiryDate;
}

class OpenedInput {
  const OpenedInput({
    required this.id,
    required this.productName,
    required this.openedAt,
    required this.afterOpenDays,
  });

  final int id;
  final String productName;
  final DateTime openedAt;
  final int afterOpenDays;
}

class StockInput {
  const StockInput({
    required this.id,
    required this.productName,
    required this.runOut,
    this.snoozed = false,
  });

  final int id;
  final String productName;
  final DateTime runOut;

  /// The household already postponed this one, so only the new morning fires.
  final bool snoozed;
}

class FollowUpInput {
  const FollowUpInput({
    required this.id,
    required this.catName,
    required this.label,
    required this.dueDate,
    required this.recheck,
  });

  final int id;
  final String catName;
  final String label;
  final DateTime dueDate;

  /// True for a disease recheck, false for a checkup reminder.
  final bool recheck;
}

/// Pure reminder schedule. Callers decide which of these to register
/// with the OS (the service keeps the soonest 60).
class ReminderPlanner {
  const ReminderPlanner();

  static const healthHour = 9;

  List<PlannedNotification> plan({
    required DateTime now,
    List<DueInput> dues = const [],
    List<ExpiryInput> expiries = const [],
    List<OpenedInput> opened = const [],
    List<FollowUpInput> followUps = const [],
    List<StockInput> stocks = const [],
  }) {
    final items = <PlannedNotification>[];
    for (final due in dues) {
      items.addAll(_due(due, now));
    }
    for (final follow in followUps) {
      items.addAll(_followUp(follow, now));
    }
    for (final expiry in expiries) {
      items.addAll(_expiry(expiry, now));
    }
    for (final bag in opened) {
      items.addAll(_opened(bag, now));
    }
    for (final stock in stocks) {
      items.addAll(_stock(stock, now));
    }
    items.sort((a, b) => a.when.compareTo(b.when));
    return items;
  }

  List<PlannedNotification> _due(DueInput due, DateTime now) {
    final kind = due.vaccine ? '接种' : '驱虫';
    final base = due.vaccine ? 10000000 : 20000000;
    return _offsets(
      day: due.dueDate,
      now: now,
      offsets: const [7, 0],
      idFor: (offset) => base + (offset == 7 ? 0 : 1000000) + due.id,
      titleFor: (offset) =>
          offset == 0 ? '${due.catName}的$kind提醒' : '${due.catName}的$kind将至',
      bodyFor: (offset) => offset == 0
          ? '今天是「${due.label}」的计划日期。这只是提醒，不能代替兽医判断。'
          : '还有 7 天到「${due.label}」的计划日期。',
      channel: ReminderChannel.health,
      doneKey: DoneKey(vaccine: due.vaccine, recordId: due.id).value,
    );
  }

  List<PlannedNotification> _followUp(FollowUpInput follow, DateTime now) {
    final base = follow.recheck ? 80000000 : 70000000;
    final kind = follow.recheck ? '复查' : '体检';
    return _offsets(
      day: follow.dueDate,
      now: now,
      offsets: const [7, 0],
      idFor: (offset) => base + (offset == 7 ? 0 : 1000000) + follow.id,
      titleFor: (offset) => offset == 0
          ? '${follow.catName}的$kind日'
          : '${follow.catName}的$kind将至',
      bodyFor: (offset) => offset == 0
          ? '今天是「${follow.label}」的计划日期。仅供参考，请遵医嘱。'
          : '还有 7 天到「${follow.label}」。',
      channel: ReminderChannel.health,
    );
  }

  List<PlannedNotification> _expiry(ExpiryInput expiry, DateTime now) {
    return _offsets(
      day: expiry.expiryDate,
      now: now,
      offsets: const [30, 7, 0],
      idFor: (offset) => switch (offset) {
        30 => 30000000 + expiry.id,
        7 => 31000000 + expiry.id,
        _ => 32000000 + expiry.id,
      },
      titleFor: (offset) => offset == 0 ? '猫粮今天到期' : '猫粮即将到期',
      bodyFor: (offset) => offset == 0
          ? '「${expiry.productName}」今天到保质期，请检查后再决定是否喂食。'
          : '「${expiry.productName}」将在 $offset 天后到期。',
      channel: ReminderChannel.food,
    );
  }

  List<PlannedNotification> _opened(OpenedInput bag, DateTime now) {
    if (bag.afterOpenDays <= 0) return const [];
    final due = dateOnly(bag.openedAt).add(Duration(days: bag.afterOpenDays));
    final offsets = <int>[0];
    if (bag.afterOpenDays >= 21) offsets.insert(0, 7);
    if (bag.afterOpenDays <= 7) offsets.insert(0, 1);
    return _offsets(
      day: due,
      now: now,
      offsets: offsets,
      idFor: (offset) => switch (offset) {
        7 => 40000000 + bag.id,
        1 => 41000000 + bag.id,
        _ => 42000000 + bag.id,
      },
      titleFor: (_) => '开封猫粮请尽快喂完',
      bodyFor: (offset) => offset == 0
          ? '「${bag.productName}」已到开封后建议喂完的日子。'
          : '「${bag.productName}」开封后还剩约 $offset 天建议喂完窗口。',
      channel: ReminderChannel.food,
    );
  }

  List<PlannedNotification> _stock(StockInput stock, DateTime now) {
    final offsets = stock.snoozed ? const <int>[0] : const <int>[7, 0];
    return _offsets(
      day: stock.runOut,
      now: now,
      offsets: offsets,
      idFor: (offset) => (offset == 7 ? 50000000 : 51000000) + stock.id,
      titleFor: (_) => '猫粮该补货了',
      bodyFor: (offset) => offset == 0
          ? '「${stock.productName}」按现在的喂食量今天会吃完。'
          : '「${stock.productName}」大约还能吃 7 天，可以准备补货。',
      channel: ReminderChannel.food,
    );
  }

  List<PlannedNotification> _offsets({
    required DateTime day,
    required DateTime now,
    required List<int> offsets,
    required int Function(int offset) idFor,
    required String Function(int offset) titleFor,
    required String Function(int offset) bodyFor,
    required ReminderChannel channel,
    String? doneKey,
  }) {
    final items = <PlannedNotification>[];
    for (final offset in offsets) {
      final when = atTime(
        dateOnly(day).subtract(Duration(days: offset)),
        healthHour,
        0,
      );
      if (!when.isAfter(now)) continue;
      items.add(
        PlannedNotification(
          id: idFor(offset),
          when: when,
          title: titleFor(offset),
          body: bodyFor(offset),
          channel: channel,
          doneKey: doneKey,
        ),
      );
    }
    return items;
  }
}

/// Drops one-shot reminders that are already due, keeps daily ones, and
/// never asks the OS for more than [limit] notifications.
List<PlannedNotification> schedulable(
  List<PlannedNotification> items,
  DateTime now, {
  int limit = 60,
}) {
  final kept = [
    for (final item in items)
      if (item.repeatsDaily || item.when.isAfter(now)) item,
  ]..sort((a, b) => a.when.compareTo(b.when));
  if (kept.length <= limit) return kept;
  return kept.sublist(0, limit);
}
