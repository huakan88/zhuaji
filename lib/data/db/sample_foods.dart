part of 'app_database.dart';

Future<void> seedSampleFoods(AppDatabase db) async {
  const storageDry = '阴凉干燥处密封保存，避免阳光直射。开封后夹紧封口，防止受潮。';
  const storageWet = '未开封时放在阴凉处。开封后冷藏，并尽快喂完。';
  const storageFreeze = '密封防潮，远离高温。开封后挤出空气再封好。';

  Future<void> add({
    required String barcode,
    required String brand,
    required String name,
    required String spec,
    required String form,
    required double kcal,
    required String storage,
    required int afterOpenDays,
  }) {
    return db
        .into(db.foodProducts)
        .insert(
          FoodProductsCompanion.insert(
            barcode: Value(barcode),
            brand: brand,
            name: name,
            spec: spec,
            foodForm: form,
            kcalPer100g: Value(kcal),
            storageMethod: storage,
            afterOpenDays: afterOpenDays,
            isSample: const Value(true),
          ),
        );
  }

  await add(
    barcode: '6971000000014',
    brand: '皇家 Royal Canin',
    name: '室内成猫全价粮',
    spec: '2kg · 示例规格',
    form: 'dry',
    kcal: 386,
    storage: storageDry,
    afterOpenDays: 42,
  );
  await add(
    barcode: '6971000000021',
    brand: '皇家 Royal Canin',
    name: '幼猫全价粮 K36',
    spec: '2kg · 示例规格',
    form: 'dry',
    kcal: 414,
    storage: storageDry,
    afterOpenDays: 42,
  );
  await add(
    barcode: '6971000000038',
    brand: '皇家 Royal Canin',
    name: '感官盛宴浓汤肉块',
    spec: '85g · 示例规格',
    form: 'wet',
    kcal: 92,
    storage: storageWet,
    afterOpenDays: 2,
  );
  await add(
    barcode: '6971000000045',
    brand: 'Orijen 原始猎食',
    name: '六种鱼猫粮',
    spec: '1.8kg · 示例规格',
    form: 'dry',
    kcal: 406,
    storage: storageDry,
    afterOpenDays: 35,
  );
  await add(
    barcode: '6971000000052',
    brand: 'Acana 爱肯拿',
    name: '农场盛宴猫粮',
    spec: '1.8kg · 示例规格',
    form: 'dry',
    kcal: 392,
    storage: storageDry,
    afterOpenDays: 35,
  );
  await add(
    barcode: '6971000000069',
    brand: 'Acana 爱肯拿',
    name: '草原配方',
    spec: '340g · 示例规格',
    form: 'dry',
    kcal: 388,
    storage: storageDry,
    afterOpenDays: 35,
  );
  await add(
    barcode: '6971000000076',
    brand: '网易严选',
    name: '全价成猫粮',
    spec: '2kg · 示例规格',
    form: 'dry',
    kcal: 370,
    storage: storageDry,
    afterOpenDays: 42,
  );
  await add(
    barcode: '6971000000083',
    brand: '网易严选',
    name: '冻干双拼',
    spec: '1.5kg · 示例规格',
    form: 'freeze',
    kcal: 380,
    storage: storageFreeze,
    afterOpenDays: 30,
  );
  await add(
    barcode: '6971000000090',
    brand: '麦富迪 Myfoodie',
    name: '佰利生鲜成猫粮',
    spec: '1.5kg · 示例规格',
    form: 'dry',
    kcal: 376,
    storage: storageDry,
    afterOpenDays: 42,
  );
  await add(
    barcode: '6971000000106',
    brand: '麦富迪 Myfoodie',
    name: '霸弗生骨肉冻干',
    spec: '100g · 示例规格',
    form: 'freeze',
    kcal: 450,
    storage: storageFreeze,
    afterOpenDays: 30,
  );
  await add(
    barcode: '6971000000113',
    brand: '诚实一口',
    name: 'K1 无谷全价猫粮',
    spec: '1.5kg · 示例规格',
    form: 'dry',
    kcal: 400,
    storage: storageDry,
    afterOpenDays: 42,
  );
  await add(
    barcode: '6971000000120',
    brand: '诚实一口',
    name: 'P40 全价猫粮',
    spec: '2kg · 示例规格',
    form: 'dry',
    kcal: 390,
    storage: storageDry,
    afterOpenDays: 42,
  );
  await add(
    barcode: '6971000000137',
    brand: '网易严选',
    name: '浓汤大口肉罐',
    spec: '85g · 示例规格',
    form: 'wet',
    kcal: 98,
    storage: storageWet,
    afterOpenDays: 2,
  );
  await add(
    barcode: '6971000000144',
    brand: '皇家 Royal Canin',
    name: '幼猫慕斯罐',
    spec: '85g · 示例规格',
    form: 'wet',
    kcal: 105,
    storage: storageWet,
    afterOpenDays: 2,
  );
}
