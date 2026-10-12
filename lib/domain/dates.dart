DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime atTime(DateTime day, int hour, int minute) =>
    DateTime(day.year, day.month, day.day, hour, minute);

int calendarDaysUntil(DateTime from, DateTime to) =>
    dateOnly(to).difference(dateOnly(from)).inDays;

DateTime addMonths(DateTime date, int months) {
  final zeroBased = date.month - 1 + months;
  final year = date.year + (zeroBased ~/ 12);
  final month = zeroBased % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = date.day > lastDay ? lastDay : date.day;
  return DateTime(year, month, day);
}

/// GS1 YY → year, using a ±50 year window around [reference].
int gs1Year(int yy, DateTime reference) {
  final century = (reference.year ~/ 100) * 100;
  var year = century + yy;
  if (year - reference.year > 50) year -= 100;
  if (reference.year - year > 50) year += 100;
  return year;
}

/// YYMMDD. Day `00` means the last day of that month. Returns null if invalid.
DateTime? parseGs1Date(String yymmdd, {DateTime? reference}) {
  if (!RegExp(r'^\d{6}$').hasMatch(yymmdd)) return null;
  final yy = int.parse(yymmdd.substring(0, 2));
  final month = int.parse(yymmdd.substring(2, 4));
  final day = int.parse(yymmdd.substring(4, 6));
  if (month < 1 || month > 12) return null;
  final year = gs1Year(yy, reference ?? DateTime.now());
  final lastDay = DateTime(year, month + 1, 0).day;
  if (day == 0) return DateTime(year, month, lastDay);
  if (day < 1 || day > lastDay) return null;
  return DateTime(year, month, day);
}

DateTime? parseCalendarDate(int year, int month, int day) {
  if (year < 1990 || year > 2100) return null;
  if (month < 1 || month > 12) return null;
  final lastDay = DateTime(year, month + 1, 0).day;
  if (day < 1 || day > lastDay) return null;
  return DateTime(year, month, day);
}
