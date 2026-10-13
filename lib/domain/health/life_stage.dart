enum LifeStage { kitten, adult, mature, senior }

/// Completed birthdays, using the calendar rather than a 365-day span.
int completedYears(DateTime birthday, DateTime now) {
  var years = now.year - birthday.year;
  final birthdayReached =
      now.month > birthday.month ||
      (now.month == birthday.month && now.day >= birthday.day);
  if (!birthdayReached) years -= 1;
  return years < 0 ? 0 : years;
}

/// AAHA/AAFP feline life stages used by this app:
/// kitten through the first birthday, adult 1–6, mature 7–10, senior 11+.
/// A missing birthday falls back to the adult baseline.
LifeStage lifeStageFor(DateTime? birthday, DateTime now) {
  if (birthday == null) return LifeStage.adult;
  final years = completedYears(birthday, now);
  if (years < 1) return LifeStage.kitten;
  if (years <= 6) return LifeStage.adult;
  if (years <= 10) return LifeStage.mature;
  return LifeStage.senior;
}

String lifeStageLabel(LifeStage stage) => switch (stage) {
  LifeStage.kitten => '幼猫',
  LifeStage.adult => '成年',
  LifeStage.mature => '成熟',
  LifeStage.senior => '老年',
};

String lifeStageRange(LifeStage stage) => switch (stage) {
  LifeStage.kitten => '0–1 岁',
  LifeStage.adult => '1–6 岁',
  LifeStage.mature => '7–10 岁',
  LifeStage.senior => '11 岁以上',
};
