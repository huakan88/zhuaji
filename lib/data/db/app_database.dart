import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';
part 'sample_foods.dart';

@DataClassName('CatRow')
class Cats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get sex => text()();
  DateTimeColumn get birthday => dateTime().nullable()();
  BoolColumn get neutered => boolean().withDefault(const Constant(false))();
  TextColumn get goal => text().withDefault(const Constant('maintain'))();
  TextColumn get coatColor => text().nullable()();
  TextColumn get breed => text().nullable()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get isSample => boolean().withDefault(const Constant(false))();
  TextColumn get recognitionSource => text().nullable()();
  RealColumn get recognitionConfidence => real().nullable()();
  TextColumn get recognitionDetail => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('CatPhotoRow')
class CatPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  TextColumn get path => text()();
  DateTimeColumn get takenAt => dateTime()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
}

@DataClassName('VaccineRow')
class Vaccines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  DateTimeColumn get givenOn => dateTime()();
  DateTimeColumn get nextDue => dateTime().nullable()();
  TextColumn get clinic => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

@DataClassName('DewormRow')
class Dewormings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => text()();
  TextColumn get product => text()();
  DateTimeColumn get givenOn => dateTime()();
  DateTimeColumn get nextDue => dateTime().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

@DataClassName('VetVisitRow')
class VetVisits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get visitedOn => dateTime()();
  TextColumn get clinic => text().nullable()();
  TextColumn get reason => text()();
  TextColumn get diagnosis => text().nullable()();
  TextColumn get treatment => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

@DataClassName('WeightRow')
class WeightLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get loggedOn => dateTime()();
  RealColumn get weightKg => real()();
}

@DataClassName('HealthNoteRow')
class HealthNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get notedOn => dateTime()();
  TextColumn get content => text()();
}

@DataClassName('FeedingRow')
class FeedingLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get loggedAt => dateTime()();
  TextColumn get foodName => text()();
  TextColumn get foodForm => text()();
  RealColumn get grams => real()();
  RealColumn get kcal => real().nullable()();
  IntColumn get productId => integer().nullable().references(
    FoodProducts,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get slot => text()();
}

@DataClassName('TransitionRow')
class FoodTransitions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  TextColumn get fromFood => text()();
  TextColumn get toFood => text()();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get days => integer().withDefault(const Constant(7))();
}

@DataClassName('FoodProductRow')
class FoodProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().nullable().unique()();
  TextColumn get brand => text()();
  TextColumn get name => text()();
  TextColumn get spec => text()();
  TextColumn get foodForm => text()();
  RealColumn get kcalPer100g => real().nullable()();
  TextColumn get storageMethod => text()();
  IntColumn get afterOpenDays => integer()();
  BoolColumn get isSample => boolean().withDefault(const Constant(false))();
}

@DataClassName('PantryRow')
class PantryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId =>
      integer().references(FoodProducts, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get productionDate => dateTime().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get batch => text().nullable()();
  TextColumn get dateSource => text().withDefault(const Constant('none'))();
  DateTimeColumn get openedAt => dateTime().nullable()();
  IntColumn get afterOpenDays => integer().nullable()();
}

@DataClassName('FeedingReminderRow')
class FeedingReminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  IntColumn get slot => integer()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

@DataClassName('CatConditionRow')
class CatConditions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  TextColumn get diseaseId => text()();
  DateTimeColumn get diagnosedOn => dateTime()();
  TextColumn get stageLabel => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get nextRecheck => dateTime().nullable()();
}

@DataClassName('CheckupLogRow')
class CheckupLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  TextColumn get itemId => text()();
  DateTimeColumn get completedOn => dateTime().nullable()();
  TextColumn get result => text().withDefault(const Constant(''))();
  DateTimeColumn get nextDue => dateTime().nullable()();
}

@DataClassName('WaterLogRow')
class WaterLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get loggedOn => dateTime()();
  RealColumn get milliliters => real()();
}

@DataClassName('SettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Cats,
    CatPhotos,
    Vaccines,
    Dewormings,
    VetVisits,
    WeightLogs,
    HealthNotes,
    FeedingLogs,
    FoodTransitions,
    FoodProducts,
    PantryItems,
    FeedingReminders,
    CatConditions,
    CheckupLogs,
    WaterLogs,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.defaults() => AppDatabase(driftDatabase(name: 'zhuaji'));

  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await migrator.createAll();
      await seedSampleFoods(this);
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(catConditions);
        await migrator.createTable(checkupLogs);
        await migrator.createTable(waterLogs);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
