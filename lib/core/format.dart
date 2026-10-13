import '../domain/dates.dart';
import '../domain/models.dart';

String formatDate(DateTime date) => '${date.year}年${date.month}月${date.day}日';

String formatMonthDay(DateTime date) => '${date.month}/${date.day}';

String formatClock(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

String sexLabel(CatSex sex) => switch (sex) {
  CatSex.male => '公',
  CatSex.female => '母',
  CatSex.unknown => '未知',
};

String formLabel(FoodForm form) => switch (form) {
  FoodForm.dry => '干粮',
  FoodForm.wet => '湿粮',
  FoodForm.freezeDried => '冻干',
  FoodForm.treat => '零食',
};

String dewormLabel(DewormKind kind) =>
    kind == DewormKind.internal ? '体内驱虫' : '体外驱虫';

String slotLabel(MealSlot slot) => switch (slot) {
  MealSlot.breakfast => '早餐',
  MealSlot.dinner => '晚餐',
  MealSlot.extra => '加餐',
};

String sourceLabel(DateSource source) => switch (source) {
  DateSource.gs1 => '包装码',
  DateSource.ocr => '拍照认的',
  DateSource.manual => '自己点的',
  DateSource.none => '还没记',
};

String greetingFor(DateTime now) {
  if (now.hour < 11) return '上午好';
  if (now.hour < 18) return '下午好';
  return '晚上好';
}

String ageLabel(DateTime? birthday, DateTime now) {
  if (birthday == null) return '年龄未填';
  var months = (now.year - birthday.year) * 12 + now.month - birthday.month;
  if (now.day < birthday.day) months -= 1;
  if (months < 1) return '未满 1 个月';
  if (months < 12) return '$months 个月';
  final years = months ~/ 12;
  final rest = months % 12;
  if (rest == 0) return '$years 岁';
  return '$years 岁 $rest 个月';
}

String countdownLabel(int days) {
  if (days < 0) return '已过期 ${-days} 天';
  if (days == 0) return '今天到期';
  return '还剩 $days 天';
}

String countdownOf(DateTime date, DateTime now) =>
    countdownLabel(calendarDaysUntil(now, date));

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isKitten(DateTime? birthday, DateTime now) {
  if (birthday == null) return false;
  return now.difference(birthday).inDays < 365;
}
