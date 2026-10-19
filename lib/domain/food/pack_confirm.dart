import '../dates.dart';
import '../models.dart';
import '../parsing/ocr_lines.dart';
import '../parsing/pack_front_parser.dart';

/// How sure the on-device reader is about one field.
///
/// The person always sees the words. A low score never becomes a saved date.
enum FieldMark { recognized, review, missing, edited }

/// Why the photo step did not fill the form. Each one still has 重拍 and 手填.
enum PackFailure { camera, empty, low }

const packFieldKeys = <String>[
  'brand',
  'name',
  'spec',
  'ingredients',
  'production',
  'expiry',
];

const emptyExpiryCopy = '没读到到期日。可以留空保存。这袋不会做临期提醒，也不会猜成一年后。';

const onDeviceOcrCopy = '认字在这台手机上完成，照片不上传。';

const ingredientLeadCaption = '配料前几位按原文标出，方便核对。';

const uncheckedSaveTitle = '还有没核对的内容，确定存进粮仓？';

String fieldMarkLabel(FieldMark mark) => switch (mark) {
  FieldMark.recognized => '识别',
  FieldMark.review => '请核对',
  FieldMark.missing => '未识别',
  FieldMark.edited => '已手改',
};

String failureTitle(PackFailure failure) => switch (failure) {
  PackFailure.camera => '需要相机才能扫描包装',
  PackFailure.empty => '文字不够清晰',
  PackFailure.low => '看不太清',
};

String failureBody(PackFailure failure) => switch (failure) {
  PackFailure.camera => '可以在系统设置里打开相机，也可以手填。认字在这台手机上完成，照片不上传。',
  PackFailure.empty => '重拍包装上的品牌和品名，或直接手填。',
  PackFailure.low => '有的字没把握。可以重拍，也可以改下面的空栏。',
};

FieldMark parseFieldMark(String raw) => switch (raw) {
  'recognized' => FieldMark.recognized,
  'review' => FieldMark.review,
  'edited' => FieldMark.edited,
  _ => FieldMark.missing,
};

PackFailure? parsePackFailure(String raw) => switch (raw) {
  'camera' => PackFailure.camera,
  'empty' => PackFailure.empty,
  'low' => PackFailure.low,
  _ => null,
};

/// Brand and name: 0.75 recognized, 0.50–0.75 check, below 0.50 left blank.
const _nameHigh = 0.75;
const _nameLow = 0.5;

/// Spec is allowed to be empty. 0.70 is enough to call it recognized.
const _specHigh = 0.7;
const _specLow = 0.5;

/// A long ingredient block is always 「请核对」. Below 0.60 it is not filled in.
const _ingredientLow = 0.6;

/// Dates need 0.80. Anything weaker, including a guessed shelf life, stays
/// empty or is marked for a check. Never invent today + 1 year.
const _dateFloor = 0.8;

class PackSheet {
  const PackSheet({
    this.brand = '',
    this.name = '',
    this.spec = '',
    this.ingredients = '',
    this.production,
    this.expiry,
    this.brandMark = FieldMark.missing,
    this.nameMark = FieldMark.missing,
    this.specMark = FieldMark.missing,
    this.ingredientsMark = FieldMark.missing,
    this.productionMark = FieldMark.missing,
    this.expiryMark = FieldMark.missing,
    this.failure,
    this.flavor = '',
    this.form,
  });

  final String brand;
  final String name;
  final String spec;
  final String ingredients;
  final DateTime? production;
  final DateTime? expiry;
  final FieldMark brandMark;
  final FieldMark nameMark;
  final FieldMark specMark;
  final FieldMark ingredientsMark;
  final FieldMark productionMark;
  final FieldMark expiryMark;
  final PackFailure? failure;
  final String flavor;
  final FoodForm? form;

  Map<String, FieldMark> get marks => {
    'brand': brandMark,
    'name': nameMark,
    'spec': specMark,
    'ingredients': ingredientsMark,
    'production': productionMark,
    'expiry': expiryMark,
  };

  int get filledCount => [
    brand,
    name,
    spec,
    ingredients,
    if (production != null) '1',
    if (expiry != null) '1',
  ].where((item) => item.trim().isNotEmpty).length;

  bool get askBeforeSave =>
      marks.values.any((mark) => mark == FieldMark.review);

  bool get expiryUnread => expiry == null;
}

/// Turns one on-device read into the confirm form.
///
/// A missing score (the engine did not grade the line) keeps the text and
/// asks for a check. A low score is dropped, especially a date.
PackSheet sheetFromRead(PackRead read, {List<OcrLine> lines = const []}) {
  final brand = _keep(
    read.brand,
    _score(lines, read.brand),
    high: _nameHigh,
    low: _nameLow,
  );
  final name = _keep(
    read.name,
    _score(lines, read.name),
    high: _nameHigh,
    low: _nameLow,
  );
  final spec = _keep(
    read.spec,
    _score(lines, read.spec),
    high: _specHigh,
    low: _specLow,
  );
  final ingredients = _keep(
    read.ingredients,
    _score(lines, read.ingredients),
    high: 2,
    low: _ingredientLow,
    forceReview: true,
  );
  final production = _keepDate(
    read.productionDate,
    _scoreDate(lines, read.productionDate),
  );
  var expiry = _keepDate(read.expiryDate, _scoreDate(lines, read.expiryDate));
  if (read.expiryUncertain) {
    expiry = (value: null, mark: FieldMark.missing);
  } else if (read.expiryInferred && expiry.value != null) {
    expiry = (value: expiry.value, mark: FieldMark.review);
  }
  final sheet = PackSheet(
    brand: brand.value,
    name: name.value,
    spec: spec.value,
    ingredients: ingredients.value,
    production: production.value,
    expiry: expiry.value,
    brandMark: brand.mark,
    nameMark: name.mark,
    specMark: spec.mark,
    ingredientsMark: ingredients.mark,
    productionMark: production.mark,
    expiryMark: expiry.mark,
    flavor: read.flavor?.trim() ?? '',
    form: read.form,
  );
  final any = sheet.filledCount > 0;
  final saw = !read.isEmpty || read.expiryUncertain;
  return PackSheet(
    brand: sheet.brand,
    name: sheet.name,
    spec: sheet.spec,
    ingredients: sheet.ingredients,
    production: sheet.production,
    expiry: sheet.expiry,
    brandMark: sheet.brandMark,
    nameMark: sheet.nameMark,
    specMark: sheet.specMark,
    ingredientsMark: sheet.ingredientsMark,
    productionMark: sheet.productionMark,
    expiryMark: sheet.expiryMark,
    failure: any ? null : (saw ? PackFailure.low : PackFailure.empty),
    flavor: sheet.flavor,
    form: sheet.form,
  );
}

String confirmProgress(int filled, Map<String, FieldMark> marks) {
  final review = marks.values.where((mark) => mark == FieldMark.review).length;
  final total = packFieldKeys.length;
  if (review == 0) return '已填写 $filled/$total';
  return '已填写 $filled/$total · $review 项请核对';
}

FieldMark markAfterEdit(String value) {
  return value.trim().isEmpty ? FieldMark.missing : FieldMark.edited;
}

/// Marks stored with a draft win. A draft from 2.20.1 has values and no
/// marks: filled fields ask for a check, empty ones stay unrecognized.
Map<String, FieldMark> marksForDraft({
  required Map<String, String> stored,
  required Map<String, String> values,
}) {
  if (stored.isEmpty) {
    return {
      for (final key in packFieldKeys)
        key: (values[key] ?? '').trim().isEmpty
            ? FieldMark.missing
            : FieldMark.review,
    };
  }
  return {
    for (final key in packFieldKeys) key: parseFieldMark(stored[key] ?? ''),
  };
}

bool askBeforeSave(Map<String, FieldMark> marks) {
  return marks.values.any((mark) => mark == FieldMark.review);
}

/// The first few ingredient names, in the order printed. Not a score.
List<String> leadingIngredients(String raw, {int limit = 5}) {
  final out = <String>[];
  for (final part in raw.split(RegExp(r'[、,，;；\n]+'))) {
    final text = part.trim();
    if (text.length < 2 || out.contains(text)) continue;
    out.add(text);
    if (out.length == limit) break;
  }
  return out;
}

bool cameraDenied(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('denied') ||
      text.contains('permission') ||
      text.contains('access_restricted') ||
      text.contains('camera_access');
}

typedef _Kept = ({String value, FieldMark mark});
typedef _KeptDate = ({DateTime? value, FieldMark mark});

_Kept _keep(
  String? raw,
  double? score, {
  required double high,
  required double low,
  bool forceReview = false,
}) {
  final text = raw?.trim() ?? '';
  if (score != null && score < low) {
    return (value: '', mark: FieldMark.missing);
  }
  if (text.isEmpty) return (value: '', mark: FieldMark.missing);
  if (forceReview || score == null || score < high) {
    return (value: text, mark: FieldMark.review);
  }
  return (value: text, mark: FieldMark.recognized);
}

_KeptDate _keepDate(DateTime? raw, double? score) {
  if (raw == null) return (value: null, mark: FieldMark.missing);
  if (score != null && score < _dateFloor) {
    return (value: null, mark: FieldMark.missing);
  }
  final day = dateOnly(raw);
  if (score == null || score < _dateFloor) {
    return (value: day, mark: FieldMark.review);
  }
  return (value: day, mark: FieldMark.recognized);
}

double? _score(List<OcrLine> lines, String? value) {
  final needle = value?.trim() ?? '';
  if (needle.isEmpty || lines.isEmpty) return null;
  return _minScore(lines, (line) => _mentions(line, needle));
}

double? _scoreDate(List<OcrLine> lines, DateTime? date) {
  if (date == null || lines.isEmpty) return null;
  final day = dateOnly(date);
  return _minScore(lines, (line) => _mentionsDate(line, day));
}

double? _minScore(List<OcrLine> lines, bool Function(String text) hit) {
  double? worst;
  for (final line in lines) {
    final text = line.text.trim();
    if (text.isEmpty || !hit(text)) continue;
    final score = line.confidence;
    if (score == null) continue;
    if (worst == null || score < worst) worst = score;
  }
  return worst;
}

bool _mentions(String line, String value) {
  if (line.contains(value)) return true;
  final flatLine = line.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  final flatValue = value.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  if (flatValue.length >= 2 && flatLine.contains(flatValue)) return true;
  for (final token in RegExp(
    r'[\u4e00-\u9fff]{2,}|[A-Za-z]{3,}',
  ).allMatches(value)) {
    final word = token.group(0)!;
    if (line.toUpperCase().contains(word.toUpperCase())) return true;
  }
  return false;
}

bool _mentionsDate(String line, DateTime date) {
  if (!line.contains('${date.year}')) return false;
  final month = '${date.month}';
  final padded = month.padLeft(2, '0');
  return line.contains(month) || line.contains(padded);
}
