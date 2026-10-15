import '../dates.dart';
import '../models.dart';

/// Remind to restock when the estimate falls to this many days or fewer.
const stockRemindDays = 7;

/// Chips on the bag page. Feeding amount is picked, not typed.
const dailyGramChoices = <int>[30, 40, 50, 60, 80, 100];

class StockEstimate {
  const StockEstimate({
    this.packGrams,
    this.dailyGrams,
    this.remainingGrams,
    this.daysLeft,
    this.runOutOn,
  });

  final double? packGrams;
  final double? dailyGrams;
  final double? remainingGrams;
  final int? daysLeft;
  final DateTime? runOutOn;

  bool get low => daysLeft != null && daysLeft! <= stockRemindDays;
}

/// `2kg`, `1.5 kg`, `85g`, `500克`. Millilitres are not a weight, so they
/// return null and the bag page asks the user to skip the estimate.
double? gramsFromSpec(String spec) {
  final text = spec.replaceAll(' ', '').toLowerCase();
  final match = RegExp(r'(\d+(?:\.\d+)?)(kg|g|千克|公斤|克)').firstMatch(text);
  if (match == null) return null;
  final amount = double.tryParse(match.group(1)!);
  if (amount == null || amount <= 0) return null;
  final unit = match.group(2)!;
  if (unit == 'kg' || unit == '千克' || unit == '公斤') return amount * 1000;
  return amount;
}

/// Full pack until the bag is opened. After that, subtract
/// [dailyGrams] for each day since [openedAt].
StockEstimate estimateStock({
  required String spec,
  required double? dailyGrams,
  required DateTime? openedAt,
  required DateTime today,
}) {
  final pack = gramsFromSpec(spec);
  if (pack == null || dailyGrams == null || dailyGrams <= 0) {
    return StockEstimate(packGrams: pack, dailyGrams: dailyGrams);
  }
  var remaining = pack;
  if (openedAt != null) {
    final eatenDays = dateOnly(today).difference(dateOnly(openedAt)).inDays;
    if (eatenDays > 0) remaining = pack - dailyGrams * eatenDays;
  }
  if (remaining < 0) remaining = 0;
  final days = (remaining / dailyGrams).floor();
  final day = dateOnly(today);
  return StockEstimate(
    packGrams: pack,
    dailyGrams: dailyGrams,
    remainingGrams: remaining,
    daysLeft: days,
    runOutOn: day.add(Duration(days: days)),
  );
}

String stockHint(StockEstimate estimate) {
  if (estimate.packGrams == null) return '包装上没有克数，没法估算';
  if (estimate.dailyGrams == null || estimate.daysLeft == null) {
    return '点一下每天喂多少';
  }
  final days = estimate.daysLeft!;
  if (days <= 0) return '按现在的喂法，今天会吃完';
  if (days <= stockRemindDays) return '大约还能吃 $days 天，该补货了';
  return '大约还能吃 $days 天';
}

/// One sentence for a bag. Eating the pack and the printed date compete;
/// whichever comes first wins, so the row does not show two clocks.
String bagStatus({
  required StockEstimate estimate,
  required DateTime? expiry,
  required DateTime? useBy,
  required DateTime today,
  required bool opened,
}) {
  final eatDays = estimate.daysLeft;
  DateTime? sooner;
  for (final date in [expiry, useBy]) {
    if (date == null) continue;
    final day = dateOnly(date);
    if (sooner == null || day.isBefore(sooner)) sooner = day;
  }
  final expireDays = sooner == null ? null : calendarDaysUntil(today, sooner);
  if (eatDays != null && (expireDays == null || eatDays <= expireDays)) {
    if (eatDays <= 0) return '今天会吃完';
    if (eatDays <= stockRemindDays) return '快吃完，还能吃 $eatDays 天';
    return '还能吃 $eatDays 天';
  }
  if (expireDays != null) {
    if (expireDays < 0) return '已过期';
    if (expireDays == 0) return opened ? '今天到期' : '没开封，今天到期';
    if (expireDays <= stockRemindDays) {
      return opened ? '快到期，还剩 $expireDays 天' : '没开封，还剩 $expireDays 天';
    }
    if (!opened) return '没开封';
    return '还剩 $expireDays 天';
  }
  if (!opened) return '没开封';
  if (estimate.dailyGrams == null && estimate.packGrams != null) {
    return '点一下每天喂多少';
  }
  return '日期还没填';
}

String pantryAckKey(PantryEntry entry) =>
    '${entry.item.id}|${entry.item.expiryDate?.millisecondsSinceEpoch ?? 0}|${entry.item.openedAt?.millisecondsSinceEpoch ?? 0}';

DateTime? openedUseBy(PantryEntry entry) {
  final opened = entry.item.openedAt;
  if (opened == null || entry.openWindowDays <= 0) return null;
  return dateOnly(opened).add(Duration(days: entry.openWindowDays));
}
