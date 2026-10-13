import '../models.dart';

/// Core vaccines: kittens get a short booster window, adults a year.
DateTime nextVaccineDate(DateTime? birthday, DateTime givenOn) {
  if (birthday != null && givenOn.difference(birthday).inDays < 365) {
    return givenOn.add(const Duration(days: 28));
  }
  return givenOn.add(const Duration(days: 365));
}

class WeightChange {
  const WeightChange({
    required this.fromKg,
    required this.toKg,
    required this.days,
  });

  final double fromKg;
  final double toKg;
  final int days;

  double get percent => fromKg == 0 ? 0 : (toKg - fromKg) / fromKg;

  /// About one month, and large enough to mention on the home screen.
  bool get notable => days >= 21 && days <= 40 && percent.abs() >= 0.05;
}

/// Compares the latest weight with the sample closest to 30 days earlier.
WeightChange? weightChangeOverMonth(List<WeightRecord> weights) {
  if (weights.length < 2) return null;
  final sorted = [...weights]..sort((a, b) => a.loggedOn.compareTo(b.loggedOn));
  final latest = sorted.last;
  WeightRecord? baseline;
  var bestGap = 1 << 30;
  for (final item in sorted) {
    if (identical(item, latest)) continue;
    final days =
        DateTime(
              latest.loggedOn.year,
              latest.loggedOn.month,
              latest.loggedOn.day,
            )
            .difference(
              DateTime(
                item.loggedOn.year,
                item.loggedOn.month,
                item.loggedOn.day,
              ),
            )
            .inDays;
    if (days < 21 || days > 40) continue;
    final gap = (days - 30).abs();
    if (gap < bestGap) {
      bestGap = gap;
      baseline = item;
    }
  }
  if (baseline == null) return null;
  final days =
      DateTime(latest.loggedOn.year, latest.loggedOn.month, latest.loggedOn.day)
          .difference(
            DateTime(
              baseline.loggedOn.year,
              baseline.loggedOn.month,
              baseline.loggedOn.day,
            ),
          )
          .inDays;
  return WeightChange(
    fromKg: baseline.weightKg,
    toKg: latest.weightKg,
    days: days,
  );
}
