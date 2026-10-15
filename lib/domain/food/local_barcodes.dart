import '../models.dart';
import 'barcode_lookup.dart';

/// One common cat food whose barcode was copied from a public page.
class LocalCatFood {
  const LocalCatFood({
    required this.barcode,
    required this.brand,
    required this.name,
    required this.spec,
    required this.category,
    required this.sourceNote,
    this.ingredients = '',
    this.nutrients = const [],
    this.imageUrl,
  });

  final String barcode;
  final String brand;
  final String name;
  final String spec;

  /// 干粮、湿粮或零食。
  final String category;
  final String ingredients;
  final List<BarcodeNutrient> nutrients;
  final String? imageUrl;

  /// Where the barcode and the name were read. Not shown on the product card.
  final String sourceNote;

  BarcodeRecord toRecord() {
    return BarcodeRecord(
      code: barcode,
      found: true,
      brand: brand,
      name: name,
      quantity: spec,
      ingredients: ingredients,
      nutrients: nutrients,
      imageUrl: imageUrl,
      source: 'local',
    );
  }
}

/// Built-in cat foods and cans. Real codes only; unknown brands are absent.
const localCatFoods = <LocalCatFood>[
  LocalCatFood(
    barcode: '6958862134620',
    brand: '麦富迪',
    name: '三文鱼双拼全价全期猫粮',
    spec: '2千克',
    category: '干粮',
    sourceNote: '22在线工具箱条码页 https://tiaoma.22tool.com/detail/70edb428aadc4dc3bdbd68c0302c4eef ，公司乖宝宠物食品集团股份有限公司',
  ),
  LocalCatFood(
    barcode: '6906628275179',
    brand: '网易天成',
    name: '浓汤红肉罐头金枪鱼鸡丝',
    spec: '85克×12',
    category: '湿粮',
    sourceNote: '22在线工具箱条码页 https://tiaoma.22tool.com/detail/645e60e4e1db4d7db60244327107c3c1 ，公司杭州网易严选贸易有限公司',
  ),
  LocalCatFood(
    barcode: '6945496203099',
    brand: '顽皮',
    name: '白身吞拿鱼猫罐',
    spec: '85克',
    category: '湿粮',
    sourceNote: '公开商品条码页，商品、品牌与规格和条码成对出现；EAN-13 校验位已核对。公司烟台顽皮宠物用品销售',
  ),
  LocalCatFood(
    barcode: '6917878081946',
    brand: '冠能',
    name: '鸡肉配方成年期全价猫粮',
    spec: '2.5千克',
    category: '干粮',
    sourceNote: '22在线工具箱条码页 https://tiaoma.22tool.com/detail/b2e2563f48664113881691effb570e3e ，公司雀巢(中国)有限公司',
  ),
  LocalCatFood(
    barcode: '6914973700871',
    brand: '伟嘉',
    name: '全价成猫海洋鱼',
    spec: '1.3千克',
    category: '干粮',
    sourceNote: '公开商品条码页，商品、品牌与规格和条码成对出现；EAN-13 校验位已核对。公司玛氏食品(中国)有限公司',
  ),
  LocalCatFood(
    barcode: '6914973107519',
    brand: '伟嘉',
    name: '幼猫海洋鱼妙鲜包',
    spec: '85克',
    category: '湿粮',
    sourceNote: '公开商品条码页，商品、品牌与规格和条码成对出现；EAN-13 校验位已核对。公司玛氏食品(中国)有限公司',
  ),
  LocalCatFood(
    barcode: '6914973700956',
    brand: '伟嘉',
    name: '全价成猫吞拿鱼及三文鱼',
    spec: '1.3千克',
    category: '干粮',
    sourceNote: '22在线工具箱条码页 https://tiaoma.22tool.com/detail/c937144c601447a49f66fcdcb8c167ca ，公司玛氏食品(中国)有限公司',
  ),
  LocalCatFood(
    barcode: '6914973700819',
    brand: '伟嘉',
    name: '全价成猫吞拿鱼及三文鱼',
    spec: '300克',
    category: '干粮',
    sourceNote: '22在线工具箱条码页 https://tiaoma.22tool.com/detail/171eac101d6b448ea0df37b00844734b ，公司玛氏食品(中国)有限公司',
  ),
  LocalCatFood(
    barcode: '9310022807619',
    brand: '伟嘉',
    name: '海洋鱼类猫粮罐头',
    spec: '400克',
    category: '湿粮',
    sourceNote: '22在线工具箱条码页 https://tiaoma.22tool.com/detail/b5faf257b19c4f5eb7346be68f70b05d ，进口商玛氏食品（中国）有限公司',
  ),
  LocalCatFood(
    barcode: '6931187900538',
    brand: '艾尔',
    name: '全价猫粮（含牛肉鲑鱼配方）',
    spec: '500克',
    category: '干粮',
    sourceNote: '22在线工具箱条码页 https://tiaoma.22tool.com/detail/ee308243228941a28df7910303cff0ad ，公司河北荣喜宠物食品有限公司',
  ),
  LocalCatFood(
    barcode: '3182550799669',
    brand: '皇家',
    name: 'Neutered Satiety Balance',
    spec: '12千克',
    category: '干粮',
    sourceNote: 'Open Pet Food Facts 商品页（2026-10-15 上午可打开，下午 502）与 ProductGuru。配料和成分只保留来源页上的开头和保证值，不是完整包装',
    ingredients: 'Protéines de volailles déshydratées, maïs',
    nutrients: [
      BarcodeNutrient(label: '粗蛋白', text: '35 %'),
      BarcodeNutrient(label: '粗脂肪', text: '10 %'),
      BarcodeNutrient(label: '粗纤维', text: '9.2 %'),
      BarcodeNutrient(label: '粗灰分', text: '9.3 %'),
    ],
  ),
  LocalCatFood(
    barcode: '0030111604439',
    brand: '皇家',
    name: 'Intense Beauty thin slices in gravy',
    spec: '24×3 oz',
    category: '湿粮',
    sourceNote: 'UPCitemdb Royal Canin 品牌页，条码与商品名成对列出 https://www.upcitemdb.com/info-royal-canin',
  ),
  LocalCatFood(
    barcode: '0030111626073',
    brand: '皇家',
    name: 'Hair and Skin Care dry',
    spec: '7 lb',
    category: '干粮',
    sourceNote:
        'UPCitemdb Royal Canin 品牌页 https://www.upcitemdb.com/info-royal-canin',
  ),
  LocalCatFood(
    barcode: '0030111630131',
    brand: '皇家',
    name: 'Indoor Beauty and Fit Care 35',
    spec: '6 lb',
    category: '干粮',
    sourceNote:
        'UPCitemdb Royal Canin 品牌页 https://www.upcitemdb.com/info-royal-canin',
  ),
  LocalCatFood(
    barcode: '0030111541666',
    brand: '皇家',
    name: 'Spayed/Neutered Appetite Control',
    spec: '6 lb',
    category: '干粮',
    sourceNote:
        'UPCitemdb Royal Canin 品牌页 https://www.upcitemdb.com/info-royal-canin',
  ),
  LocalCatFood(
    barcode: '0030111541772',
    brand: '皇家',
    name: 'Aging Spayed/Neutered 12+',
    spec: '7 lb',
    category: '干粮',
    sourceNote:
        'UPCitemdb Royal Canin 品牌页 https://www.upcitemdb.com/info-royal-canin',
  ),
  LocalCatFood(
    barcode: '0064992280178',
    brand: '渴望',
    name: 'Orijen Original Cat',
    spec: '17千克',
    category: '干粮',
    sourceNote: 'Open Pet Food Facts 商品页（2026-10-15 上午可打开，下午 502）与 ProductGuru。配料和成分只保留来源页开头，不是完整包装',
    ingredients: 'Fresh chicken (20%), raw turkey (10%)',
    nutrients: [
      BarcodeNutrient(label: '粗蛋白', text: '40 %'),
      BarcodeNutrient(label: '粗脂肪', text: '20 %'),
      BarcodeNutrient(label: '水分', text: '10 %'),
    ],
  ),
  LocalCatFood(
    barcode: '0064992052270',
    brand: '渴望',
    name: 'Orijen grain-free dry cat food',
    spec: '5 lb',
    category: '干粮',
    sourceNote:
        'UPCitemdb Orijen 品牌页，条码与商品名成对列出 https://www.upcitemdb.com/info-orijen',
  ),
  LocalCatFood(
    barcode: '0064992070687',
    brand: '渴望',
    name: 'Orijen fish cat food',
    spec: '15 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Orijen 品牌页 https://www.upcitemdb.com/info-orijen',
  ),
  LocalCatFood(
    barcode: '0064992201401',
    brand: '渴望',
    name: 'Orijen Cat and Kitten',
    spec: '4 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Orijen 品牌页 https://www.upcitemdb.com/info-orijen',
  ),
  LocalCatFood(
    barcode: '0064992092276',
    brand: '渴望',
    name: 'Orijen Regional Red cat',
    spec: '2.27千克',
    category: '干粮',
    sourceNote: 'UPCitemdb 商品页 https://www.upcitemdb.com/upc/64992092276',
  ),
  LocalCatFood(
    barcode: '0064992721831',
    brand: '渴望',
    name: 'Orijen Original entree in bone broth',
    spec: '5.5 oz',
    category: '湿粮',
    sourceNote: 'UPCitemdb 商品页 https://www.upcitemdb.com/upc/64992721831',
  ),
  LocalCatFood(
    barcode: '0064992260361',
    brand: '渴望',
    name: 'Orijen Original freeze-dried cat treats',
    spec: '1.25 oz',
    category: '零食',
    sourceNote: 'UPCitemdb Orijen 品牌页 https://www.upcitemdb.com/info-orijen',
  ),
  LocalCatFood(
    barcode: '0064992684358',
    brand: '渴望',
    name: 'Orijen Tundra freeze-dried cat treats',
    spec: '1.25 oz',
    category: '零食',
    sourceNote: 'UPCitemdb Orijen 品牌页 https://www.upcitemdb.com/info-orijen',
  ),
  LocalCatFood(
    barcode: '0064992611040',
    brand: '爱肯拿',
    name: 'Acana Homestead Harvest',
    spec: '4 lb',
    category: '干粮',
    sourceNote:
        'UPCitemdb Acana 品牌页，条码与商品名成对列出 https://www.upcitemdb.com/info-acana',
  ),
  LocalCatFood(
    barcode: '0064992611101',
    brand: '爱肯拿',
    name: 'Acana Homestead Harvest',
    spec: '见包装',
    category: '干粮',
    sourceNote: 'UPCitemdb Acana 品牌页 https://www.upcitemdb.com/info-acana',
  ),
  LocalCatFood(
    barcode: '0064992612047',
    brand: '爱肯拿',
    name: 'Acana Bountiful Catch',
    spec: '4 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Acana 品牌页 https://www.upcitemdb.com/info-acana',
  ),
  LocalCatFood(
    barcode: '0064992612108',
    brand: '爱肯拿',
    name: 'Acana Bountiful Catch',
    spec: '10 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Acana 品牌页 https://www.upcitemdb.com/info-acana',
  ),
  LocalCatFood(
    barcode: '0064992613044',
    brand: '爱肯拿',
    name: 'Acana Indoor Entree',
    spec: '4 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Acana 品牌页 https://www.upcitemdb.com/info-acana',
  ),
  LocalCatFood(
    barcode: '0064992613105',
    brand: '爱肯拿',
    name: 'Acana Indoor Entree',
    spec: '10 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Acana 品牌页 https://www.upcitemdb.com/info-acana',
  ),
  LocalCatFood(
    barcode: '0064992686048',
    brand: '爱肯拿',
    name: 'Acana Grasslands',
    spec: '4 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Acana 品牌页 https://www.upcitemdb.com/info-acana',
  ),
  LocalCatFood(
    barcode: '0052742035963',
    brand: '希尔斯',
    name: 'Sterilised Cat young adult with duck',
    spec: '3千克',
    category: '干粮',
    sourceNote: 'Open Pet Food Facts 商品页（2026-10-15 上午有名称和图片，没有配料和成分；下午 502）与 ProductGuru',
  ),
  LocalCatFood(
    barcode: '0052742034669',
    brand: '希尔斯',
    name: 'Science Diet kitten wet pouch, chicken',
    spec: '2.8 oz×24',
    category: '湿粮',
    sourceNote: 'UPCitemdb Hill\'s 品牌页 https://www.upcitemdb.com/info-hill%27s',
  ),
  LocalCatFood(
    barcode: '0052742059150',
    brand: '希尔斯',
    name: 'Science Diet sensitive stomach and skin dry',
    spec: '3.5 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Hill\'s 品牌页 https://www.upcitemdb.com/info-hill%27s',
  ),
  LocalCatFood(
    barcode: '0052742012650',
    brand: '希尔斯',
    name: 'Science Diet kitten liver and chicken entree',
    spec: '2.9 oz×24',
    category: '湿粮',
    sourceNote: 'UPCitemdb Hill\'s 品牌页 https://www.upcitemdb.com/info-hill%27s',
  ),
  LocalCatFood(
    barcode: '0052742032269',
    brand: '希尔斯',
    name: 'Science Diet chicken senior 7+ wet',
    spec: '2.8 oz',
    category: '湿粮',
    sourceNote: 'UPCitemdb Hill\'s 品牌页 https://www.upcitemdb.com/info-hill%27s',
  ),
  LocalCatFood(
    barcode: '0052742046341',
    brand: '希尔斯',
    name: 'Science Diet sensitive stomach salmon and tuna pouch',
    spec: '2.8 oz×24',
    category: '湿粮',
    sourceNote: 'UPCitemdb Hill\'s 品牌页 https://www.upcitemdb.com/info-hill%27s',
  ),
  LocalCatFood(
    barcode: '0052742068381',
    brand: '希尔斯',
    name: 'Science Diet indoor salmon and vegetable canned',
    spec: '5.5 oz×24',
    category: '湿粮',
    sourceNote: 'UPCitemdb Hill\'s 品牌页 https://www.upcitemdb.com/info-hill%27s',
  ),
  LocalCatFood(
    barcode: '0052742753409',
    brand: '希尔斯',
    name: 'Science Diet mature adult hairball control dry',
    spec: '7 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb 商品页 https://www.upcitemdb.com/upc/52742753409',
  ),
  LocalCatFood(
    barcode: '0769949658849',
    brand: 'Instinct',
    name: 'Original grain-free salmon dry',
    spec: '10 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Instinct 品牌页，条码与商品名成对列出 https://www.upcitemdb.com/info-instinct',
  ),
  LocalCatFood(
    barcode: '0769949657408',
    brand: 'Instinct',
    name: 'Grain-free chicken meal dry',
    spec: '2.2 lb',
    category: '干粮',
    sourceNote:
        'UPCitemdb Instinct 品牌页 https://www.upcitemdb.com/info-instinct',
  ),
  LocalCatFood(
    barcode: '0769949658825',
    brand: 'Instinct',
    name: 'Ultimate Protein cage-free chicken dry',
    spec: '1.8 lb',
    category: '干粮',
    sourceNote:
        'UPCitemdb Instinct 品牌页 https://www.upcitemdb.com/info-instinct',
  ),
  LocalCatFood(
    barcode: '0769949507017',
    brand: 'Instinct',
    name: 'Original grain-free chicken canned',
    spec: '5.5 oz×12',
    category: '湿粮',
    sourceNote:
        'UPCitemdb Instinct 品牌页 https://www.upcitemdb.com/info-instinct',
  ),
  LocalCatFood(
    barcode: '0769949602149',
    brand: 'Instinct',
    name: 'Freeze-dried raw boost chicken topper',
    spec: '6 oz',
    category: '零食',
    sourceNote:
        'UPCitemdb Instinct 品牌页 https://www.upcitemdb.com/info-instinct',
  ),
  LocalCatFood(
    barcode: '0693804480866',
    brand: 'Tiki Cat',
    name: 'Essentials chicken and turkey meal dry',
    spec: '12 lb',
    category: '干粮',
    sourceNote: 'Barcode Index 商品页 https://barcodeindex.com/upc/693804480866 ，品牌 Tiki Pets',
  ),
  LocalCatFood(
    barcode: '0693804470010',
    brand: 'Tiki Cat',
    name: 'Born Carnivore chicken dry',
    spec: '6 lb',
    category: '干粮',
    sourceNote:
        'UPCitemdb Tiki Cat 品牌页 https://www.upcitemdb.com/info-tiki-cat',
  ),
  LocalCatFood(
    barcode: '0693804470065',
    brand: 'Tiki Cat',
    name: 'Born Carnivore chicken and fish dry',
    spec: '5.6 lb',
    category: '干粮',
    sourceNote:
        'UPCitemdb Tiki Cat 品牌页 https://www.upcitemdb.com/info-tiki-cat',
  ),
  LocalCatFood(
    barcode: '0693804480064',
    brand: 'Tiki Cat',
    name: 'Velvet Mousse variety',
    spec: '2.8 oz×12',
    category: '湿粮',
    sourceNote:
        'UPCitemdb Tiki Cat 品牌页 https://www.upcitemdb.com/info-tiki-cat',
  ),
  LocalCatFood(
    barcode: '0693804102409',
    brand: 'Tiki Cat',
    name: 'King Kamehameha Luau variety',
    spec: '2.8 oz×12',
    category: '湿粮',
    sourceNote:
        'UPCitemdb Tiki Cat 品牌页 https://www.upcitemdb.com/info-tiki-cat',
  ),
  LocalCatFood(
    barcode: '0693804100313',
    brand: 'Tiki Cat',
    name: 'Hawaiian Grill ahi tuna',
    spec: '2.8 oz×12',
    category: '湿粮',
    sourceNote:
        'UPCitemdb Tiki Cat 品牌页 https://www.upcitemdb.com/info-tiki-cat',
  ),
  LocalCatFood(
    barcode: '0693804112439',
    brand: 'Tiki Cat',
    name: 'After Dark shredded meat variety',
    spec: '2.8 oz×12',
    category: '湿粮',
    sourceNote:
        'UPCitemdb Tiki Cat 品牌页 https://www.upcitemdb.com/info-tiki-cat',
  ),
  LocalCatFood(
    barcode: '0875992000228',
    brand: 'Tiki Cat',
    name: 'Bora Bora Luau sardine cutlets',
    spec: '见包装',
    category: '湿粮',
    sourceNote:
        'UPCitemdb Tiki Cat 品牌页 https://www.upcitemdb.com/info-tiki-cat',
  ),
  LocalCatFood(
    barcode: '0079105117586',
    brand: '美士',
    name: 'Wholesome chicken and brown rice dry',
    spec: '6.5 lb',
    category: '干粮',
    sourceNote:
        'UPCitemdb Nutro 品牌页，条码与商品名成对列出 https://www.upcitemdb.com/info-nutro',
  ),
  LocalCatFood(
    barcode: '0079105111812',
    brand: '美士',
    name: 'Wholesome essentials turkey and brown rice',
    spec: '14 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Nutro 品牌页 https://www.upcitemdb.com/info-nutro',
  ),
  LocalCatFood(
    barcode: '0079105102483',
    brand: '美士',
    name: 'Max indoor adult salmon dry',
    spec: '16 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Nutro 品牌页 https://www.upcitemdb.com/info-nutro',
  ),
  LocalCatFood(
    barcode: '0079105102322',
    brand: '美士',
    name: 'Max kitten roasted chicken dry',
    spec: '6 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Nutro 品牌页 https://www.upcitemdb.com/info-nutro',
  ),
  LocalCatFood(
    barcode: '0079105117647',
    brand: '美士',
    name: 'Grain-free duck and potato dry',
    spec: '6.5 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Nutro 品牌页 https://www.upcitemdb.com/info-nutro',
  ),
  LocalCatFood(
    barcode: '0023100110271',
    brand: '希宝',
    name: 'Perfect Portions chicken and turkey pate',
    spec: '2.64 oz×12',
    category: '湿粮',
    sourceNote:
        'UPCitemdb Sheba 品牌页，条码与商品名成对列出 https://www.upcitemdb.com/info-sheba',
  ),
  LocalCatFood(
    barcode: '0023100102955',
    brand: '希宝',
    name: 'Premium pate chicken entree',
    spec: '3 oz',
    category: '湿粮',
    sourceNote: 'UPCitemdb Sheba 品牌页 https://www.upcitemdb.com/info-sheba',
  ),
  LocalCatFood(
    barcode: '0023100102986',
    brand: '希宝',
    name: 'Premium cuts tuna entree',
    spec: '3 oz',
    category: '湿粮',
    sourceNote: 'UPCitemdb Sheba 品牌页 https://www.upcitemdb.com/info-sheba',
  ),
  LocalCatFood(
    barcode: '0023100119526',
    brand: '希宝',
    name: 'Signature broths tuna chicken and vegetable',
    spec: '12 袋',
    category: '湿粮',
    sourceNote: 'UPCitemdb Sheba 品牌页 https://www.upcitemdb.com/info-sheba',
  ),
  LocalCatFood(
    barcode: '0023100122694',
    brand: '希宝',
    name: 'Perfect Portions chicken and salmon variety',
    spec: '2.6 oz',
    category: '湿粮',
    sourceNote: 'UPCitemdb Sheba 品牌页 https://www.upcitemdb.com/info-sheba',
  ),
  LocalCatFood(
    barcode: '0023100117850',
    brand: '希宝',
    name: 'Meaty tender sticks tuna',
    spec: '0.7 oz',
    category: '零食',
    sourceNote: 'UPCitemdb Sheba 品牌页 https://www.upcitemdb.com/info-sheba',
  ),
  LocalCatFood(
    barcode: '0023100273020',
    brand: '伟嘉',
    name: 'Indoor chicken flavor dry',
    spec: '3 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Whiskas 品牌页，条码与商品名成对列出 https://www.upcitemdb.com/info-whiskas',
  ),
  LocalCatFood(
    barcode: '0023100071022',
    brand: '伟嘉',
    name: 'Meaty selections chicken and turkey dry',
    spec: '6 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Whiskas 品牌页 https://www.upcitemdb.com/info-whiskas',
  ),
  LocalCatFood(
    barcode: '0023100230276',
    brand: '伟嘉',
    name: 'Kitten dry',
    spec: '3 lb',
    category: '干粮',
    sourceNote: 'UPCitemdb Whiskas 品牌页 https://www.upcitemdb.com/info-whiskas',
  ),
];

String localBarcodeKey(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  final trimmed = digits.replaceFirst(RegExp(r'^0+'), '');
  return trimmed.isEmpty ? '0' : trimmed;
}

LocalCatFood? localCatFood(String code) {
  final key = localBarcodeKey(code);
  if (key.isEmpty) return null;
  for (final item in localCatFoods) {
    if (localBarcodeKey(item.barcode) == key) return item;
  }
  return null;
}

FoodForm localFoodForm(LocalCatFood food) {
  final text = '${food.name} ${food.spec}'.toLowerCase();
  if (food.category == '零食') {
    if (text.contains('冻干') || text.contains('freeze')) {
      return FoodForm.freezeDried;
    }
    return FoodForm.treat;
  }
  if (food.category == '湿粮') {
    if (text.contains('罐') || text.contains('can')) return FoodForm.can;
    return FoodForm.wet;
  }
  return FoodForm.dry;
}
