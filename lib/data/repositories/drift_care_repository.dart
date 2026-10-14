import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models.dart';
import '../../domain/repositories/care_repository.dart';
import '../db/app_database.dart';

class DriftCareRepository implements CareRepository {
  DriftCareRepository(this._db);

  final AppDatabase _db;
  var _silent = false;

  @override
  Future<void> close() => _db.close();

  @override
  Future<void> seedDemoIfNeeded(DateTime now) async {
    await seedSampleFoods(_db);
    final seeded = await setting('demoSeeded');
    if (seeded == '1') return;
    final existing = await cats();
    if (existing.isNotEmpty) {
      await setSetting('demoSeeded', '1');
      return;
    }

    final today = DateTime(now.year, now.month, now.day);
    final orangeId = await upsertCat(
      CatDraft(
        name: '橘座',
        sex: CatSex.male,
        birthday: DateTime(now.year - 3, now.month, now.day),
        neutered: true,
        goal: CareGoal.maintain,
        coatColor: '橘白',
        breed: '中华田园猫',
        avatarPath: 'asset:assets/cats/cat-orange.jpg',
        notes: '示例档案，可以编辑或删除。',
        isSample: true,
        recognitionSource: RecognitionSource.mock,
        recognitionConfidence: 0.62,
        recognitionDetail: '示例识别：橘白 / 中华田园猫。请以你的观察为准。',
      ),
    );
    final creamId = await upsertCat(
      CatDraft(
        name: '奶油',
        sex: CatSex.female,
        birthday: DateTime(now.year - 1, now.month, now.day),
        neutered: true,
        goal: CareGoal.maintain,
        coatColor: '乳白',
        breed: '英国短毛猫',
        avatarPath: 'asset:assets/cats/cat-cream.jpg',
        notes: '示例档案。',
        isSample: true,
      ),
    );

    const orangeWeights = [4.62, 4.55, 4.5, 4.48, 4.44, 4.4, 4.38, 4.35];
    for (var i = 0; i < orangeWeights.length; i++) {
      await addWeight(
        catId: orangeId,
        loggedOn: today.subtract(
          Duration(days: (orangeWeights.length - 1 - i) * 7),
        ),
        weightKg: orangeWeights[i],
      );
    }
    for (final entry in [3.8, 3.9, 4.0, 4.05]) {
      final index = [3.8, 3.9, 4.0, 4.05].indexOf(entry);
      await addWeight(
        catId: creamId,
        loggedOn: today.subtract(Duration(days: (3 - index) * 14)),
        weightKg: entry,
      );
    }

    await addPhoto(
      catId: orangeId,
      path: 'asset:assets/cats/cat-orange.jpg',
      takenAt: today.subtract(const Duration(days: 56)),
      weightKg: 4.62,
      note: '示例照片 · 较早体态',
    );
    await addPhoto(
      catId: orangeId,
      path: 'asset:assets/cats/cat-diary.jpg',
      takenAt: today.subtract(const Duration(days: 7)),
      weightKg: 4.35,
      note: '示例照片 · 最近体态',
    );
    await addPhoto(
      catId: creamId,
      path: 'asset:assets/cats/cat-cream.jpg',
      takenAt: today.subtract(const Duration(days: 20)),
      weightKg: 4.05,
      note: '示例照片',
    );

    await upsertVaccine(
      VaccineDraft(
        catId: orangeId,
        name: '猫三联',
        givenOn: today.subtract(const Duration(days: 340)),
        nextDue: today.add(const Duration(days: 18)),
        clinic: '示例社区医院',
        notes: '示例记录',
      ),
    );
    await upsertDeworm(
      DewormDraft(
        catId: orangeId,
        kind: DewormKind.internal,
        product: '示例体内驱虫',
        givenOn: today.subtract(const Duration(days: 80)),
        nextDue: today.add(const Duration(days: 10)),
        notes: '示例记录',
      ),
    );
    await upsertDeworm(
      DewormDraft(
        catId: orangeId,
        kind: DewormKind.external,
        product: '示例体外驱虫',
        givenOn: today.subtract(const Duration(days: 24)),
        nextDue: today.add(const Duration(days: 6)),
      ),
    );
    await upsertVisit(
      VetDraft(
        catId: orangeId,
        visitedOn: today.subtract(const Duration(days: 120)),
        clinic: '示例宠物医院',
        reason: '年度体检',
        diagnosis: '示例：未见明显异常',
        treatment: '继续家庭称重',
        notes: '示例病历，不是真实诊断。',
      ),
    );
    await addNote(
      catId: orangeId,
      notedOn: today.subtract(const Duration(days: 3)),
      content: '毛发顺，食欲正常。示例笔记。',
    );

    final foods = await products();
    FoodProduct? named(String name) {
      for (final item in foods) {
        if (item.name == name) return item;
      }
      return null;
    }

    final royal = named('室内成猫全价粮');
    final honest = named('K1 无谷全价猫粮');
    await upsertFeeding(
      FeedingDraft(
        catId: orangeId,
        loggedAt: DateTime(now.year, now.month, now.day, 8, 10),
        foodName: royal?.displayName ?? '皇家室内成猫粮',
        foodForm: FoodForm.dry,
        grams: 35,
        kcal: royal?.kcalPer100g == null
            ? null
            : 35 * royal!.kcalPer100g! / 100,
        productId: royal?.id,
        slot: MealSlot.breakfast,
      ),
    );
    if (royal != null && honest != null) {
      await addTransition(
        catId: orangeId,
        fromFood: royal.displayName,
        toFood: honest.displayName,
        startDate: today.subtract(const Duration(days: 2)),
      );
      await upsertPantry(
        PantryDraft(
          productId: royal.id,
          productionDate: today.subtract(const Duration(days: 70)),
          expiryDate: today.add(const Duration(days: 20)),
          batch: 'DEMO-11',
          dateSource: DateSource.manual,
          openedAt: today.subtract(const Duration(days: 10)),
          afterOpenDays: royal.afterOpenDays,
        ),
      );
    }
    final wet = named('浓汤大口肉罐');
    if (wet != null) {
      await upsertPantry(
        PantryDraft(
          productId: wet.id,
          productionDate: today.subtract(const Duration(days: 40)),
          expiryDate: today.add(const Duration(days: 200)),
          dateSource: DateSource.gs1,
          batch: 'WET-17',
        ),
      );
    }
    await upsertCondition(
      ConditionDraft(
        catId: orangeId,
        diseaseId: 'ckd',
        diagnosedOn: today.subtract(const Duration(days: 200)),
        stageLabel: 'IRIS 2',
        note: '示例：兽医告知的分期，可以改。',
        nextRecheck: today.add(const Duration(days: 40)),
      ),
    );
    await upsertCheckup(
      CheckupDraft(
        catId: orangeId,
        itemId: 'cbc',
        completedOn: today.subtract(const Duration(days: 40)),
        result: '示例：兽医说血常规在参考范围内',
        nextDue: today.add(const Duration(days: 140)),
      ),
    );
    await addWater(catId: orangeId, loggedOn: today, milliliters: 180);
    await addWater(
      catId: orangeId,
      loggedOn: today.subtract(const Duration(days: 1)),
      milliliters: 160,
    );
    await setSetting('activeCatId', '$orangeId');
    await setSetting('demoSeeded', '1');
  }

  @override
  Future<List<CatProfile>> cats() async {
    final rows = await (_db.select(
      _db.cats,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    return rows.map(_cat).toList();
  }

  @override
  Future<int> upsertCat(CatDraft draft) async {
    final companion = CatsCompanion(
      name: Value(draft.name.trim()),
      sex: Value(draft.sex.name),
      birthday: Value(draft.birthday),
      neutered: Value(draft.neutered),
      goal: Value(draft.goal.name),
      coatColor: Value(_blank(draft.coatColor)),
      breed: Value(_blank(draft.breed)),
      avatarPath: Value(_blank(draft.avatarPath)),
      notes: Value(draft.notes.trim()),
      isSample: Value(draft.isSample),
      recognitionSource: Value(draft.recognitionSource?.name),
      recognitionConfidence: Value(draft.recognitionConfidence),
      recognitionDetail: Value(_blank(draft.recognitionDetail)),
    );
    if (draft.id == null) {
      final id = await _db
          .into(_db.cats)
          .insert(companion.copyWith(createdAt: Value(DateTime.now())));
      await saveFeedingReminder(
        catId: id,
        slot: 0,
        hour: 8,
        minute: 0,
        enabled: true,
      );
      await saveFeedingReminder(
        catId: id,
        slot: 1,
        hour: 18,
        minute: 30,
        enabled: true,
      );
      await _note('cats', id, 'upsert', {
        'id': '$id',
        'name': draft.name.trim(),
      });
      return id;
    }
    await (_db.update(
      _db.cats,
    )..where((t) => t.id.equals(draft.id!))).write(companion);
    await _note('cats', draft.id!, 'upsert', {
      'id': '${draft.id}',
      'name': draft.name.trim(),
    });
    return draft.id!;
  }

  @override
  Future<void> deleteCat(int id) async {
    await (_db.delete(_db.cats)..where((t) => t.id.equals(id))).go();
    await _note('cats', id, 'delete', {'id': '$id'});
  }

  @override
  Future<String?> setting(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> setSetting(String key, String value) {
    return _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
  }

  @override
  Future<List<CatPhoto>> photosOf(int catId) async {
    final rows =
        await (_db.select(_db.catPhotos)
              ..where((t) => t.catId.equals(catId))
              ..orderBy([(t) => OrderingTerm.asc(t.takenAt)]))
            .get();
    return rows
        .map(
          (row) => CatPhoto(
            id: row.id,
            catId: row.catId,
            path: row.path,
            takenAt: row.takenAt,
            weightKg: row.weightKg,
            note: row.note,
          ),
        )
        .toList();
  }

  @override
  Future<int> addPhoto({
    required int catId,
    required String path,
    required DateTime takenAt,
    double? weightKg,
    String note = '',
  }) {
    return _db
        .into(_db.catPhotos)
        .insert(
          CatPhotosCompanion.insert(
            catId: catId,
            path: path,
            takenAt: takenAt,
            weightKg: Value(weightKg),
            note: Value(note),
          ),
        );
  }

  @override
  Future<void> deletePhoto(int id) {
    return (_db.delete(_db.catPhotos)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<VaccineRecord>> vaccines() async {
    final rows = await (_db.select(
      _db.vaccines,
    )..orderBy([(t) => OrderingTerm.desc(t.givenOn)])).get();
    return rows
        .map(
          (row) => VaccineRecord(
            id: row.id,
            catId: row.catId,
            name: row.name,
            givenOn: row.givenOn,
            nextDue: row.nextDue,
            clinic: row.clinic,
            notes: row.notes,
            batch: row.batch,
          ),
        )
        .toList();
  }

  @override
  Future<int> upsertVaccine(VaccineDraft draft) async {
    final companion = VaccinesCompanion(
      catId: Value(draft.catId),
      name: Value(draft.name.trim()),
      givenOn: Value(draft.givenOn),
      nextDue: Value(draft.nextDue),
      clinic: Value(_blank(draft.clinic)),
      notes: Value(draft.notes.trim()),
      batch: Value(_blank(draft.batch)),
    );
    if (draft.id == null) {
      final id = await _db.into(_db.vaccines).insert(companion);
      await _note('vaccines', id, 'upsert', {
        'id': '$id',
        'catId': draft.catId,
        'name': draft.name.trim(),
      });
      return id;
    }
    await (_db.update(
      _db.vaccines,
    )..where((t) => t.id.equals(draft.id!))).write(companion);
    await _note('vaccines', draft.id!, 'upsert', {
      'id': '${draft.id}',
      'catId': draft.catId,
      'name': draft.name.trim(),
    });
    return draft.id!;
  }

  @override
  Future<void> deleteVaccine(int id) async {
    await (_db.delete(_db.vaccines)..where((t) => t.id.equals(id))).go();
    await _note('vaccines', id, 'delete', {'id': '$id'});
  }

  @override
  Future<List<DewormRecord>> deworms() async {
    final rows = await (_db.select(
      _db.dewormings,
    )..orderBy([(t) => OrderingTerm.desc(t.givenOn)])).get();
    return rows
        .map(
          (row) => DewormRecord(
            id: row.id,
            catId: row.catId,
            kind: parseDeworm(row.kind),
            product: row.product,
            givenOn: row.givenOn,
            nextDue: row.nextDue,
            notes: row.notes,
          ),
        )
        .toList();
  }

  @override
  Future<int> upsertDeworm(DewormDraft draft) async {
    final companion = DewormingsCompanion(
      catId: Value(draft.catId),
      kind: Value(draft.kind == DewormKind.external ? 'external' : 'internal'),
      product: Value(draft.product.trim()),
      givenOn: Value(draft.givenOn),
      nextDue: Value(draft.nextDue),
      notes: Value(draft.notes.trim()),
    );
    if (draft.id == null) {
      final id = await _db.into(_db.dewormings).insert(companion);
      await _note('deworms', id, 'upsert', {
        'id': '$id',
        'catId': draft.catId,
        'product': draft.product.trim(),
      });
      return id;
    }
    await (_db.update(
      _db.dewormings,
    )..where((t) => t.id.equals(draft.id!))).write(companion);
    await _note('deworms', draft.id!, 'upsert', {
      'id': '${draft.id}',
      'catId': draft.catId,
      'product': draft.product.trim(),
    });
    return draft.id!;
  }

  @override
  Future<void> deleteDeworm(int id) async {
    await (_db.delete(_db.dewormings)..where((t) => t.id.equals(id))).go();
    await _note('deworms', id, 'delete', {'id': '$id'});
  }

  @override
  Future<List<VetRecord>> visits() async {
    final rows = await (_db.select(
      _db.vetVisits,
    )..orderBy([(t) => OrderingTerm.desc(t.visitedOn)])).get();
    return rows
        .map(
          (row) => VetRecord(
            id: row.id,
            catId: row.catId,
            visitedOn: row.visitedOn,
            clinic: row.clinic,
            reason: row.reason,
            diagnosis: row.diagnosis,
            treatment: row.treatment,
            notes: row.notes,
          ),
        )
        .toList();
  }

  @override
  Future<int> upsertVisit(VetDraft draft) async {
    final companion = VetVisitsCompanion(
      catId: Value(draft.catId),
      visitedOn: Value(draft.visitedOn),
      clinic: Value(_blank(draft.clinic)),
      reason: Value(draft.reason.trim()),
      diagnosis: Value(_blank(draft.diagnosis)),
      treatment: Value(_blank(draft.treatment)),
      notes: Value(draft.notes.trim()),
    );
    if (draft.id == null) {
      final id = await _db.into(_db.vetVisits).insert(companion);
      await _note('visits', id, 'upsert', {
        'id': '$id',
        'catId': draft.catId,
        'reason': draft.reason.trim(),
      });
      return id;
    }
    await (_db.update(
      _db.vetVisits,
    )..where((t) => t.id.equals(draft.id!))).write(companion);
    await _note('visits', draft.id!, 'upsert', {
      'id': '${draft.id}',
      'catId': draft.catId,
      'reason': draft.reason.trim(),
    });
    return draft.id!;
  }

  @override
  Future<void> deleteVisit(int id) async {
    await (_db.delete(_db.vetVisits)..where((t) => t.id.equals(id))).go();
    await _note('visits', id, 'delete', {'id': '$id'});
  }

  @override
  Future<List<WeightRecord>> weights() async {
    final rows = await (_db.select(
      _db.weightLogs,
    )..orderBy([(t) => OrderingTerm.asc(t.loggedOn)])).get();
    return rows
        .map(
          (row) => WeightRecord(
            id: row.id,
            catId: row.catId,
            loggedOn: row.loggedOn,
            weightKg: row.weightKg,
          ),
        )
        .toList();
  }

  @override
  Future<int> addWeight({
    required int catId,
    required DateTime loggedOn,
    required double weightKg,
  }) async {
    final id = await _db
        .into(_db.weightLogs)
        .insert(
          WeightLogsCompanion.insert(
            catId: catId,
            loggedOn: loggedOn,
            weightKg: weightKg,
          ),
        );
    await _note('weights', id, 'upsert', {
      'id': '$id',
      'catId': catId,
      'weightKg': weightKg,
    });
    return id;
  }

  @override
  Future<void> deleteWeight(int id) async {
    await (_db.delete(_db.weightLogs)..where((t) => t.id.equals(id))).go();
    await _note('weights', id, 'delete', {'id': '$id'});
  }

  @override
  Future<List<HealthNote>> notes() async {
    final rows = await (_db.select(
      _db.healthNotes,
    )..orderBy([(t) => OrderingTerm.desc(t.notedOn)])).get();
    return rows
        .map(
          (row) => HealthNote(
            id: row.id,
            catId: row.catId,
            notedOn: row.notedOn,
            content: row.content,
          ),
        )
        .toList();
  }

  @override
  Future<int> addNote({
    required int catId,
    required DateTime notedOn,
    required String content,
  }) {
    return _db
        .into(_db.healthNotes)
        .insert(
          HealthNotesCompanion.insert(
            catId: catId,
            notedOn: notedOn,
            content: content.trim(),
          ),
        );
  }

  @override
  Future<void> deleteNote(int id) {
    return (_db.delete(_db.healthNotes)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<FeedingRecord>> feedings() async {
    final rows = await (_db.select(
      _db.feedingLogs,
    )..orderBy([(t) => OrderingTerm.desc(t.loggedAt)])).get();
    return rows
        .map(
          (row) => FeedingRecord(
            id: row.id,
            catId: row.catId,
            loggedAt: row.loggedAt,
            foodName: row.foodName,
            foodForm: parseFoodForm(row.foodForm),
            grams: row.grams,
            kcal: row.kcal,
            productId: row.productId,
            slot: parseSlot(row.slot),
          ),
        )
        .toList();
  }

  @override
  Future<int> upsertFeeding(FeedingDraft draft) async {
    final companion = FeedingLogsCompanion(
      catId: Value(draft.catId),
      loggedAt: Value(draft.loggedAt),
      foodName: Value(draft.foodName.trim()),
      foodForm: Value(foodFormKey(draft.foodForm)),
      grams: Value(draft.grams),
      kcal: Value(draft.kcal),
      productId: Value(draft.productId),
      slot: Value(slotKey(draft.slot)),
    );
    if (draft.id == null) return _db.into(_db.feedingLogs).insert(companion);
    await (_db.update(
      _db.feedingLogs,
    )..where((t) => t.id.equals(draft.id!))).write(companion);
    return draft.id!;
  }

  @override
  Future<void> deleteFeeding(int id) {
    return (_db.delete(_db.feedingLogs)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<TransitionPlan>> transitions() async {
    final rows = await (_db.select(
      _db.foodTransitions,
    )..orderBy([(t) => OrderingTerm.desc(t.startDate)])).get();
    return rows
        .map(
          (row) => TransitionPlan(
            id: row.id,
            catId: row.catId,
            fromFood: row.fromFood,
            toFood: row.toFood,
            startDate: row.startDate,
            days: row.days,
          ),
        )
        .toList();
  }

  @override
  Future<int> addTransition({
    required int catId,
    required String fromFood,
    required String toFood,
    required DateTime startDate,
    int days = 7,
  }) {
    return _db
        .into(_db.foodTransitions)
        .insert(
          FoodTransitionsCompanion.insert(
            catId: catId,
            fromFood: fromFood.trim(),
            toFood: toFood.trim(),
            startDate: startDate,
            days: Value(days),
          ),
        );
  }

  @override
  Future<void> deleteTransition(int id) {
    return (_db.delete(
      _db.foodTransitions,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<FeedingReminder>> feedingReminders() async {
    final rows = await _db.select(_db.feedingReminders).get();
    return rows
        .map(
          (row) => FeedingReminder(
            id: row.id,
            catId: row.catId,
            slot: row.slot,
            hour: row.hour,
            minute: row.minute,
            enabled: row.enabled,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveFeedingReminder({
    required int catId,
    required int slot,
    required int hour,
    required int minute,
    required bool enabled,
  }) async {
    final existing =
        await (_db.select(_db.feedingReminders)
              ..where((t) => t.catId.equals(catId) & t.slot.equals(slot)))
            .getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.feedingReminders)
          .insert(
            FeedingRemindersCompanion.insert(
              catId: catId,
              slot: slot,
              hour: hour,
              minute: minute,
              enabled: Value(enabled),
            ),
          );
      return;
    }
    await (_db.update(
      _db.feedingReminders,
    )..where((t) => t.id.equals(existing.id))).write(
      FeedingRemindersCompanion(
        hour: Value(hour),
        minute: Value(minute),
        enabled: Value(enabled),
      ),
    );
  }

  @override
  Future<List<FoodProduct>> products() async {
    final rows =
        await (_db.select(_db.foodProducts)..orderBy([
              (t) => OrderingTerm.asc(t.brand),
              (t) => OrderingTerm.asc(t.name),
            ]))
            .get();
    return rows.map(_product).toList();
  }

  @override
  Future<FoodProduct?> productByBarcode(String barcode) async {
    final row = await (_db.select(
      _db.foodProducts,
    )..where((t) => t.barcode.equals(barcode.trim()))).getSingleOrNull();
    return row == null ? null : _product(row);
  }

  @override
  Future<int> upsertProduct(FoodDraft draft) async {
    final barcode = _blank(draft.barcode);
    final companion = FoodProductsCompanion(
      barcode: Value(barcode),
      brand: Value(draft.brand.trim()),
      name: Value(draft.name.trim()),
      spec: Value(draft.spec.trim()),
      foodForm: Value(foodFormKey(draft.foodForm)),
      kcalPer100g: Value(draft.kcalPer100g),
      storageMethod: Value(draft.storageMethod.trim()),
      afterOpenDays: Value(draft.afterOpenDays),
      isSample: Value(draft.isSample),
      flavor: Value(draft.flavor.trim()),
      isCustom: Value(draft.isCustom),
      photoPath: Value(_blank(draft.photoPath)),
    );
    if (draft.id == null) return _db.into(_db.foodProducts).insert(companion);
    await (_db.update(
      _db.foodProducts,
    )..where((t) => t.id.equals(draft.id!))).write(companion);
    return draft.id!;
  }

  @override
  Future<void> deleteProduct(int id) async {
    await (_db.delete(_db.foodProducts)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<PantryEntry>> pantry() async {
    final query = _db.select(_db.pantryItems).join([
      innerJoin(
        _db.foodProducts,
        _db.foodProducts.id.equalsExp(_db.pantryItems.productId),
      ),
    ])..orderBy([OrderingTerm.desc(_db.pantryItems.id)]);
    final rows = await query.get();
    return rows.map((row) {
      final item = row.readTable(_db.pantryItems);
      final product = row.readTable(_db.foodProducts);
      return PantryEntry(
        item: PantryItem(
          id: item.id,
          productId: item.productId,
          productionDate: item.productionDate,
          expiryDate: item.expiryDate,
          batch: item.batch,
          dateSource: parseDateSource(item.dateSource),
          openedAt: item.openedAt,
          afterOpenDays: item.afterOpenDays,
          dailyGrams: item.dailyGrams,
        ),
        product: _product(product),
      );
    }).toList();
  }

  @override
  Future<int> upsertPantry(PantryDraft draft) async {
    final companion = PantryItemsCompanion(
      productId: Value(draft.productId),
      productionDate: Value(draft.productionDate),
      expiryDate: Value(draft.expiryDate),
      batch: Value(_blank(draft.batch)),
      dateSource: Value(draft.dateSource.name),
      openedAt: Value(draft.openedAt),
      afterOpenDays: Value(draft.afterOpenDays),
      dailyGrams: Value(draft.dailyGrams),
    );
    if (draft.id == null) {
      final id = await _db.into(_db.pantryItems).insert(companion);
      await _note('pantry', id, 'upsert', {
        'id': '$id',
        'productId': draft.productId,
      });
      return id;
    }
    await (_db.update(
      _db.pantryItems,
    )..where((t) => t.id.equals(draft.id!))).write(companion);
    await _note('pantry', draft.id!, 'upsert', {
      'id': '${draft.id}',
      'productId': draft.productId,
    });
    return draft.id!;
  }

  @override
  Future<void> deletePantry(int id) async {
    await (_db.delete(_db.pantryItems)..where((t) => t.id.equals(id))).go();
    await _note('pantry', id, 'delete', {'id': '$id'});
  }

  @override
  Future<List<ConditionRecord>> conditions() async {
    final rows = await (_db.select(
      _db.catConditions,
    )..orderBy([(t) => OrderingTerm.desc(t.diagnosedOn)])).get();
    return [
      for (final row in rows)
        ConditionRecord(
          id: row.id,
          catId: row.catId,
          diseaseId: row.diseaseId,
          diagnosedOn: row.diagnosedOn,
          stageLabel: row.stageLabel,
          note: row.note,
          nextRecheck: row.nextRecheck,
        ),
    ];
  }

  @override
  Future<int> upsertCondition(ConditionDraft draft) async {
    final companion = CatConditionsCompanion(
      catId: Value(draft.catId),
      diseaseId: Value(draft.diseaseId),
      diagnosedOn: Value(draft.diagnosedOn),
      stageLabel: Value(draft.stageLabel.trim()),
      note: Value(draft.note.trim()),
      nextRecheck: Value(draft.nextRecheck),
    );
    if (draft.id == null) {
      return _db.into(_db.catConditions).insert(companion);
    }
    await (_db.update(
      _db.catConditions,
    )..where((t) => t.id.equals(draft.id!))).write(companion);
    return draft.id!;
  }

  @override
  Future<void> deleteCondition(int id) {
    return (_db.delete(_db.catConditions)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<CheckupRecord>> checkups() async {
    final rows = await (_db.select(
      _db.checkupLogs,
    )..orderBy([(t) => OrderingTerm.desc(t.completedOn)])).get();
    return [
      for (final row in rows)
        CheckupRecord(
          id: row.id,
          catId: row.catId,
          itemId: row.itemId,
          completedOn: row.completedOn,
          result: row.result,
          nextDue: row.nextDue,
        ),
    ];
  }

  @override
  Future<int> upsertCheckup(CheckupDraft draft) async {
    final companion = CheckupLogsCompanion(
      catId: Value(draft.catId),
      itemId: Value(draft.itemId),
      completedOn: Value(draft.completedOn),
      result: Value(draft.result.trim()),
      nextDue: Value(draft.nextDue),
    );
    if (draft.id == null) return _db.into(_db.checkupLogs).insert(companion);
    await (_db.update(
      _db.checkupLogs,
    )..where((t) => t.id.equals(draft.id!))).write(companion);
    return draft.id!;
  }

  @override
  Future<void> deleteCheckup(int id) {
    return (_db.delete(_db.checkupLogs)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<WaterRecord>> waters() async {
    final rows = await (_db.select(
      _db.waterLogs,
    )..orderBy([(t) => OrderingTerm.desc(t.loggedOn)])).get();
    return [
      for (final row in rows)
        WaterRecord(
          id: row.id,
          catId: row.catId,
          loggedOn: row.loggedOn,
          milliliters: row.milliliters,
        ),
    ];
  }

  @override
  Future<int> addWater({
    required int catId,
    required DateTime loggedOn,
    required double milliliters,
  }) {
    return _db
        .into(_db.waterLogs)
        .insert(
          WaterLogsCompanion.insert(
            catId: catId,
            loggedOn: loggedOn,
            milliliters: milliliters,
          ),
        );
  }

  @override
  Future<void> deleteWater(int id) {
    return (_db.delete(_db.waterLogs)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<LabReport>> labs() async {
    final reports = await (_db.select(_db.labReports)..orderBy([
          (t) => OrderingTerm.desc(t.takenOn),
          (t) => OrderingTerm.desc(t.id),
        ]))
        .get();
    final values = await (_db.select(
      _db.labValues,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    final byReport = <int, List<LabValue>>{};
    for (final row in values) {
      byReport
          .putIfAbsent(row.reportId, () => [])
          .add(
            LabValue(
              id: row.id,
              code: row.code,
              value: row.value,
              unit: row.unit,
              source: row.source == 'manual'
                  ? LabValueSource.manual
                  : LabValueSource.ocr,
              printedLow: row.printedLow,
              printedHigh: row.printedHigh,
            ),
          );
    }
    return [
      for (final row in reports)
        LabReport(
          id: row.id,
          catId: row.catId,
          kind: parseLabKind(row.kind),
          takenOn: row.takenOn,
          photos: _paths(row.photos),
          values: byReport[row.id] ?? const [],
          note: row.note,
          checkupItemId: row.checkupItemId,
          createdAt: row.createdAt,
        ),
    ];
  }

  List<String> _paths(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return [for (final item in decoded) '$item'];
    } catch (_) {}
    return const [];
  }

  @override
  Future<int> upsertLab(LabDraft draft) async {
    final companion = LabReportsCompanion(
      catId: Value(draft.catId),
      kind: Value(labKindKey(draft.kind)),
      takenOn: Value(draft.takenOn),
      photos: Value(jsonEncode(draft.photos)),
      note: Value(draft.note.trim()),
      checkupItemId: Value(draft.checkupItemId),
    );
    if (draft.id == null) {
      return _db
          .into(_db.labReports)
          .insert(companion.copyWith(createdAt: Value(DateTime.now())));
    }
    await (_db.update(
      _db.labReports,
    )..where((t) => t.id.equals(draft.id!))).write(companion);
    return draft.id!;
  }

  @override
  Future<void> deleteLab(int id) async {
    await (_db.delete(_db.labReports)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> setLabValues(int reportId, List<LabValue> values) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.labValues,
      )..where((t) => t.reportId.equals(reportId))).go();
      for (final value in values) {
        await _db
            .into(_db.labValues)
            .insert(
              LabValuesCompanion.insert(
                reportId: reportId,
                code: value.code,
                value: value.value,
                unit: Value(value.unit),
                source: Value(value.source.name),
                printedLow: Value(value.printedLow),
                printedHigh: Value(value.printedHigh),
              ),
            );
      }
    });
  }

  CatProfile _cat(CatRow row) => CatProfile(
    id: row.id,
    name: row.name,
    sex: parseSex(row.sex),
    birthday: row.birthday,
    neutered: row.neutered,
    goal: parseGoal(row.goal),
    coatColor: row.coatColor,
    breed: row.breed,
    avatarPath: row.avatarPath,
    notes: row.notes,
    isSample: row.isSample,
    recognitionSource: switch (row.recognitionSource) {
      'mlkit' => RecognitionSource.mlkit,
      'mock' => RecognitionSource.mock,
      _ => null,
    },
    recognitionConfidence: row.recognitionConfidence,
    recognitionDetail: row.recognitionDetail,
    createdAt: row.createdAt,
  );

  FoodProduct _product(FoodProductRow row) => FoodProduct(
    id: row.id,
    barcode: row.barcode,
    brand: row.brand,
    name: row.name,
    spec: row.spec,
    foodForm: parseFoodForm(row.foodForm),
    kcalPer100g: row.kcalPer100g,
    storageMethod: row.storageMethod,
    afterOpenDays: row.afterOpenDays,
    isSample: row.isSample,
    flavor: row.flavor,
    isCustom: row.isCustom,
    photoPath: row.photoPath,
  );

  Future<String> ensureDeviceId() async {
    final existing = await setting('deviceId');
    if (existing != null && existing.isNotEmpty) return existing;
    final id = 'dev-${DateTime.now().microsecondsSinceEpoch}';
    await setSetting('deviceId', id);
    return id;
  }

  Future<List<SyncOutboxRow>> pendingSync() {
    return (_db.select(
      _db.syncOutbox,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
  }

  Future<void> ackSync(Iterable<int> ids) async {
    final keys = ids.toList();
    if (keys.isEmpty) return;
    await (_db.delete(_db.syncOutbox)..where((t) => t.id.isIn(keys))).go();
  }

  /// Remote apply must not enqueue another copy of the same change.
  Future<T> runSilent<T>(Future<T> Function() action) async {
    final previous = _silent;
    _silent = true;
    try {
      return await action();
    } finally {
      _silent = previous;
    }
  }

  Future<void> _note(
    String entity,
    int id,
    String op,
    Map<String, Object?> payload,
  ) async {
    if (_silent) return;
    await _db
        .into(_db.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            entity: entity,
            recordKey: '$id',
            op: op,
            payload: jsonEncode(payload),
            updatedAt: DateTime.now().toUtc(),
            deviceId: await ensureDeviceId(),
          ),
        );
  }
}

String? _blank(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
