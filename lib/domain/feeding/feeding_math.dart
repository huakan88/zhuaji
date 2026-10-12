import 'dart:math';

import '../models.dart';

class TransitionRatio {
  const TransitionRatio(this.day, this.oldPercent, this.newPercent);

  final int day;
  final int oldPercent;
  final int newPercent;

  String get label => '旧粮 $oldPercent% · 新粮 $newPercent%';
}

/// Classic 7-day switch: 75/25, 75/25, 50/50, 50/50, 25/75, 25/75, 0/100.
TransitionRatio transitionRatio(int day) {
  final safe = day < 1 ? 1 : (day > 7 ? 7 : day);
  final (oldPercent, newPercent) = switch (safe) {
    1 || 2 => (75, 25),
    3 || 4 => (50, 50),
    5 || 6 => (25, 75),
    _ => (0, 100),
  };
  return TransitionRatio(safe, oldPercent, newPercent);
}

int transitionDayNumber(DateTime start, DateTime now) {
  final startDay = DateTime(start.year, start.month, start.day);
  final today = DateTime(now.year, now.month, now.day);
  return today.difference(startDay).inDays + 1;
}

class CalorieEstimate {
  const CalorieEstimate({
    required this.rer,
    required this.mer,
    required this.factor,
    required this.grams,
    required this.kcalPer100g,
    required this.assumedKcal,
  });

  final double rer;
  final double mer;
  final double factor;
  final double? grams;
  final double kcalPer100g;
  final bool assumedKcal;

  String get summary =>
      '估算每日约 ${mer.round()} kcal'
      '${grams == null ? '' : '，约 ${grams!.round()} g'}';
}

/// Resting energy × a life-stage factor. This is a household estimate,
/// not a prescription.
CalorieEstimate estimateCalories({
  required double weightKg,
  required bool neutered,
  required bool kitten,
  required CareGoal goal,
  double? kcalPer100g,
}) {
  final rer = 70 * pow(weightKg <= 0 ? 0.1 : weightKg, 0.75);
  final factor = kitten
      ? 2.5
      : goal == CareGoal.loss
      ? 0.8
      : neutered
      ? 1.2
      : 1.4;
  final mer = rer * factor;
  const fallback = 380.0;
  final density = (kcalPer100g != null && kcalPer100g > 0)
      ? kcalPer100g
      : fallback;
  final grams = mer / (density / 100);
  return CalorieEstimate(
    rer: rer.toDouble(),
    mer: mer.toDouble(),
    factor: factor,
    grams: grams,
    kcalPer100g: density,
    assumedKcal: kcalPer100g == null || kcalPer100g <= 0,
  );
}

double? mealKcal({required double grams, required double? kcalPer100g}) {
  if (kcalPer100g == null || kcalPer100g <= 0 || grams <= 0) return null;
  return grams * kcalPer100g / 100;
}
