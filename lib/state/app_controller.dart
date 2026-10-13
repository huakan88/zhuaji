import 'package:flutter/foundation.dart';

import '../core/format.dart';
import '../domain/dates.dart';
import '../domain/feeding/feeding_math.dart';
import '../domain/health/checkup_catalog.dart';
import '../domain/health/disease_catalog.dart';
import '../domain/models.dart';
import '../domain/reminders/reminder_planner.dart';
import '../domain/repositories/care_repository.dart';
import '../services/notification_service.dart';

class DailyTask {
  const DailyTask({
    required this.title,
    required this.detail,
    required this.done,
  });

  final String title;
  final String detail;
  final bool done;
}

class CareSlice {
  const CareSlice({required this.label, required this.done});

  final String label;
  final bool done;
}

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
  List<CatPhoto> photos = [];
  List<VaccineRecord> vaccines = [];
  List<DewormRecord> deworms = [];
  List<VetRecord> visits = [];
  List<WeightRecord> weights = [];
  List<HealthNote> notes = [];
  List<FeedingRecord> feedings = [];
  List<TransitionPlan> transitions = [];
  List<FeedingReminder> feedingSlots = [];
  List<FoodProduct> products = [];
  List<PantryEntry> pantry = [];
  List<ConditionRecord> conditions = [];
  List<CheckupRecord> checkups = [];
  List<WaterRecord> waters = [];
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
  List<HealthNote> get catNotes =>
      notes.where((item) => item.catId == activeCatId).toList();
  List<FeedingRecord> get catFeedings =>
      feedings.where((item) => item.catId == activeCatId).toList();
  List<ConditionRecord> get catConditions =>
      conditions.where((item) => item.catId == activeCatId).toList();
  List<CheckupRecord> get catCheckups =>
      checkups.where((item) => item.catId == activeCatId).toList();
  List<WaterRecord> get catWaters =>
      waters.where((item) => item.catId == activeCatId).toList();

  double get todayWaterMl => catWaters
      .where((item) => isSameDay(item.loggedOn, now))
      .fold<double>(0, (sum, item) => sum + item.milliliters);

  WeightRecord? get latestWeight =>
      catWeights.isEmpty ? null : catWeights.last;

  List<FeedingRecord> get todayFeedings => catFeedings
      .where((item) => isSameDay(item.loggedAt, now))
      .toList();

  double get todayGrams =>
      todayFeedings.fold<double>(0, (sum, item) => sum + item.grams);

  CalorieEstimate? get calories {
    final weight = latestWeight?.weightKg;
    final cat = active;
    if (weight == null || cat == null) return null;
    return estimateCalories(
      weightKg: weight,
      neutered: cat.neutered,
      kitten: isKitten(cat.birthday, now),
      goal: cat.goal,
      kcalPer100g: _density,
    );
  }

  double? get _density {
    for (final meal in catFeedings) {
      final id = meal.productId;
      if (id == null) continue;
      final product = productById(id);
      if (product?.kcalPer100g != null) return product!.kcalPer100g;
    }
    return null;
  }

  VaccineRecord? get nextVaccine => _soonestDue(catVaccines);
  DewormRecord? get nextInternal => _soonestDeworm(DewormKind.internal);
  DewormRecord? get nextExternal => _soonestDeworm(DewormKind.external);

  PantryEntry? get nearestExpiry {
    final dated = pantry.where((item) => item.item.expiryDate != null).toList()
      ..sort(
        (a, b) => a.item.expiryDate!.compareTo(b.item.expiryDate!),
      );
    return dated.isEmpty ? null : dated.first;
  }

  TransitionPlan? get activeTransition {
    for (final plan in transitions.where((item) => item.catId == activeCatId)) {
      final day = transitionDayNumber(plan.startDate, now);
      if (day >= 1 && day <= plan.days) return plan;
    }
    return null;
  }

  List<FeedingReminder> remindersFor(int catId) =>
      feedingSlots.where((item) => item.catId == catId).toList();

  List<DailyTask> get todayTasks {
    final fed = todayFeedings.isNotEmpty;
    final weighed = catWeights.any(
      (item) => now.difference(item.loggedOn).inDays <= 7,
    );
    final vaccine = nextVaccine;
    final vaccineOk =
        vaccine?.nextDue != null && !dateOnly(vaccine!.nextDue!).isBefore(dateOnly(now));
    return [
      DailyTask(
        title: '今日喂食',
        detail: fed ? '已记录 ${todayGrams.round()} g' : '还没有记下这一餐',
        done: fed,
      ),
      DailyTask(
        title: '一周体重',
        detail: weighed ? '最近 7 天有称重' : '记一次体重，曲线才走得动',
        done: weighed,
      ),
      DailyTask(
        title: '疫苗日期',
        detail: vaccine?.nextDue == null
            ? '还没有下一次日期'
            : formatDate(vaccine!.nextDue!),
        done: vaccineOk,
      ),
    ];
  }

  int get careScore {
    var score = 0;
    if (todayFeedings.isNotEmpty) score++;
    if (catWeights.any((item) => now.difference(item.loggedOn).inDays <= 7)) {
      score++;
    }
    if (_dueOk(nextVaccine?.nextDue)) score++;
    if (_dueOk(nextInternal?.nextDue) && _dueOk(nextExternal?.nextDue)) {
      score++;
    }
    if (active?.avatarPath != null) score++;
    return score;
  }

  String get careLevel {
    final ratio = careScore / 5;
    if (ratio >= 0.8) return '细心铲屎官';
    if (ratio >= 0.4) return '稳定陪伴';
    return '初识爪记';
  }

  String get mood {
    if (careScore >= 4) return '状态不错';
    if (careScore >= 2) return '平稳';
    return '多看一眼';
  }

  List<CareSlice> get careRing => [
    CareSlice(label: '疫苗', done: _dueOk(nextVaccine?.nextDue)),
    CareSlice(label: '体内驱虫', done: _dueOk(nextInternal?.nextDue)),
    CareSlice(label: '体外驱虫', done: _dueOk(nextExternal?.nextDue)),
    CareSlice(label: '体重', done: catWeights.any((item) => now.difference(item.loggedOn).inDays <= 14)),
    CareSlice(label: '今日喂食', done: todayFeedings.isNotEmpty),
  ];

  List<PlannedNotification> get upcoming => _plan().take(6).toList();

  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await repo.seedDemoIfNeeded(now);
      await _read();
      await _reschedule();
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
        return;
      }
      final nextPhotos = await repo.photosOf(id);
      if (epoch != _selectEpoch) return;
      photos = nextPhotos;
      notifyListeners();
    } catch (error, stack) {
      debugPrint('切换猫咪没有完成：$error\n$stack');
    }
  }

  Future<void> enableNotifications() async {
    try {
      await notifications.requestPermissions();
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
    await repo.setSetting('activeCatId', '$id');
    await _refresh();
    return id;
  }

  Future<void> removeCat(int id) async {
    await repo.deleteCat(id);
    if (activeCatId == id) activeCatId = null;
    await _refresh();
  }

  Future<void> addPhoto({
    required String path,
    double? weightKg,
    String note = '',
  }) async {
    final cat = active;
    if (cat == null) return;
    await repo.addPhoto(
      catId: cat.id,
      path: path,
      takenAt: now,
      weightKg: weightKg,
      note: note,
    );
    await _refresh();
  }

  Future<void> removePhoto(int id) async {
    await repo.deletePhoto(id);
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

  Future<void> saveDeworm(DewormDraft draft) async {
    await repo.upsertDeworm(draft);
    await _refresh();
  }

  Future<void> removeDeworm(int id) async {
    await repo.deleteDeworm(id);
    await _refresh();
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

  Future<void> addNote(String content) async {
    final cat = active;
    if (cat == null) return;
    await repo.addNote(catId: cat.id, notedOn: now, content: content);
    await _refresh();
  }

  Future<void> removeNote(int id) async {
    await repo.deleteNote(id);
    await _refresh();
  }

  Future<void> saveFeeding(FeedingDraft draft) async {
    await repo.upsertFeeding(draft);
    await _refresh();
  }

  Future<void> removeFeeding(int id) async {
    await repo.deleteFeeding(id);
    await _refresh();
  }

  Future<void> startTransition({
    required String fromFood,
    required String toFood,
  }) async {
    final cat = active;
    if (cat == null) return;
    await repo.addTransition(
      catId: cat.id,
      fromFood: fromFood,
      toFood: toFood,
      startDate: dateOnly(now),
    );
    await _refresh();
  }

  Future<void> removeTransition(int id) async {
    await repo.deleteTransition(id);
    await _refresh();
  }

  Future<void> saveReminder(FeedingReminder reminder) async {
    await repo.saveFeedingReminder(
      catId: reminder.catId,
      slot: reminder.slot,
      hour: reminder.hour,
      minute: reminder.minute,
      enabled: reminder.enabled,
    );
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
    await repo.addWater(
      catId: cat.id,
      loggedOn: now,
      milliliters: milliliters,
    );
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
    for (final product in products) {
      if (product.barcode == code) return product;
    }
    return null;
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
    notes = await repo.notes();
    feedings = await repo.feedings();
    transitions = await repo.transitions();
    feedingSlots = await repo.feedingReminders();
    products = await repo.products();
    pantry = await repo.pantry();
    conditions = await repo.conditions();
    checkups = await repo.checkups();
    waters = await repo.waters();
    final epoch = _selectEpoch;
    final photoCatId = activeCatId;
    final nextPhotos = photoCatId == null
        ? <CatPhoto>[]
        : await repo.photosOf(photoCatId);
    if (epoch == _selectEpoch && activeCatId == photoCatId) {
      photos = nextPhotos;
    }
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
      feedings: [
        for (final slot in feedingSlots)
          FeedingInput(
            catId: slot.catId,
            catName: _name(slot.catId),
            slot: slot.slot,
            hour: slot.hour,
            minute: slot.minute,
            enabled: slot.enabled,
          ),
      ],
      transitions: [
        for (final plan in transitions)
          if (transitionDayNumber(plan.startDate, now) <= plan.days)
            TransitionInput(
              id: plan.id,
              catName: _name(plan.catId),
              fromFood: plan.fromFood,
              toFood: plan.toFood,
              startDate: plan.startDate,
              days: plan.days,
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
    );
  }

  String _name(int catId) => catById(catId)?.name ?? '猫咪';

  VaccineRecord? _soonestDue(List<VaccineRecord> records) {
    final dated = records.where((item) => item.nextDue != null).toList()
      ..sort((a, b) => a.nextDue!.compareTo(b.nextDue!));
    return dated.isEmpty ? null : dated.first;
  }

  DewormRecord? _soonestDeworm(DewormKind kind) {
    final dated = catDeworms
        .where((item) => item.kind == kind && item.nextDue != null)
        .toList()
      ..sort((a, b) => a.nextDue!.compareTo(b.nextDue!));
    return dated.isEmpty ? null : dated.first;
  }

  bool _dueOk(DateTime? due) =>
      due != null && !dateOnly(due).isBefore(dateOnly(now));
}
