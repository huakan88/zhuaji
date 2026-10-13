enum CatSex { male, female, unknown }

enum CareGoal { maintain, loss }

enum FoodForm { dry, wet, freezeDried, treat }

enum DewormKind { internal, external }

enum DateSource { gs1, ocr, manual, none }

enum RecognitionSource { mock, mlkit }

enum MealSlot { breakfast, dinner, extra }

CareGoal parseGoal(String raw) =>
    raw == 'loss' ? CareGoal.loss : CareGoal.maintain;

CatSex parseSex(String raw) => switch (raw) {
  'male' => CatSex.male,
  'female' => CatSex.female,
  _ => CatSex.unknown,
};

FoodForm parseFoodForm(String raw) => switch (raw) {
  'wet' => FoodForm.wet,
  'freeze' => FoodForm.freezeDried,
  'treat' => FoodForm.treat,
  _ => FoodForm.dry,
};

String foodFormKey(FoodForm form) => switch (form) {
  FoodForm.dry => 'dry',
  FoodForm.wet => 'wet',
  FoodForm.freezeDried => 'freeze',
  FoodForm.treat => 'treat',
};

DewormKind parseDeworm(String raw) =>
    raw == 'external' ? DewormKind.external : DewormKind.internal;

DateSource parseDateSource(String raw) => switch (raw) {
  'gs1' => DateSource.gs1,
  'ocr' => DateSource.ocr,
  'manual' => DateSource.manual,
  _ => DateSource.none,
};

MealSlot parseSlot(String raw) => switch (raw) {
  'dinner' => MealSlot.dinner,
  'extra' => MealSlot.extra,
  _ => MealSlot.breakfast,
};

String slotKey(MealSlot slot) => switch (slot) {
  MealSlot.breakfast => 'breakfast',
  MealSlot.dinner => 'dinner',
  MealSlot.extra => 'extra',
};

class CatProfile {
  const CatProfile({
    required this.id,
    required this.name,
    required this.sex,
    required this.neutered,
    required this.goal,
    required this.notes,
    required this.isSample,
    required this.createdAt,
    this.birthday,
    this.coatColor,
    this.breed,
    this.avatarPath,
    this.recognitionSource,
    this.recognitionConfidence,
    this.recognitionDetail,
  });

  final int id;
  final String name;
  final CatSex sex;
  final DateTime? birthday;
  final bool neutered;
  final CareGoal goal;
  final String? coatColor;
  final String? breed;
  final String? avatarPath;
  final String notes;
  final bool isSample;
  final RecognitionSource? recognitionSource;
  final double? recognitionConfidence;
  final String? recognitionDetail;
  final DateTime createdAt;
}

class CatDraft {
  const CatDraft({
    this.id,
    required this.name,
    required this.sex,
    required this.neutered,
    required this.goal,
    this.birthday,
    this.coatColor,
    this.breed,
    this.avatarPath,
    this.notes = '',
    this.isSample = false,
    this.recognitionSource,
    this.recognitionConfidence,
    this.recognitionDetail,
  });

  final int? id;
  final String name;
  final CatSex sex;
  final DateTime? birthday;
  final bool neutered;
  final CareGoal goal;
  final String? coatColor;
  final String? breed;
  final String? avatarPath;
  final String notes;
  final bool isSample;
  final RecognitionSource? recognitionSource;
  final double? recognitionConfidence;
  final String? recognitionDetail;
}

class CatPhoto {
  const CatPhoto({
    required this.id,
    required this.catId,
    required this.path,
    required this.takenAt,
    required this.note,
    this.weightKg,
  });

  final int id;
  final int catId;
  final String path;
  final DateTime takenAt;
  final double? weightKg;
  final String note;
}

class VaccineRecord {
  const VaccineRecord({
    required this.id,
    required this.catId,
    required this.name,
    required this.givenOn,
    required this.notes,
    this.nextDue,
    this.clinic,
  });

  final int id;
  final int catId;
  final String name;
  final DateTime givenOn;
  final DateTime? nextDue;
  final String? clinic;
  final String notes;
}

class VaccineDraft {
  const VaccineDraft({
    this.id,
    required this.catId,
    required this.name,
    required this.givenOn,
    this.nextDue,
    this.clinic,
    this.notes = '',
  });

  final int? id;
  final int catId;
  final String name;
  final DateTime givenOn;
  final DateTime? nextDue;
  final String? clinic;
  final String notes;
}

class DewormRecord {
  const DewormRecord({
    required this.id,
    required this.catId,
    required this.kind,
    required this.product,
    required this.givenOn,
    required this.notes,
    this.nextDue,
  });

  final int id;
  final int catId;
  final DewormKind kind;
  final String product;
  final DateTime givenOn;
  final DateTime? nextDue;
  final String notes;
}

class DewormDraft {
  const DewormDraft({
    this.id,
    required this.catId,
    required this.kind,
    required this.product,
    required this.givenOn,
    this.nextDue,
    this.notes = '',
  });

  final int? id;
  final int catId;
  final DewormKind kind;
  final String product;
  final DateTime givenOn;
  final DateTime? nextDue;
  final String notes;
}

class VetRecord {
  const VetRecord({
    required this.id,
    required this.catId,
    required this.visitedOn,
    required this.reason,
    required this.notes,
    this.clinic,
    this.diagnosis,
    this.treatment,
  });

  final int id;
  final int catId;
  final DateTime visitedOn;
  final String? clinic;
  final String reason;
  final String? diagnosis;
  final String? treatment;
  final String notes;
}

class VetDraft {
  const VetDraft({
    this.id,
    required this.catId,
    required this.visitedOn,
    required this.reason,
    this.clinic,
    this.diagnosis,
    this.treatment,
    this.notes = '',
  });

  final int? id;
  final int catId;
  final DateTime visitedOn;
  final String? clinic;
  final String reason;
  final String? diagnosis;
  final String? treatment;
  final String notes;
}

class WeightRecord {
  const WeightRecord({
    required this.id,
    required this.catId,
    required this.loggedOn,
    required this.weightKg,
  });

  final int id;
  final int catId;
  final DateTime loggedOn;
  final double weightKg;
}

class HealthNote {
  const HealthNote({
    required this.id,
    required this.catId,
    required this.notedOn,
    required this.content,
  });

  final int id;
  final int catId;
  final DateTime notedOn;
  final String content;
}

class FeedingRecord {
  const FeedingRecord({
    required this.id,
    required this.catId,
    required this.loggedAt,
    required this.foodName,
    required this.foodForm,
    required this.grams,
    required this.slot,
    this.productId,
    this.kcal,
  });

  final int id;
  final int catId;
  final DateTime loggedAt;
  final String foodName;
  final FoodForm foodForm;
  final double grams;
  final double? kcal;
  final int? productId;
  final MealSlot slot;
}

class FeedingDraft {
  const FeedingDraft({
    this.id,
    required this.catId,
    required this.loggedAt,
    required this.foodName,
    required this.foodForm,
    required this.grams,
    required this.slot,
    this.productId,
    this.kcal,
  });

  final int? id;
  final int catId;
  final DateTime loggedAt;
  final String foodName;
  final FoodForm foodForm;
  final double grams;
  final double? kcal;
  final int? productId;
  final MealSlot slot;
}

class TransitionPlan {
  const TransitionPlan({
    required this.id,
    required this.catId,
    required this.fromFood,
    required this.toFood,
    required this.startDate,
    required this.days,
  });

  final int id;
  final int catId;
  final String fromFood;
  final String toFood;
  final DateTime startDate;
  final int days;
}

class FeedingReminder {
  const FeedingReminder({
    required this.id,
    required this.catId,
    required this.slot,
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  final int id;
  final int catId;
  final int slot;
  final int hour;
  final int minute;
  final bool enabled;
}

class FoodProduct {
  const FoodProduct({
    required this.id,
    required this.brand,
    required this.name,
    required this.spec,
    required this.foodForm,
    required this.storageMethod,
    required this.afterOpenDays,
    required this.isSample,
    this.barcode,
    this.kcalPer100g,
  });

  final int id;
  final String? barcode;
  final String brand;
  final String name;
  final String spec;
  final FoodForm foodForm;
  final double? kcalPer100g;
  final String storageMethod;
  final int afterOpenDays;
  final bool isSample;

  String get displayName => '$brand $name';
}

class FoodDraft {
  const FoodDraft({
    this.id,
    required this.brand,
    required this.name,
    required this.spec,
    required this.foodForm,
    required this.storageMethod,
    required this.afterOpenDays,
    this.barcode,
    this.kcalPer100g,
    this.isSample = false,
  });

  final int? id;
  final String? barcode;
  final String brand;
  final String name;
  final String spec;
  final FoodForm foodForm;
  final double? kcalPer100g;
  final String storageMethod;
  final int afterOpenDays;
  final bool isSample;
}

class PantryItem {
  const PantryItem({
    required this.id,
    required this.productId,
    required this.dateSource,
    this.productionDate,
    this.expiryDate,
    this.batch,
    this.openedAt,
    this.afterOpenDays,
  });

  final int id;
  final int productId;
  final DateTime? productionDate;
  final DateTime? expiryDate;
  final String? batch;
  final DateSource dateSource;
  final DateTime? openedAt;
  final int? afterOpenDays;
}

class PantryEntry {
  const PantryEntry({required this.item, required this.product});

  final PantryItem item;
  final FoodProduct product;

  int get openWindowDays => item.afterOpenDays ?? product.afterOpenDays;
}

class PantryDraft {
  const PantryDraft({
    this.id,
    required this.productId,
    required this.dateSource,
    this.productionDate,
    this.expiryDate,
    this.batch,
    this.openedAt,
    this.afterOpenDays,
  });

  final int? id;
  final int productId;
  final DateTime? productionDate;
  final DateTime? expiryDate;
  final String? batch;
  final DateSource dateSource;
  final DateTime? openedAt;
  final int? afterOpenDays;
}

class RecognitionSuggestion {
  const RecognitionSuggestion({
    required this.coatColor,
    required this.breed,
    required this.confidence,
    required this.source,
    required this.detail,
    this.coatChoices = const [],
    this.breedChoices = const [],
  });

  final String coatColor;
  final String breed;
  final double confidence;
  final RecognitionSource source;
  final String detail;
  final List<String> coatChoices;
  final List<String> breedChoices;
}

abstract class CoatBreedRecognizer {
  Future<RecognitionSuggestion> recognize(String imagePath);
}

class ConditionRecord {
  const ConditionRecord({
    required this.id,
    required this.catId,
    required this.diseaseId,
    required this.diagnosedOn,
    required this.stageLabel,
    required this.note,
    this.nextRecheck,
  });

  final int id;
  final int catId;
  final String diseaseId;
  final DateTime diagnosedOn;
  final String stageLabel;
  final String note;
  final DateTime? nextRecheck;
}

class ConditionDraft {
  const ConditionDraft({
    this.id,
    required this.catId,
    required this.diseaseId,
    required this.diagnosedOn,
    this.stageLabel = '',
    this.note = '',
    this.nextRecheck,
  });

  final int? id;
  final int catId;
  final String diseaseId;
  final DateTime diagnosedOn;
  final String stageLabel;
  final String note;
  final DateTime? nextRecheck;
}

class CheckupRecord {
  const CheckupRecord({
    required this.id,
    required this.catId,
    required this.itemId,
    required this.result,
    this.completedOn,
    this.nextDue,
  });

  final int id;
  final int catId;
  final String itemId;
  final DateTime? completedOn;
  final String result;
  final DateTime? nextDue;
}

class CheckupDraft {
  const CheckupDraft({
    this.id,
    required this.catId,
    required this.itemId,
    this.completedOn,
    this.result = '',
    this.nextDue,
  });

  final int? id;
  final int catId;
  final String itemId;
  final DateTime? completedOn;
  final String result;
  final DateTime? nextDue;
}

class WaterRecord {
  const WaterRecord({
    required this.id,
    required this.catId,
    required this.loggedOn,
    required this.milliliters,
  });

  final int id;
  final int catId;
  final DateTime loggedOn;
  final double milliliters;
}
