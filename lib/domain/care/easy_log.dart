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

  /// A recent change large enough to mention in one sentence on 今天.
  bool get notable {
    if (days < 7 || days > 90) return false;
    if (percent.abs() >= 0.05) return true;
    return days <= 14 && percent.abs() >= 0.03;
  }
}

/// Compares the latest weight with the sample closest to 30 days earlier.
WeightChange? weightChangeOverMonth(List<WeightRecord> weights) {
  if (weights.length < 2) return null;
  final sorted = [...weights]..sort((a, b) => a.loggedOn.compareTo(b.loggedOn));
  final latest = sorted.last;
  WeightRecord? baseline;
  var strongest = 0.0;
  for (final item in sorted) {
    if (item.loggedOn == latest.loggedOn && item.id == latest.id) continue;
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
    if (days < 7 || days > 90) continue;
    final change = item.weightKg == 0
        ? 0.0
        : ((latest.weightKg - item.weightKg) / item.weightKg).abs();
    if (baseline == null || change > strongest) {
      strongest = change;
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
