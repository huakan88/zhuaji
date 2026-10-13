import '../models.dart';

abstract class CareRepository {
  Future<void> seedDemoIfNeeded(DateTime now);
  Future<void> close();

  Future<List<CatProfile>> cats();
  Future<int> upsertCat(CatDraft draft);
  Future<void> deleteCat(int id);

  Future<String?> setting(String key);
  Future<void> setSetting(String key, String value);

  Future<List<CatPhoto>> photosOf(int catId);
  Future<int> addPhoto({
    required int catId,
    required String path,
    required DateTime takenAt,
    double? weightKg,
    String note = '',
  });
  Future<void> deletePhoto(int id);

  Future<List<VaccineRecord>> vaccines();
  Future<int> upsertVaccine(VaccineDraft draft);
  Future<void> deleteVaccine(int id);

  Future<List<DewormRecord>> deworms();
  Future<int> upsertDeworm(DewormDraft draft);
  Future<void> deleteDeworm(int id);

  Future<List<VetRecord>> visits();
  Future<int> upsertVisit(VetDraft draft);
  Future<void> deleteVisit(int id);

  Future<List<WeightRecord>> weights();
  Future<int> addWeight({
    required int catId,
    required DateTime loggedOn,
    required double weightKg,
  });
  Future<void> deleteWeight(int id);

  Future<List<HealthNote>> notes();
  Future<int> addNote({
    required int catId,
    required DateTime notedOn,
    required String content,
  });
  Future<void> deleteNote(int id);

  Future<List<FeedingRecord>> feedings();
  Future<int> upsertFeeding(FeedingDraft draft);
  Future<void> deleteFeeding(int id);

  Future<List<TransitionPlan>> transitions();
  Future<int> addTransition({
    required int catId,
    required String fromFood,
    required String toFood,
    required DateTime startDate,
    int days = 7,
  });
  Future<void> deleteTransition(int id);

  Future<List<FeedingReminder>> feedingReminders();
  Future<void> saveFeedingReminder({
    required int catId,
    required int slot,
    required int hour,
    required int minute,
    required bool enabled,
  });

  Future<List<FoodProduct>> products();
  Future<FoodProduct?> productByBarcode(String barcode);
  Future<int> upsertProduct(FoodDraft draft);

  Future<List<PantryEntry>> pantry();
  Future<int> upsertPantry(PantryDraft draft);
  Future<void> deletePantry(int id);

  Future<List<ConditionRecord>> conditions();
  Future<int> upsertCondition(ConditionDraft draft);
  Future<void> deleteCondition(int id);

  Future<List<CheckupRecord>> checkups();
  Future<int> upsertCheckup(CheckupDraft draft);
  Future<void> deleteCheckup(int id);

  Future<List<WaterRecord>> waters();
  Future<int> addWater({
    required int catId,
    required DateTime loggedOn,
    required double milliliters,
  });
  Future<void> deleteWater(int id);
}
