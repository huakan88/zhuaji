import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/format.dart';
import '../domain/care/agenda.dart';
import '../domain/care/easy_log.dart';
import '../domain/dates.dart';
import '../domain/food/stock.dart' as stock;
import '../domain/health/checkup_catalog.dart';
import '../domain/health/disease_catalog.dart';
import '../domain/health/life_stage.dart';
import '../domain/models.dart';
import '../domain/parsing/gs1_parser.dart';
import '../domain/reminders/reminder_planner.dart';
import '../domain/repositories/care_repository.dart';
import '../services/notification_service.dart';
import '../services/widget_bridge.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.repo,
    required this.notifications,
    required this.recognizer,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CareRepository repo;
  final ReminderNotifier notifications;
  final CoatBreedRecognizer recognizer;
  final DateTime Function() _clock;

  bool loading = true;
  String? error;

  List<CatProfile> cats = [];
  int? activeCatId;
  List<VaccineRecord> vaccines = [];
  List<DewormRecord> deworms = [];
  List<VetRecord> visits = [];
  List<WeightRecord> weights = [];
  List<FoodProduct> products = [];
  List<PantryEntry> pantry = [];
  List<ConditionRecord> conditions = [];
  List<CheckupRecord> checkups = [];
  List<WaterRecord> waters = [];
  List<LabReport> labs = [];
  Set<String> weightAcks = {};
  Set<String> pantryAcks = {};

  /// Pantry id to the morning a restock reminder was postponed to.
  Map<int, DateTime> stockSnooze = {};

  /// When false, the Android widget stays blank of names and todos.
  bool widgetEnabled = true;

  /// Barcodes the catalog did not know, mapped to the product the user chose.
  Map<String, int> barcodeMemory = {};

  /// The owner's own weight from the last 「抱猫称」, offered again next time.
  double? ownerWeightKg;
  String? permissionNote;

  DateTime get now => _clock();

  CatProfile? get active {
    for (final cat in cats) {
      if (cat.id == activeCatId) return cat;
    }
    return null;
  }

  List<VaccineRecord> get catVaccines =>
      vaccines.where((item) => item.catId == activeCatId).toList();
  List<DewormRecord> get catDeworms =>
      deworms.where((item) => item.catId == activeCatId).toList();
  List<VetRecord> get catVisits =>
      visits.where((item) => item.catId == activeCatId).toList();
  List<WeightRecord> get catWeights =>
      weights.where((item) => item.catId == activeCatId).toList();
  List<ConditionRecord> get catConditions =>
      conditions.where((item) => item.catId == activeCatId).toList();
  List<CheckupRecord> get catCheckups =>
      checkups.where((item) => item.catId == activeCatId).toList();
  List<WaterRecord> get catWaters =>
      waters.where((item) => item.catId == activeCatId).toList();
  List<LabReport> get catLabs =>
      labs.where((item) => item.catId == activeCatId).toList();

  double get todayWaterMl => catWaters
      .where((item) => isSameDay(item.loggedOn, now))
      .fold<double>(0, (sum, item) => sum + item.milliliters);

  WeightRecord? get latestWeight => catWeights.isEmpty ? null : catWeights.last;

  /// The most recent dose for this cat, so the form starts on "same as last".
  DewormRecord? get lastDeworm {
    DewormRecord? best;
    for (final item in catDeworms) {
      if (best == null || item.givenOn.isAfter(best.givenOn)) best = item;
    }
    return best;
  }

  /// Clinics already visited (any cat), most recent first.
  List<String> get knownClinics {
    final sorted = [...visits]
      ..sort((a, b) {
        final mine = (b.catId == activeCatId ? 1 : 0).compareTo(
          a.catId == activeCatId ? 1 : 0,
        );
        return mine != 0 ? mine : b.visitedOn.compareTo(a.visitedOn);
      });
    final names = <String>[];
    for (final visit in sorted) {
      final name = (visit.clinic ?? '').trim();
      if (name.isNotEmpty && !names.contains(name)) names.add(name);
    }
    return names;
  }

  VaccineRecord? get nextVaccine => _soonestDue(catVaccines);
  DewormRecord? get nextInternal => _soonestDeworm(DewormKind.internal);
  DewormRecord? get nextExternal => _soonestDeworm(DewormKind.external);

  PantryEntry? get nearestExpiry {
    final dated = pantry.where((item) => item.item.expiryDate != null).toList()
      ..sort((a, b) => a.item.expiryDate!.compareTo(b.item.expiryDate!));
    return dated.isEmpty ? null : dated.first;
  }

  void failStart(String message) {
    loading = false;
    error = message;
    notifyListeners();
  }

  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await repo.seedDemoIfNeeded(now);
      await _read();
      await _reschedule();
      await _publishWidget();
    } catch (error) {
      this.error = '本地数据没有打开：$error';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  var _selectEpoch = 0;

  Future<void> selectCat(int id) async {
    final epoch = ++_selectEpoch;
    activeCatId = id;
    notifyListeners();
    try {
      await repo.setSetting('activeCatId', '$id');
      if (epoch != _selectEpoch) {
        final current = activeCatId;
        if (current != null) await repo.setSetting('activeCatId', '$current');
      }
    } catch (error, stack) {
      debugPrint('切换猫咪没有完成：$error\n$stack');
    }
  }

  Future<void> enableNotifications() async {
    try {
      final askedExact = await repo.setting('exactAsked');
      await notifications.requestPermissions(askExactAlarm: askedExact != '1');
      await repo.setSetting('exactAsked', '1');
      await repo.setSetting('notifAsked', '1');
      await _reschedule();
      permissionNote = '已请求通知权限，提醒会按计划送到';
    } catch (error, stack) {
      permissionNote = '通知权限没有打开，记录仍会留在这台手机上';
      debugPrint('通知权限没有打开：$error\n$stack');
    }
    notifyListeners();
  }

  Future<int> saveCat(CatDraft draft) async {
    final id = await repo.upsertCat(draft);
    activeCatId = id;
    await repo.setSetting('activeCatId', '$id');
    await _refresh();
    return id;
  }

  Future<void> removeCat(int id) async {
    await repo.deleteCat(id);
    if (activeCatId == id) activeCatId = null;
    await _refresh();
  }

  Future<void> saveVaccine(VaccineDraft draft) async {
    await repo.upsertVaccine(draft);
    await _refresh();
  }

  Future<void> removeVaccine(int id) async {
    await repo.deleteVaccine(id);
    await _refresh();
  }

  /// Marks this dose done today and moves the next due date forward.
  Future<DateTime> completeVaccine(VaccineRecord record) async {
    final given = dateOnly(now);
    final next = nextVaccineDate(catById(record.catId)?.birthday, given);
    await repo.upsertVaccine(
      VaccineDraft(
        id: record.id,
        catId: record.catId,
        name: record.name,
        givenOn: given,
        nextDue: next,
        clinic: record.clinic,
        notes: record.notes,
        batch: record.batch,
      ),
    );
    await _refresh();
    return next;
  }

  /// Handles 「已完成」 on a due notification. Returns what to tell the user,
  /// or null when the record is gone (deleted since the reminder was set).
  Future<String?> completeFromNotification(String? raw) async {
    final key = DoneKey.parse(raw);
    if (key == null) return null;
    if (key.vaccine) {
      for (final item in vaccines) {
        if (item.id != key.recordId) continue;
        final next = await completeVaccine(item);
        return '${_name(item.catId)}的${item.name}记下了，下次 ${formatDate(next)}';
      }
    } else {
      for (final item in deworms) {
        if (item.id != key.recordId) continue;
        final next = await completeDeworm(item);
        return '${_name(item.catId)}的${item.product}记下了，下次 ${formatDate(next)}';
      }
    }
    return null;
  }

  /// Puts a record back exactly as it was before a one-tap "done".
  Future<void> restoreVaccine(VaccineRecord record) => saveVaccine(
    VaccineDraft(
      id: record.id,
      catId: record.catId,
      name: record.name,
      givenOn: record.givenOn,
      nextDue: record.nextDue,
      clinic: record.clinic,
      notes: record.notes,
      batch: record.batch,
    ),
  );

  Future<void> restoreDeworm(DewormRecord record) => saveDeworm(
    DewormDraft(
      id: record.id,
      catId: record.catId,
      kind: record.kind,
      product: record.product,
      givenOn: record.givenOn,
      nextDue: record.nextDue,
      notes: record.notes,
    ),
  );

  Future<void> saveDeworm(DewormDraft draft) async {
    await repo.upsertDeworm(draft);
    await _refresh();
  }

  Future<void> removeDeworm(int id) async {
    await repo.deleteDeworm(id);
    await _refresh();
  }

  /// Marks this dose done today and schedules the usual 90-day follow-up.
  Future<DateTime> completeDeworm(DewormRecord record) async {
    final given = dateOnly(now);
    final next = given.add(const Duration(days: 90));
    await repo.upsertDeworm(
      DewormDraft(
        id: record.id,
        catId: record.catId,
        kind: record.kind,
        product: record.product,
        givenOn: given,
        nextDue: next,
        notes: record.notes,
      ),
    );
    await _refresh();
    return next;
  }

  Future<void> saveVisit(VetDraft draft) async {
    await repo.upsertVisit(draft);
    await _refresh();
  }

  Future<void> removeVisit(int id) async {
    await repo.deleteVisit(id);
    await _refresh();
  }

  Future<void> addWeight(double kg) async {
    final cat = active;
    if (cat == null) return;
    await repo.addWeight(catId: cat.id, loggedOn: dateOnly(now), weightKg: kg);
    await _refresh();
  }

  Future<void> removeWeight(int id) async {
    await repo.deleteWeight(id);
    await _refresh();
  }

  Future<int> saveProduct(FoodDraft draft) async {
    final id = await repo.upsertProduct(draft);
    await _refresh();
    return id;
  }

  Future<int> savePantry(PantryDraft draft) async {
    final id = await repo.upsertPantry(draft);
    await _refresh();
    return id;
  }

  Future<void> markOpened(PantryEntry entry) async {
    await repo.upsertPantry(
      PantryDraft(
        id: entry.item.id,
        productId: entry.product.id,
        productionDate: entry.item.productionDate,
        expiryDate: entry.item.expiryDate,
        batch: entry.item.batch,
        dateSource: entry.item.dateSource,
        openedAt: now,
        afterOpenDays: entry.openWindowDays,
        dailyGrams: entry.item.dailyGrams,
      ),
    );
    await _refresh();
  }

  Future<void> removePantry(int id) async {
    await repo.deletePantry(id);
    await _refresh();
  }

  ConditionRecord? conditionFor(String diseaseId) {
    for (final item in catConditions) {
      if (item.diseaseId == diseaseId) return item;
    }
    return null;
  }

  List<CheckupRecord> checkupsFor(String itemId) =>
      catCheckups.where((item) => item.itemId == itemId).toList();

  Future<String?> scheduleCheckup({
    required String itemId,
    required int intervalDays,
  }) async {
    final cat = active;
    if (cat == null) return '先选择一只猫';
    final pending = catCheckups.any(
      (item) =>
          item.itemId == itemId &&
          item.nextDue != null &&
          dateOnly(item.nextDue!).isAfter(dateOnly(now)),
    );
    if (pending) return '这项已经有未到的提醒';
    await repo.upsertCheckup(
      CheckupDraft(
        catId: cat.id,
        itemId: itemId,
        nextDue: dateOnly(now).add(Duration(days: intervalDays)),
      ),
    );
    await _refresh();
    return null;
  }

  Future<void> completeCheckup({
    required String itemId,
    required String result,
    required int intervalDays,
  }) async {
    final cat = active;
    if (cat == null) return;
    await repo.upsertCheckup(
      CheckupDraft(
        catId: cat.id,
        itemId: itemId,
        completedOn: dateOnly(now),
        result: result.trim(),
        nextDue: dateOnly(now).add(Duration(days: intervalDays)),
      ),
    );
    await _refresh();
  }

  LabReport? labById(int id) {
    for (final report in labs) {
      if (report.id == id) return report;
    }
    return null;
  }

  Future<int> saveLab(LabDraft draft, {List<LabValue>? values}) async {
    final id = await repo.upsertLab(draft);
    if (values != null) await repo.setLabValues(id, values);
    await _refresh();
    return id;
  }

  /// Replaces the value with the same code, or adds it.
  Future<void> setLabValue(int reportId, LabValue value) async {
    final report = labById(reportId);
    if (report == null) return;
    final next = [
      for (final item in report.values)
        if (item.code != value.code) item,
      value,
    ];
    await repo.setLabValues(reportId, next);
    await _refresh();
  }

  Future<void> removeLabValue(int reportId, String code) async {
    final report = labById(reportId);
    if (report == null) return;
    await repo.setLabValues(reportId, [
      for (final item in report.values)
        if (item.code != code) item,
    ]);
    await _refresh();
  }

  Future<void> removeLab(int id) async {
    await repo.deleteLab(id);
    await _refresh();
  }

  /// One analyte across the active cat's reports, oldest first.
  List<({DateTime date, int reportId, LabValue value})> labTrend(String code) {
    final points = <({DateTime date, int reportId, LabValue value})>[];
    for (final report in catLabs) {
      for (final value in report.values) {
        if (value.code == code) {
          points.add((date: report.takenOn, reportId: report.id, value: value));
        }
      }
    }
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  Future<void> removeCheckup(int id) async {
    await repo.deleteCheckup(id);
    await _refresh();
  }

  Future<void> markDisease({
    required String diseaseId,
    String stageLabel = '',
  }) async {
    final cat = active;
    final info = diseaseById(diseaseId);
    if (cat == null || info == null) return;
    final existing = conditionFor(diseaseId);
    await repo.upsertCondition(
      ConditionDraft(
        id: existing?.id,
        catId: cat.id,
        diseaseId: diseaseId,
        diagnosedOn: existing?.diagnosedOn ?? dateOnly(now),
        stageLabel: stageLabel,
        note: existing?.note ?? '',
        nextRecheck:
            existing?.nextRecheck ??
            dateOnly(now).add(Duration(days: info.recheckDays)),
      ),
    );
    await _refresh();
  }

  Future<void> setRecheck(int id, DateTime date) async {
    ConditionRecord? found;
    for (final item in conditions) {
      if (item.id == id) found = item;
    }
    if (found == null) return;
    await repo.upsertCondition(
      ConditionDraft(
        id: found.id,
        catId: found.catId,
        diseaseId: found.diseaseId,
        diagnosedOn: found.diagnosedOn,
        stageLabel: found.stageLabel,
        note: found.note,
        nextRecheck: dateOnly(date),
      ),
    );
    await _refresh();
  }

  Future<void> removeCondition(int id) async {
    await repo.deleteCondition(id);
    await _refresh();
  }

  Future<void> addWater(double milliliters) async {
    final cat = active;
    if (cat == null) return;
    await repo.addWater(catId: cat.id, loggedOn: now, milliliters: milliliters);
    await _refresh();
  }

  Future<void> removeWater(int id) async {
    await repo.deleteWater(id);
    await _refresh();
  }

  FoodProduct? productById(int id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  FoodProduct? findBarcode(String barcode) {
    final code = barcode.trim();
    final key = barcodeKey(code);
    if (key.isEmpty) return null;
    final remembered = barcodeMemory[key];
    final chosen = remembered == null ? null : productById(remembered);
    if (chosen != null) return chosen;
    for (final product in products) {
      final own = product.barcode;
      if (own == null || own.isEmpty) continue;
      if (own == code || barcodeKey(own) == key) return product;
    }
    return null;
  }

  Future<void> saveOwnerWeight(double kg) async {
    ownerWeightKg = kg;
    await repo.setSetting('ownerWeightKg', kg.toStringAsFixed(2));
    notifyListeners();
  }

  /// Saves a user-made food. A scanned [barcode] is tied to it so the next
  /// scan finds it straight away.
  Future<int> saveFood(FoodDraft draft, {String? barcode}) async {
    final code = barcode?.trim() ?? '';
    final owner = code.isEmpty ? null : findBarcode(code);
    final keepOwn = code.isNotEmpty && (owner == null || owner.id == draft.id);
    final id = await repo.upsertProduct(
      FoodDraft(
        id: draft.id,
        barcode: keepOwn ? code : draft.barcode,
        brand: draft.brand,
        name: draft.name,
        spec: draft.spec,
        foodForm: draft.foodForm,
        kcalPer100g: draft.kcalPer100g,
        storageMethod: draft.storageMethod,
        afterOpenDays: draft.afterOpenDays,
        isSample: false,
        flavor: draft.flavor,
        isCustom: true,
        photoPath: draft.photoPath,
      ),
    );
    if (code.isNotEmpty) {
      final key = barcodeKey(code);
      if (key.isNotEmpty) barcodeMemory[key] = id;
      await repo.setSetting('barcodeMemory', jsonEncode(barcodeMemory));
    }
    await _refresh();
    return id;
  }

  int pantryCountOf(int productId) =>
      pantry.where((entry) => entry.product.id == productId).length;

  /// Removes a food and every bag of it in the pantry.
  Future<void> deleteFood(int id) async {
    await repo.deleteProduct(id);
    barcodeMemory.removeWhere((_, value) => value == id);
    await repo.setSetting('barcodeMemory', jsonEncode(barcodeMemory));
    await _refresh();
  }

  /// Next scan of [barcode] goes straight to [productId].
  Future<void> rememberBarcode(String barcode, int productId) async {
    final key = barcodeKey(barcode);
    if (key.isEmpty) return;
    barcodeMemory[key] = productId;
    await repo.setSetting('barcodeMemory', jsonEncode(barcodeMemory));
    notifyListeners();
  }

  PantryEntry? pantryById(int id) {
    for (final entry in pantry) {
      if (entry.item.id == id) return entry;
    }
    return null;
  }

  CatProfile? catById(int id) {
    for (final cat in cats) {
      if (cat.id == id) return cat;
    }
    return null;
  }

  Future<void> _refresh() async {
    await _read();
    await _reschedule();
    await _publishWidget();
    notifyListeners();
  }

  Future<void> _read() async {
    cats = await repo.cats();
    final stored = int.tryParse(await repo.setting('activeCatId') ?? '');
    if (activeCatId != null && cats.any((cat) => cat.id == activeCatId)) {
      // keep the in-memory selection
    } else if (stored != null && cats.any((cat) => cat.id == stored)) {
      activeCatId = stored;
    } else {
      activeCatId = cats.isEmpty ? null : cats.first.id;
    }
    vaccines = await repo.vaccines();
    deworms = await repo.deworms();
    visits = await repo.visits();
    weights = await repo.weights();
    products = await repo.products();
    pantry = await repo.pantry();
    conditions = await repo.conditions();
    checkups = await repo.checkups();
    waters = await repo.waters();
    labs = await repo.labs();
    final raw = await repo.setting('weightAcks') ?? '';
    weightAcks = raw.split(',').where((item) => item.isNotEmpty).toSet();
    final pantryRaw = await repo.setting('pantryAcks') ?? '';
    pantryAcks = pantryRaw.split(',').where((item) => item.isNotEmpty).toSet();
    stockSnooze = _decodeSnooze(await repo.setting('stockSnooze'));
    widgetEnabled = (await repo.setting('widgetEnabled') ?? '1') != '0';
    barcodeMemory = _decodeMemory(await repo.setting('barcodeMemory'));
    ownerWeightKg = double.tryParse(await repo.setting('ownerWeightKg') ?? '');
  }

  Map<String, int> _decodeMemory(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return {
        for (final entry in decoded.entries)
          if (entry.value is int) '${entry.key}': entry.value as int,
      };
    } catch (_) {
      return {};
    }
  }

  String pantryAckKey(PantryEntry entry) => stock.pantryAckKey(entry);

  bool pantryAcked(PantryEntry entry) =>
      pantryAcks.contains(pantryAckKey(entry));

  Future<void> ackPantry(PantryEntry entry) async {
    pantryAcks.add(pantryAckKey(entry));
    await repo.setSetting('pantryAcks', pantryAcks.join(','));
    notifyListeners();
  }

  Future<void> unackPantry(PantryEntry entry) async {
    pantryAcks.remove(pantryAckKey(entry));
    await repo.setSetting('pantryAcks', pantryAcks.join(','));
    notifyListeners();
  }

  List<AgendaItem> agenda() => buildAgenda(
    now: now,
    cats: cats,
    vaccines: vaccines,
    deworms: deworms,
    checkups: checkups,
    conditions: conditions,
    pantry: pantry,
    ackedPantryKeys: pantryAcks,
    stockSnooze: stockSnooze,
  );

  Future<void> setWidgetEnabled(bool value) async {
    widgetEnabled = value;
    await repo.setSetting('widgetEnabled', value ? '1' : '0');
    await _publishWidget();
    notifyListeners();
  }

  Future<void> setDailyGrams(PantryEntry entry, double grams) async {
    stockSnooze.remove(entry.item.id);
    await _storeSnooze();
    await savePantry(_pantryDraft(entry, dailyGrams: grams));
  }

  Future<void> postponeAgenda(AgendaItem item) async {
    switch (item.kind) {
      case AgendaKind.vaccine:
        final record = _vaccine(item.recordId);
        final due = record?.nextDue;
        if (record == null || due == null) return;
        await saveVaccine(
          VaccineDraft(
            id: record.id,
            catId: record.catId,
            name: record.name,
            givenOn: record.givenOn,
            nextDue: dateOnly(due).add(const Duration(days: 7)),
            clinic: record.clinic,
            notes: record.notes,
            batch: record.batch,
          ),
        );
      case AgendaKind.deworm:
        final record = _deworm(item.recordId);
        final due = record?.nextDue;
        if (record == null || due == null) return;
        await saveDeworm(
          DewormDraft(
            id: record.id,
            catId: record.catId,
            kind: record.kind,
            product: record.product,
            givenOn: record.givenOn,
            nextDue: dateOnly(due).add(const Duration(days: 7)),
            notes: record.notes,
          ),
        );
      case AgendaKind.checkup:
        final record = _checkup(item.recordId);
        final due = record?.nextDue;
        if (record == null || due == null) return;
        await repo.upsertCheckup(
          CheckupDraft(
            id: record.id,
            catId: record.catId,
            itemId: record.itemId,
            completedOn: record.completedOn,
            result: record.result,
            nextDue: dateOnly(due).add(const Duration(days: 7)),
          ),
        );
        await _refresh();
      case AgendaKind.recheck:
        final record = _condition(item.recordId);
        final due = record?.nextRecheck;
        if (record == null || due == null) return;
        await setRecheck(record.id, dateOnly(due).add(const Duration(days: 7)));
      case AgendaKind.expiry:
        final entry = pantryById(item.recordId);
        final due = entry?.item.expiryDate;
        if (entry == null || due == null) return;
        await savePantry(
          _pantryDraft(
            entry,
            expiryDate: dateOnly(due).add(const Duration(days: 7)),
          ),
        );
      case AgendaKind.opened:
        final entry = pantryById(item.recordId);
        if (entry == null) return;
        await savePantry(
          _pantryDraft(entry, afterOpenDays: entry.openWindowDays + 7),
        );
      case AgendaKind.restock:
        stockSnooze[item.recordId] = dateOnly(now).add(const Duration(days: 7));
        await _storeSnooze();
        await _refresh();
    }
  }

  Future<String> completeAgenda(AgendaItem item) async {
    switch (item.kind) {
      case AgendaKind.vaccine:
        final record = _vaccine(item.recordId);
        if (record == null) return '这条已经不在了';
        final next = await completeVaccine(record);
        return '${record.name}记下了，下次 ${formatDate(next)}';
      case AgendaKind.deworm:
        final record = _deworm(item.recordId);
        if (record == null) return '这条已经不在了';
        final next = await completeDeworm(record);
        return '${record.product}记下了，下次 ${formatDate(next)}';
      case AgendaKind.checkup:
        final record = _checkup(item.recordId);
        if (record == null) return '这条已经不在了';
        final days = _checkupInterval(record);
        await repo.upsertCheckup(
          CheckupDraft(
            catId: record.catId,
            itemId: record.itemId,
            completedOn: dateOnly(now),
            result: record.result,
            nextDue: dateOnly(now).add(Duration(days: days)),
          ),
        );
        await _refresh();
        return '体检记下了';
      case AgendaKind.recheck:
        final record = _condition(item.recordId);
        if (record == null) return '这条已经不在了';
        await repo.upsertCondition(
          ConditionDraft(
            id: record.id,
            catId: record.catId,
            diseaseId: record.diseaseId,
            diagnosedOn: record.diagnosedOn,
            stageLabel: record.stageLabel,
            note: record.note,
          ),
        );
        await _refresh();
        return '这次复诊记下了';
      case AgendaKind.expiry:
      case AgendaKind.opened:
        final entry = pantryById(item.recordId);
        if (entry == null) return '这袋已经不在了';
        await ackPantry(entry);
        return '知道了，还在粮仓';
      case AgendaKind.restock:
        final entry = pantryById(item.recordId);
        if (entry == null) return '这袋已经不在了';
        stockSnooze.remove(entry.item.id);
        await _storeSnooze();
        await savePantry(_pantryDraft(entry, openedAt: dateOnly(now)));
        return '按新开的一袋重新算';
    }
  }

  PantryDraft _pantryDraft(
    PantryEntry entry, {
    DateTime? expiryDate,
    DateTime? openedAt,
    int? afterOpenDays,
    double? dailyGrams,
  }) {
    return PantryDraft(
      id: entry.item.id,
      productId: entry.product.id,
      productionDate: entry.item.productionDate,
      expiryDate: expiryDate ?? entry.item.expiryDate,
      batch: entry.item.batch,
      dateSource: entry.item.dateSource,
      openedAt: openedAt ?? entry.item.openedAt,
      afterOpenDays: afterOpenDays ?? entry.item.afterOpenDays,
      dailyGrams: dailyGrams ?? entry.item.dailyGrams,
    );
  }

  int _checkupInterval(CheckupRecord record) {
    final item = checkupById(record.itemId);
    final stage = lifeStageFor(catById(record.catId)?.birthday, now);
    return item?.byStage[stage]?.intervalDays ?? 365;
  }

  VaccineRecord? _vaccine(int id) {
    for (final item in vaccines) {
      if (item.id == id) return item;
    }
    return null;
  }

  DewormRecord? _deworm(int id) {
    for (final item in deworms) {
      if (item.id == id) return item;
    }
    return null;
  }

  CheckupRecord? _checkup(int id) {
    for (final item in checkups) {
      if (item.id == id) return item;
    }
    return null;
  }

  ConditionRecord? _condition(int id) {
    for (final item in conditions) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> _storeSnooze() async {
    await repo.setSetting(
      'stockSnooze',
      jsonEncode({
        for (final entry in stockSnooze.entries)
          '${entry.key}': dateOnly(entry.value).toIso8601String(),
      }),
    );
  }

  Map<int, DateTime> _decodeSnooze(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final parsed = <int, DateTime>{};
      for (final entry in decoded.entries) {
        final id = int.tryParse('${entry.key}');
        final day = DateTime.tryParse('${entry.value}');
        if (id != null && day != null) parsed[id] = dateOnly(day);
      }
      return parsed;
    } catch (_) {
      return {};
    }
  }

  Future<void> _publishWidget() async {
    if (Platform.environment['FLUTTER_TEST'] == 'true') return;
    final copy = widgetEnabled
        ? homeWidgetCopy(now: now, items: agenda())
        : const HomeWidgetCopy(
            todayLines: ['小组件已关闭'],
            nextLine: '打开爪记查看',
            route: '/calendar',
          );
    await WidgetBridge.publish(copy.toJson());
  }

  StockInput? _stockInput(PantryEntry entry) {
    final estimate = stock.estimateStock(
      spec: entry.product.spec,
      dailyGrams: entry.item.dailyGrams,
      openedAt: entry.item.openedAt,
      today: dateOnly(now),
    );
    final runOut = estimate.runOutOn;
    if (!estimate.low || runOut == null) return null;
    final held = stockSnooze[entry.item.id];
    final snoozed = held != null && dateOnly(held).isAfter(dateOnly(now));
    return StockInput(
      id: entry.item.id,
      productName: entry.product.displayName,
      runOut: snoozed ? held : runOut,
      snoozed: snoozed,
    );
  }

  String weightAckKey(int catId, WeightChange change) =>
      '$catId|${change.days}|${change.fromKg}|${change.toKg}';

  bool weightAlertVisible(CatProfile cat) {
    final change = weightChangeOverMonth(
      weights.where((item) => item.catId == cat.id).toList(),
    );
    if (change == null || !change.notable) return false;
    return !weightAcks.contains(weightAckKey(cat.id, change));
  }

  /// Vaccines, deworming and weight alerts due within 30 days for one cat.
  int dueCountFor(CatProfile cat) {
    final soon = dateOnly(now).add(const Duration(days: 30));
    bool due(DateTime? date) => date != null && !dateOnly(date).isAfter(soon);
    var count = 0;
    for (final item in vaccines) {
      if (item.catId == cat.id && due(item.nextDue)) count++;
    }
    for (final item in deworms) {
      if (item.catId == cat.id && due(item.nextDue)) count++;
    }
    if (weightAlertVisible(cat)) count++;
    return count;
  }

  Future<void> ackWeightAlert(CatProfile cat) async {
    final change = weightChangeOverMonth(
      weights.where((item) => item.catId == cat.id).toList(),
    );
    if (change == null) return;
    weightAcks.add(weightAckKey(cat.id, change));
    await repo.setSetting('weightAcks', weightAcks.join(','));
    notifyListeners();
  }

  Future<void> _reschedule() async {
    try {
      await notifications.replaceAll(_plan());
    } catch (error, stack) {
      debugPrint('提醒同步失败：$error\n$stack');
    }
  }

  List<PlannedNotification> _plan() {
    return const ReminderPlanner().plan(
      now: now,
      dues: [
        for (final item in vaccines)
          if (item.nextDue != null)
            DueInput(
              id: item.id,
              catName: _name(item.catId),
              label: item.name,
              dueDate: item.nextDue!,
              vaccine: true,
            ),
        for (final item in deworms)
          if (item.nextDue != null)
            DueInput(
              id: item.id,
              catName: _name(item.catId),
              label: '${dewormLabel(item.kind)} ${item.product}',
              dueDate: item.nextDue!,
              vaccine: false,
            ),
      ],
      expiries: [
        for (final entry in pantry)
          if (entry.item.expiryDate != null)
            ExpiryInput(
              id: entry.item.id,
              productName: entry.product.displayName,
              expiryDate: entry.item.expiryDate!,
            ),
      ],
      opened: [
        for (final entry in pantry)
          if (entry.item.openedAt != null)
            OpenedInput(
              id: entry.item.id,
              productName: entry.product.displayName,
              openedAt: entry.item.openedAt!,
              afterOpenDays: entry.openWindowDays,
            ),
      ],
      followUps: [
        for (final item in checkups)
          if (item.nextDue != null)
            FollowUpInput(
              id: item.id,
              catName: _name(item.catId),
              label: checkupById(item.itemId)?.name ?? '体检',
              dueDate: item.nextDue!,
              recheck: false,
            ),
        for (final item in conditions)
          if (item.nextRecheck != null)
            FollowUpInput(
              id: item.id,
              catName: _name(item.catId),
              label: diseaseById(item.diseaseId)?.name ?? '复查',
              dueDate: item.nextRecheck!,
              recheck: true,
            ),
      ],
      stocks: [
        for (final entry in pantry) ?_stockInput(entry),
      ],
    );
  }

  String _name(int catId) => catById(catId)?.name ?? '猫咪';

  VaccineRecord? _soonestDue(List<VaccineRecord> records) {
    final dated = records.where((item) => item.nextDue != null).toList()
      ..sort((a, b) => a.nextDue!.compareTo(b.nextDue!));
    return dated.isEmpty ? null : dated.first;
  }

  DewormRecord? _soonestDeworm(DewormKind kind) {
    final dated =
        catDeworms
            .where((item) => item.kind == kind && item.nextDue != null)
            .toList()
          ..sort((a, b) => a.nextDue!.compareTo(b.nextDue!));
    return dated.isEmpty ? null : dated.first;
  }
}

/// One key per product code: a GS1 string and the plain EAN-13 printed under
/// it both reduce to the same digits, so either scan finds the memory.
String barcodeKey(String raw) {
  final code = raw.trim();
  if (code.isEmpty) return '';
  final gtin = code.length > 14 ? const Gs1Parser().parse(code).gtin : null;
  final digits = (gtin ?? code).replaceAll(RegExp(r'\s'), '');
  if (RegExp(r'^\d+$').hasMatch(digits)) {
    final trimmed = digits.replaceFirst(RegExp(r'^0+'), '');
    return trimmed.isEmpty ? '0' : trimmed;
  }
  return digits;
}
