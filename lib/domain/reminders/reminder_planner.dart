import '../dates.dart';
import '../feeding/feeding_math.dart';

enum ReminderChannel { health, feeding, food }

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
    required this.channel,
    this.repeatsDaily = false,
  });

  final int id;
  final DateTime when;
  final String title;
  final String body;
  final ReminderChannel channel;
  final bool repeatsDaily;
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

class FeedingInput {
  const FeedingInput({
    required this.catId,
    required this.catName,
    required this.slot,
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  final int catId;
  final String catName;
  final int slot;
  final int hour;
  final int minute;
  final bool enabled;
}

class TransitionInput {
  const TransitionInput({
    required this.id,
    required this.catName,
    required this.fromFood,
    required this.toFood,
    required this.startDate,
    this.days = 7,
  });

  final int id;
  final String catName;
  final String fromFood;
  final String toFood;
  final DateTime startDate;
  final int days;
}

/// Pure reminder schedule. Callers decide which of these to register
/// with the OS (the service keeps the soonest 60).
class ReminderPlanner {
  const ReminderPlanner();

  static const healthHour = 9;
  static const transitionHour = 8;
  static const transitionMinute = 30;

  List<PlannedNotification> plan({
    required DateTime now,
    List<DueInput> dues = const [],
    List<ExpiryInput> expiries = const [],
    List<OpenedInput> opened = const [],
    List<FeedingInput> feedings = const [],
    List<TransitionInput> transitions = const [],
  }) {
    final items = <PlannedNotification>[];
    for (final due in dues) {
      items.addAll(_due(due, now));
    }
    for (final expiry in expiries) {
      items.addAll(_expiry(expiry, now));
    }
    for (final bag in opened) {
      items.addAll(_opened(bag, now));
    }
    for (final feeding in feedings) {
      final next = _feeding(feeding, now);
      if (next != null) items.add(next);
    }
    for (final transition in transitions) {
      items.addAll(_transition(transition, now));
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
      titleFor: (offset) => offset == 0
          ? '${due.catName}的$kind提醒'
          : '${due.catName}的$kind将至',
      bodyFor: (offset) => offset == 0
          ? '今天是「${due.label}」的计划日期。这只是提醒，不能代替兽医判断。'
          : '还有 7 天到「${due.label}」的计划日期。',
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

  PlannedNotification? _feeding(FeedingInput feeding, DateTime now) {
    if (!feeding.enabled) return null;
    var when = atTime(now, feeding.hour, feeding.minute);
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }
    final slotName = feeding.slot == 0 ? '早餐' : '晚餐';
    return PlannedNotification(
      id: 50000000 + feeding.catId * 10 + feeding.slot,
      when: when,
      title: '该喂${feeding.catName}了',
      body: '$slotName时间到了。记得按今天的分量记录。',
      channel: ReminderChannel.feeding,
      repeatsDaily: true,
    );
  }

  List<PlannedNotification> _transition(TransitionInput plan, DateTime now) {
    final items = <PlannedNotification>[];
    for (var day = 1; day <= plan.days; day++) {
      final when = atTime(
        dateOnly(plan.startDate).add(Duration(days: day - 1)),
        transitionHour,
        transitionMinute,
      );
      if (!when.isAfter(now)) continue;
      final ratio = transitionRatio(day);
      items.add(
        PlannedNotification(
          id: 60000000 + plan.id * 10 + day,
          when: when,
          title: '${plan.catName}换粮第 $day 天',
          body:
              '旧粮 ${plan.fromFood} ${ratio.oldPercent}% ，新粮 ${plan.toFood} ${ratio.newPercent}%。',
          channel: ReminderChannel.feeding,
        ),
      );
    }
    return items;
  }

  List<PlannedNotification> _offsets({
    required DateTime day,
    required DateTime now,
    required List<int> offsets,
    required int Function(int offset) idFor,
    required String Function(int offset) titleFor,
    required String Function(int offset) bodyFor,
    required ReminderChannel channel,
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
        ),
      );
    }
    return items;
  }
}
