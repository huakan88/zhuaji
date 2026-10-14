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

@DataClassName('SyncOutboxRow')
class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()();
  TextColumn get recordKey => text()();
  TextColumn get op => text()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get deviceId => text()();
}

@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  TextColumn get scope => text()();
  TextColumn get cursor => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {scope};
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
    SyncOutbox,
    SyncCursors,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.defaults() => AppDatabase(driftDatabase(name: 'zhuaji'));

  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await migrator.createAll();
      await seedSampleFoods(this);
    },
    onUpgrade: (migrator, from, to) async {
      for (final step in upgradesFrom(from, to)) {
        switch (step) {
          case 2:
            await _createMissing(migrator, catConditions);
            await _createMissing(migrator, checkupLogs);
            await _createMissing(migrator, waterLogs);
          case 3:
            await _createMissing(migrator, syncOutbox);
            await _createMissing(migrator, syncCursors);
        }
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createMissing(Migrator migrator, TableInfo table) async {
    final rows = await customSelect(
      "SELECT 1 AS ok FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable.withString(table.actualTableName)],
    ).get();
    if (rows.isEmpty) await migrator.createTable(table);
  }
}

/// Schema steps this build can apply. Skipping a missing step is how an
/// already-upgraded file stays safe if the upgrade callback runs again.
List<int> upgradesFrom(int from, int to) {
  const steps = [2, 3];
  return [
    for (final step in steps)
      if (step > from && step <= to) step,
  ];
}
