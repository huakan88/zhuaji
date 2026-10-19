import '../dates.dart';
import '../models.dart';
import '../reminders/reminder_planner.dart';

/// A printed or typed expiry can remind. An empty date never does.
bool shouldRemindExpiry(DateTime? expiry) => expiry != null;

/// Near-expiry notifications for bags that actually have a date.
List<ExpiryInput> expiryReminders(Iterable<PantryEntry> entries) {
  return [
    for (final entry in entries)
      if (shouldRemindExpiry(entry.item.expiryDate))
        ExpiryInput(
          id: entry.item.id,
          productName: entry.product.displayName,
          expiryDate: entry.item.expiryDate!,
        ),
  ];
}

class NearExpiryBag {
  const NearExpiryBag({
    required this.pantryId,
    required this.name,
    required this.expiry,
    required this.daysLeft,
  });

  final int pantryId;
  final String name;
  final DateTime expiry;
  final int daysLeft;
}

/// Home card rows. Bags with no expiry are left out, including ones whose
/// photo never produced a date.
List<NearExpiryBag> bagsNearExpiry(
  Iterable<PantryEntry> entries,
  DateTime today, {
  int withinDays = 30,
}) {
  final day = dateOnly(today);
  final items = <NearExpiryBag>[];
  for (final entry in entries) {
    final expiry = entry.item.expiryDate;
    if (!shouldRemindExpiry(expiry)) continue;
    final due = dateOnly(expiry!);
    final days = due.difference(day).inDays;
    if (days > withinDays) continue;
    items.add(
      NearExpiryBag(
        pantryId: entry.item.id,
        name: entry.product.name,
        expiry: due,
        daysLeft: days,
      ),
    );
  }
  items.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
  return items;
}

bool pantryHasUndatedExpiry(Iterable<PantryEntry> entries) {
  return entries.any((entry) => entry.item.expiryDate == null);
}

String nearExpiryLabel(NearExpiryBag bag) {
  final when = bag.daysLeft < 0
      ? '已过期'
      : bag.daysLeft == 0
      ? '今天到期'
      : '还有 ${bag.daysLeft} 天';
  return '${bag.name} · $when';
}
