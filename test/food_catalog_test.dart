import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/photo_store.dart';

void main() {
  test('food catalog leaves unverified numbers empty', () async {
    final database = AppDatabase.memory();
    final repo = DriftCareRepository(database);
    await repo.seedDemoIfNeeded(DateTime(2026, 10, 12));
    final products = await repo.products();
    for (final brand in ['皇家', '渴望', '希尔斯', '百利', '麦富迪', '网易严选', '小佩']) {
      expect(products.any((item) => item.brand.contains(brand)), isTrue);
    }
    expect(products.every((item) => item.barcode == null), isTrue);
    expect(products.every((item) => item.kcalPer100g == null), isTrue);
    expect(
      products.firstWhere((item) => item.name == '室内成猫全价粮').afterOpenDays,
      42,
    );
    expect(
      products.firstWhere((item) => item.name == '幼猫慕斯罐').afterOpenDays,
      2,
    );
    expect(products.firstWhere((item) => item.name == '成猫罐头').afterOpenDays, 7);
    expect(
      products
          .firstWhere(
            (item) =>
                item.brand.contains('渴望') && item.foodForm == FoodForm.wet,
          )
          .afterOpenDays,
      3,
    );
    expect(
      products.firstWhere((item) => item.brand.contains('小佩')).afterOpenDays,
      0,
    );
    await database.close();
  });

  test('orange pixels suggest an orange coat and a domestic-cat breed', () {
    final image = img.Image(width: 48, height: 48);
    img.fill(image, color: img.ColorRgb8(210, 110, 40));
    final suggestion = suggestionForImage(image);
    expect(suggestion.coatColor, anyOf('橘', '狸花', '橘白'));
    expect(suggestion.breedChoices, contains('中华田园猫'));
  });

  test('a subject in the corner is cropped into a square', () {
    final image = img.Image(width: 180, height: 220);
    img.fill(image, color: img.ColorRgb8(250, 250, 250));
    img.fillRect(
      image,
      x1: 8,
      y1: 12,
      x2: 70,
      y2: 96,
      color: img.ColorRgb8(40, 40, 40),
    );
    final cropped = centerCatPhoto(img.encodeJpg(image));
    final decoded = img.decodeImage(cropped!);
    expect(decoded, isNotNull);
    expect(decoded!.width, decoded.height);
    expect(decoded.width, lessThan(180));
  });
}
