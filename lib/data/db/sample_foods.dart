part of 'app_database.dart';

/// Catalog rows use only figures taken from a brand's own storage page.
/// Barcode, calories and pack size stay empty when they were not checked.
/// `afterOpenDays` of 0 means the brand page did not give one number.
Future<void> seedSampleFoods(AppDatabase db) async {
  final existing = await db.select(db.foodProducts).get();
  final keys = existing.map((row) => '${row.brand}|${row.name}').toSet();

  Future<void> add({
    required String brand,
    required String name,
    required String form,
    required String storage,
    required int afterOpenDays,
    String spec = '',
  }) async {
    final key = '$brand|$name';
    if (keys.contains(key)) return;
    keys.add(key);
    await db
        .into(db.foodProducts)
        .insert(
          FoodProductsCompanion.insert(
            brand: brand,
            name: name,
            spec: spec,
            foodForm: form,
            storageMethod: storage,
            afterOpenDays: afterOpenDays,
            isSample: const Value(true),
          ),
        );
  }

  const royalDry =
      '皇家新加坡站说明：干粮留在原袋，放进密封容器，两次喂食之间封好。适口性大约能保持 1 个月，密封妥当最长约 6 周。不要冷冻。';
  const royalWet = '皇家美国站说明：湿粮开封后加盖冷藏，1–2 天内喂完。室温放置超过约 2 小时应丢弃。';
  const orijenDry =
      '渴望官网：干粮和冻干留在原包装，卷好袋口；潮湿环境可把整袋放进密封容器。放在室内阴凉干燥处，不必冷藏。开封后的统一天数官网没有写，以包装为准。';
  const orijenWet = '渴望官网：罐头开封后冷藏，剩料 3 天内喂完。赏味期按包装上的日/月/年阅读。';
  const hillsDry = '希尔斯官网：干粮放在阴凉干燥处，保留原袋，不要冷冻，也不要放在车库这类温度不稳的地方。开封后的统一天数没有单独写出。';
  const hillsWet = '希尔斯兽医站：普通罐头开封后加盖，冷藏最多 7 天。a/d 等个别处方罐头更短，以该罐说明为准，这里不代填。';
  const unverified = '这个品牌能确认，但公开页面没有给出统一的开封天数、条码或热量，这些字段留空，请看手中包装。';

  await add(
    brand: '皇家 Royal Canin',
    name: '室内成猫全价粮',
    form: 'dry',
    storage: royalDry,
    afterOpenDays: 42,
  );
  await add(
    brand: '皇家 Royal Canin',
    name: '幼猫全价粮',
    form: 'dry',
    storage: royalDry,
    afterOpenDays: 42,
  );
  await add(
    brand: '皇家 Royal Canin',
    name: '幼猫慕斯罐',
    form: 'wet',
    storage: royalWet,
    afterOpenDays: 2,
  );
  await add(
    brand: 'Orijen 渴望',
    name: '六种鱼猫粮',
    form: 'dry',
    storage: orijenDry,
    afterOpenDays: 0,
  );
  await add(
    brand: 'Orijen 渴望',
    name: '原味鸡猫粮',
    form: 'dry',
    storage: orijenDry,
    afterOpenDays: 0,
  );
  await add(
    brand: 'Orijen 渴望',
    name: '猫罐',
    form: 'wet',
    storage: orijenWet,
    afterOpenDays: 3,
  );
  await add(
    brand: 'Hill\'s 希尔斯',
    name: '室内成猫干粮',
    form: 'dry',
    storage: hillsDry,
    afterOpenDays: 0,
  );
  await add(
    brand: 'Hill\'s 希尔斯',
    name: '成猫罐头',
    form: 'wet',
    storage: hillsWet,
    afterOpenDays: 7,
  );
  await add(
    brand: '百利 Instinct',
    name: '无谷鸡肉猫粮',
    form: 'dry',
    storage: unverified,
    afterOpenDays: 0,
  );
  await add(
    brand: '百利 Instinct',
    name: '猫罐',
    form: 'wet',
    storage: unverified,
    afterOpenDays: 0,
  );
  await add(
    brand: '麦富迪 Myfoodie',
    name: '佰利生鲜成猫粮',
    form: 'dry',
    storage: unverified,
    afterOpenDays: 0,
  );
  await add(
    brand: '网易严选',
    name: '全价成猫粮',
    form: 'dry',
    storage: unverified,
    afterOpenDays: 0,
  );
  await add(
    brand: '网易严选',
    name: '浓汤大口肉罐',
    form: 'wet',
    storage: unverified,
    afterOpenDays: 0,
  );
  await add(
    brand: '小佩 PETKIT',
    name: '全价猫粮',
    form: 'dry',
    storage: unverified,
    afterOpenDays: 0,
  );
  await add(
    brand: 'Acana 爱肯拿',
    name: '农场盛宴猫粮',
    form: 'dry',
    storage: unverified,
    afterOpenDays: 0,
  );
  await add(
    brand: '诚实一口',
    name: 'K1 无谷全价猫粮',
    form: 'dry',
    storage: unverified,
    afterOpenDays: 0,
  );
}
