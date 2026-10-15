import 'dart:math' as math;

import '../models.dart';

/// Offline homemade-feeding notes.
///
/// WSAVA, AAFCO, NRC, Tufts, UC Davis and Cornell do not publish one
/// complete homemade recipe that every cat can eat long term. Cards below
/// keep their figures and say so. Nothing here is a balanced staple.

const neuteredAdultFactor = 1.2;
const intactAdultFactor = 1.4;
const obesityProneFactor = 1.0;

/// Hosts allowed on a recipe card. Tests pin this set.
const freshSourceHosts = {
  'wsava.org',
  'pmc.ncbi.nlm.nih.gov',
  'aafco.org',
  'nap.nationalacademies.org',
  'tufts.edu',
  'vetmed.ucdavis.edu',
  'vet.cornell.edu',
  'aaha.org',
  'petnutritionalliance.org',
  'acvn.org',
};

const freshHoldDays = <int>[2, 3];
const freshSupplementHolds = <int>[30, 90];

const aafcoScaleNote =
    '下面是成猫维持期、每 1000 千卡代谢能的最低含量，AAFCO 按 NRC 2006 整理，并假定每千克干物质约 4000 千卡。食物热量更高时要往上修正，更低时不要把最低量再往下调。这是全价食品里的含量，不是某种药片或滴剂的颗数，多补也可能过量。';

bool freshSourceAllowed(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return false;
  final host = uri.host.toLowerCase();
  for (final item in freshSourceHosts) {
    if (host == item || host.endsWith('.$item')) return true;
  }
  return false;
}

/// RER, kcal/day. 70 x kg^0.75.
double restingEnergyKcal(double kilograms) {
  if (kilograms <= 0) return 0;
  return 70 * math.pow(kilograms, 0.75).toDouble();
}

double merKcal(double kilograms, {double factor = neuteredAdultFactor}) {
  return restingEnergyKcal(kilograms) * factor;
}

/// Scale an amount stated per 1000 kcal to one day's energy.
double allowancePerDay({
  required double per1000kcal,
  required double dailyKcal,
}) {
  return per1000kcal * dailyKcal / 1000;
}

/// Daily grams when the batch's kcal per 100 g is already known.
double? gramsForKcal({required double dailyKcal, required double kcalPer100g}) {
  if (kcalPer100g <= 0 || dailyKcal <= 0) return null;
  return dailyKcal / kcalPer100g * 100;
}

String formatMeasure(double value) {
  final abs = value.abs();
  final digits = abs >= 100 ? 0 : (abs >= 10 ? 1 : (abs >= 1 ? 2 : 3));
  var text = value.toStringAsFixed(digits);
  if (text.contains('.')) {
    while (text.endsWith('0')) {
      text = text.substring(0, text.length - 1);
    }
    if (text.endsWith('.')) text = text.substring(0, text.length - 1);
  }
  return text;
}

String freshBarcode(String id) => 'fresh:$id';

class FreshSource {
  const FreshSource(this.label, this.url);

  final String label;
  final String url;
}

class FreshNutrient {
  const FreshNutrient(this.name, this.per1000kcal, this.unit, this.official);

  final String name;
  final double per1000kcal;
  final String unit;

  /// Official figure as printed, so 1.40 does not collapse to 1.4.
  final String official;
}

enum FreshKind { safety, avoid, recipe, amount, supplement }

class FreshCard {
  const FreshCard({
    required this.id,
    required this.kind,
    required this.title,
    required this.summary,
    this.paragraphs = const [],
    this.lines = const [],
    this.steps = const [],
    this.nutrients = const [],
    this.sources = const [],
    this.stockId,
    this.holdDays = const [],
    this.pickGrams = false,
    this.pantryName = '',
    this.spec = '',
    this.storage = '',
    this.form = FoodForm.wet,
  });

  final String id;
  final FreshKind kind;
  final String title;
  final String summary;
  final List<String> paragraphs;
  final List<String> lines;
  final List<String> steps;
  final List<FreshNutrient> nutrients;
  final List<FreshSource> sources;

  /// Pantry product this card writes. Null when the card is only a warning.
  final String? stockId;
  final List<int> holdDays;
  final bool pickGrams;
  final String pantryName;
  final String spec;
  final String storage;
  final FoodForm form;

  String get text => [
    title,
    summary,
    ...paragraphs,
    ...lines,
    ...steps,
    for (final item in nutrients) '${item.name} ${item.official} ${item.unit}',
    for (final item in sources) '${item.label} ${item.url}',
  ].join('\n');
}

class FreshSection {
  const FreshSection(this.title, this.cards);

  final String title;
  final List<FreshCard> cards;
}

const _wsava2024 = FreshSource(
  'WSAVA 全球营养委员会：营养评估指南（2024）',
  'https://pmc.ncbi.nlm.nih.gov/articles/PMC11107980/',
);
const _wsava2011 = FreshSource(
  'WSAVA 营养评估指南（2011 PDF）',
  'https://wsava.org/wp-content/uploads/2020/01/WSAVA-Nutrition-Assessment-Guidelines-2011-JSAP.pdf',
);
const _wsavaCats = FreshSource(
  '把 WSAVA 营养评估用到猫（2024）',
  'https://pmc.ncbi.nlm.nih.gov/articles/PMC10814421/',
);
const _aafco = FreshSource(
  'AAFCO 猫营养素档案（2014 修订，依据 NRC 2006）',
  'https://www.aafco.org/wp-content/uploads/2023/01/Pet_Food_Report_Annual_2014-Appendix_A-Revised_AAFCO_Nutrient_Profiles-Final_092214.pdf',
);
const _nrc = FreshSource(
  'NRC：Nutrient Requirements of Dogs and Cats（2006）',
  'https://nap.nationalacademies.org/catalog/10668/nutrient-requirements-of-dogs-and-cats',
);
const _tuftsHome = FreshSource(
  'Tufts Petfoodology：该不该自己做宠物食物',
  'https://sites.tufts.edu/petfoodology/2016/07/14/should-you-make-your-own-pet-food-at-home/',
);
const _tuftsMistakes = FreshSource(
  'Tufts Petfoodology：自制饮食常见错误',
  'https://sites.tufts.edu/petfoodology/2019/01/29/cooking-up-trouble-common-home-cooking-mistakes/',
);
const _tuftsFive = FreshSource(
  'Tufts Petfoodology：自制饮食的五个误区',
  'https://sites.tufts.edu/petfoodology/2023/03/31/5-homecooked-diet-mistakes-misconceptions/',
);
const _tuftsCats = FreshSource(
  'Tufts Petfoodology：猫不是小型犬',
  'https://sites.tufts.edu/petfoodology/2018/12/18/cats-are-not-small-dogs-unique-nutritional-needs-of-cats/',
);
const _tuftsNutrients = FreshSource(
  'Tufts Petfoodology：哪些营养素是必需的',
  'https://sites.tufts.edu/petfoodology/2023/05/09/what-nutrients-are-essential-for-my-pet/',
);
const _ucdavisNews = FreshSource(
  'UC Davis：自制猫粮可能有风险（2019）',
  'https://www.vetmed.ucdavis.edu/news/homemade-cat-food-diets-could-be-risky',
);
const _ucdavisClinic = FreshSource(
  'UC Davis 兽医教学医院：营养门诊（ACVIM Nutrition）',
  'https://www.vetmed.ucdavis.edu/hospital/small-animal/nutrition',
);
const _acvn = FreshSource(
  '美国兽医营养学院名录（ACVN，现为 ACVIM Nutrition）',
  'https://www.acvn.org',
);
const _aahaHome = FreshSource(
  'AAHA 2021：自制饮食',
  'https://www.aaha.org/resources/2021-aaha-nutrition-and-weight-management-guidelines/home-prepared-diets/',
);
const _aahaEnergy = FreshSource(
  'AAHA 2021：绝育猫的维持能量',
  'https://www.aaha.org/resources/2021-aaha-nutrition-and-weight-management-guidelines/weight-reduction-in-the-obese-pet/',
);
const _pna = FreshSource(
  'Pet Nutrition Alliance：静息能量与维持能量（WSAVA 相关）',
  'https://petnutritionalliance.org/wp-content/uploads/2023/03/MER.RER_.PNA_.pdf',
);
const _cornellHazards = FreshSource(
  'Cornell 猫咪健康中心：常见危害',
  'https://www.vet.cornell.edu/departments-centers-and-institutes/cornell-feline-health-center/health-information/feline-health-topics/common-cat-hazards',
);
const _cornellPoisons = FreshSource(
  'Cornell 猫咪健康中心：中毒',
  'https://www.vet.cornell.edu/departments-centers-and-institutes/cornell-feline-health-center/health-information/feline-health-topics/poisons',
);
const _cornellToxins = FreshSource(
  'Cornell 大学兽医院：小动物毒物',
  'https://www.vet.cornell.edu/hospitals/pharmacy/consumer-clinical-care-guidelines-animals/small-animal-toxins',
);
const _cornellFeed = FreshSource(
  'Cornell 猫咪健康中心：喂猫',
  'https://www.vet.cornell.edu/departments-centers-and-institutes/cornell-feline-health-center/health-information/feline-health-topics/feeding-your-cat',
);

const _slowStorage = '冷藏，尽快喂完。你点的天数只用来提醒，这些资料没有公布一个通用的冷藏天数。';

const freshSections = <FreshSection>[
  FreshSection('先看安全', [_safety, _avoid]),
  FreshSection('做法和喂量', [_grams, _slow, _daily]),
  FreshSection('必备添加剂', [
    _taurine,
    _calcium,
    _fish,
    _vitaminE,
    _bComplex,
    _iodine,
  ]),
];

List<FreshCard> get freshCards => [
  for (final section in freshSections) ...section.cards,
];

FreshCard? freshById(String id) {
  for (final card in freshCards) {
    if (card.id == id) return card;
  }
  return null;
}

const _safety = FreshCard(
  id: 'safety',
  kind: FreshKind.safety,
  title: '先给营养师看',
  summary: '自制粮要经兽医或认证营养师确认，才能长期当主食。',
  paragraphs: [
    'WSAVA 把自制和生食算作非常规饮食：要看食谱、做法、保存和有没有偷偷换食材，并联系认证兽医营养师评估或重新配制。',
    'UC Davis 2019 年看过的自制猫食谱，没有一份补齐全部必需营养，有的还放了可能有毒的食材。营养门诊的做法是按具体那只猫单独开方。书上和网上的食谱大多不均衡。',
    'Tufts 的营养师写道：只靠天然食材几乎凑不齐，常常要 7 到 9 种添加剂，用量同时取决于食材和这只动物。他们举过精确写法：「100 克去骨去皮烤鸡胸，和 45 克烤熟捣碎的红薯」。含糊的「1 杯鸡或鱼或猪肉」不能用。就算兽医开了方，很多家庭后来也会换食材或换牌子，配方就不再成立。',
    'AAHA：已发表的自制食谱大多不完整，包括一些兽医写的。要按克数原样做，并且每年和营养师复核一次。',
    '认证专科是 ACVIM Nutrition（2021 年起；在那之前是美国兽医营养学院 ACVN）。可以在名录里找，或去大学兽医院的营养门诊。',
  ],
  sources: [
    _wsava2024,
    _wsava2011,
    _wsavaCats,
    _ucdavisNews,
    _ucdavisClinic,
    _tuftsHome,
    _tuftsMistakes,
    _tuftsFive,
    _aahaHome,
    _acvn,
  ],
);

const _avoid = FreshCard(
  id: 'avoid',
  kind: FreshKind.avoid,
  title: '这些不要喂',
  summary: '洋葱、大蒜、葡萄、巧克力、生鱼，都不要进碗。',
  lines: [
    '洋葱、大蒜、韭菜、细香葱（葱属）',
    '葡萄、葡萄干',
    '牛油果',
    '木糖醇',
    '巧克力',
    '生鱼、生肉，以及只加热到温热的轻煮',
    '给人吃的鱼罐头当主食',
    '狗粮',
    '牛奶（很多猫会拉肚子）',
  ],
  paragraphs: [
    'Cornell 猫咪健康中心把葡萄、洋葱、葡萄干、牛油果、木糖醇和巧克力列为猫的常见危害。大学兽医院的小动物毒物页写明：大蒜、洋葱、韭菜、细香葱对猫可能有毒，巧克力有毒。',
    '同一中心的喂猫说明：不建议生食或轻煮，原因是细菌、病毒和寄生虫，也没有证实对猫更好。生肉还有弓形虫的风险。有的猫长期吃给人的鱼罐头后出现严重的神经症状，和硫胺素有关。牛奶常因乳糖引起肠胃不适。零食大约占每天热量的 10% 到 15% 就够了。',
    'Tufts：猫不是小型犬。猫自己合成的牛磺酸不够，缺乏会造成视网膜变性和扩张型心肌病；还需要现成的维生素 A、维生素 D、花生四烯酸，以及更高的烟酸。不要喂狗粮。',
  ],
  sources: [
    _cornellHazards,
    _cornellPoisons,
    _cornellToxins,
    _cornellFeed,
    _tuftsCats,
  ],
);

const _grams = FreshCard(
  id: 'grams',
  kind: FreshKind.recipe,
  title: '克数要写死',
  summary: '100 克鸡胸、45 克红薯，只说明写法，不是全价餐。',
  paragraphs: [
    'Tufts 用一句话对比两种写法。能用的写法是：100 克去骨、去皮、烤熟的鸡胸，加上 45 克烤熟、捣碎的红薯。不能用的写法是：1 杯鸡或鱼或猪肉。',
    '这句话是在教「克数必须写死」，不是在发布猫的全价食谱。猫不是小型犬，不能把狗的食谱缩小了喂。换一种肉、换一个牌子的添加剂，这张方子就不再是原来那张。',
    '成猫维持期粗蛋白的最低量是每 1000 千卡 65 克。单靠上面两行食材，补不齐钙、牛磺酸和维生素。',
  ],
  lines: ['去骨去皮烤鸡胸 100 克（熟重）', '烤熟捣碎的红薯 45 克（熟重）', '生重和熟重不一样，方子要写明称的是哪一种'],
  nutrients: [FreshNutrient('粗蛋白', 65, '克', '65')],
  sources: [_tuftsHome, _tuftsMistakes, _tuftsCats, _aafco, _nrc],
);

const _slow = FreshCard(
  id: 'slow-cook',
  kind: FreshKind.recipe,
  title: '慢煮一份熟肉',
  summary: '按 100 克鸡胸和 45 克红薯称重，煮到中心不发粉。',
  paragraphs: [
    '这是把 Tufts 那两行克数煮熟的步骤，用来示范称重和煮熟。它不是全价主食，也不能长期单喂。',
    '慢煮的温度和时间：WSAVA、AAFCO、NRC、Tufts、UC Davis 和 Cornell 都没有公布「加热到某一度、维持几小时，这份食物就成为全价猫粮」。所以这里不写一个没有出处的度数和小时数。Cornell 不建议生食，也不建议低温轻煮。',
  ],
  lines: ['去骨去皮鸡胸，熟重 100 克', '烤熟捣碎的红薯，熟重 45 克'],
  steps: [
    '用厨房秤称。克数写死，不要改成「鸡或鱼或猪肉」。先和营养师约定称生重还是熟重。这里的 100 克和 45 克是熟重示例。',
    '加水没过食材。',
    '慢煮到鸡肉中心不再发粉，用叉子能拨开。不要只煮到温热。',
    '放凉。添加剂只加营养师方子上的那些，不要自己抓一把人类的复合维生素。',
    '按「每天喂多少」分成每餐。冷藏，尽快喂完。',
  ],
  sources: [
    _tuftsHome,
    _tuftsMistakes,
    _tuftsFive,
    _cornellFeed,
    _wsava2024,
    _ucdavisNews,
  ],
  stockId: 'slow-cook',
  holdDays: freshHoldDays,
  pickGrams: true,
  pantryName: '慢煮熟肉（不是全价）',
  spec: '熟鸡胸 100 克',
  storage: _slowStorage,
  form: FoodForm.wet,
);

const _daily = FreshCard(
  id: 'daily',
  kind: FreshKind.amount,
  title: '每天喂多少',
  summary: '先算每天千卡，再换成克。没有热量就先点一个克数。',
  paragraphs: [
    '静息能量（千卡/天）= 70 × 体重（千克）的 0.75 次方。绝育成猫从 1.2 倍起算，未绝育大约 1.4 倍，特别容易胖的猫维持期可以靠近 1.0 倍。AAHA 给绝育猫的区间是 1.2 到 1.4 倍。',
    'WSAVA 提醒：猫的实际能量需要可能和估计差大约 50%。先按这个起点喂，再看体重和体况改，不要一成不变。',
    '如果营养师已经给出这份食物每 100 克多少千卡：每天克数 = 每天千卡 ÷（每 100 克千卡）× 100。上面的鸡胸和红薯没有附带可引用的热量，所以这里不编一个每 100 克的数字。不知道热量时，先在 30 到 100 克里点一个，看体重再改。',
    '零食大约占每天热量的 10% 到 15%。',
  ],
  steps: ['看下面按这只猫算的起步千卡。', '点一个每天克数。', '点「加入粮仓并提醒」。提醒按你选的冷藏天数走，不是保质期承诺。'],
  sources: [_wsava2024, _wsava2011, _pna, _aahaEnergy, _cornellFeed],
  stockId: 'slow-cook',
  holdDays: freshHoldDays,
  pickGrams: true,
);

const _taurine = FreshCard(
  id: 'taurine',
  kind: FreshKind.supplement,
  title: '牛磺酸',
  summary: '每 1000 千卡：挤压型 0.25 克，罐头型 0.50 克。',
  paragraphs: [
    '猫自己合成的牛磺酸不够。缺乏会造成视网膜变性（可致失明）和扩张型心肌病。食物里的其他成分也会改变牛磺酸能不能被利用。',
    'AAFCO 成猫维持有两档，因为加热和加工会损失：挤压、损失较小的做法用 0.25 克/1000 千卡；罐头这类热加工用 0.50 克/1000 千卡。你的慢煮算哪一档，由营养师定，不要自己降档。',
    aafcoScaleNote,
  ],
  nutrients: [
    FreshNutrient('牛磺酸（挤压型）', 0.25, '克', '0.25'),
    FreshNutrient('牛磺酸（罐头型）', 0.50, '克', '0.50'),
  ],
  sources: [_aafco, _nrc, _tuftsCats, _tuftsHome, _tuftsNutrients],
  stockId: 'taurine',
  holdDays: freshSupplementHolds,
  pantryName: '牛磺酸',
  spec: '添加剂，按营养师方子',
  storage: '按产品密封保存。天数只是提醒你复查这瓶还在不在。',
  form: FoodForm.treat,
);

const _calcium = FreshCard(
  id: 'calcium',
  kind: FreshKind.supplement,
  title: '钙和磷',
  summary: '每 1000 千卡至少钙 1.5 克、磷 1.25 克。',
  paragraphs: [
    '自制饮食常常缺钙，可能连到缺铁、缺锌、缺维生素 E 和缺硫胺素，出现骨折、贫血、皮肤或神经问题。钙和磷要一起算。',
    '骨粉同时提供钙和磷。碳酸钙基本上只提供钙。食谱里已经有多少磷，决定该用哪一种。Tufts：不要自行更换添加剂，连牌子都不要随便换。',
    '成猫这两项最低量放在一起，是 1.5 克钙对 1.25 克磷。同一份 AAFCO 资料里钙磷比不超过 2:1 的上限写在犬的档案，不要套到猫身上。',
    aafcoScaleNote,
  ],
  nutrients: [
    FreshNutrient('钙', 1.5, '克', '1.5'),
    FreshNutrient('磷', 1.25, '克', '1.25'),
  ],
  sources: [
    _aafco,
    _nrc,
    _wsavaCats,
    _tuftsMistakes,
    _tuftsFive,
    _tuftsNutrients,
  ],
  stockId: 'calcium',
  holdDays: freshSupplementHolds,
  pantryName: '钙（骨粉或碳酸钙）',
  spec: '添加剂，按营养师方子',
  storage: '按产品密封保存。天数只是提醒你复查这瓶还在不在。',
  form: FoodForm.treat,
);

const _fish = FreshCard(
  id: 'fish-oil',
  kind: FreshKind.supplement,
  title: '鱼油（EPA 和 DHA）',
  summary: '成猫维持的最低量标为未确定，不要拿生长期的数来喂。',
  paragraphs: [
    'AAFCO 成猫维持的 EPA+DHA 是未确定（表上写 ND）。NRC 认为没有足够数据给成猫定一个需要量。生长和繁殖的最低量是每 1000 千卡 0.03 克，那不是成猫的剂量。',
    '猫需要花生四烯酸。成猫维持最低量是每 1000 千卡 0.05 克。',
    '如果方子里加了鱼油：按 AAFCO 脚注，每千克食物、每增加 1 克鱼油，维生素 E 要在最低量之外再加 10 IU。鱼按干物质超过 25% 时，才另外考虑维生素 K。不要为了补鱼油把生鱼喂下去。',
    aafcoScaleNote,
  ],
  nutrients: [FreshNutrient('花生四烯酸', 0.05, '克', '0.05')],
  sources: [_aafco, _nrc, _tuftsCats, _tuftsNutrients, _cornellFeed],
  stockId: 'fish-oil',
  holdDays: freshSupplementHolds,
  pantryName: '鱼油',
  spec: '添加剂，按营养师方子',
  storage: '按产品密封、避光保存。天数只是提醒你复查这瓶还在不在。',
  form: FoodForm.treat,
);

const _vitaminE = FreshCard(
  id: 'vitamin-e',
  kind: FreshKind.supplement,
  title: '维生素 E',
  summary: '每 1000 千卡至少 10 IU。加了鱼油还要再加。',
  paragraphs: [
    '成猫维持的维生素 E 最低量是每 1000 千卡 10 IU。自制饮食里维生素 E 常常不够。',
    '鱼油会提高需要量：每千克食物、每 1 克鱼油，在最低量之外再加 10 IU。这一条按食物重量算，不能简单乘每天千卡。',
    aafcoScaleNote,
  ],
  nutrients: [FreshNutrient('维生素 E', 10, 'IU', '10')],
  sources: [_aafco, _nrc, _wsavaCats, _tuftsNutrients],
  stockId: 'vitamin-e',
  holdDays: freshSupplementHolds,
  pantryName: '维生素 E',
  spec: '添加剂，按营养师方子',
  storage: '按产品密封保存。天数只是提醒你复查这瓶还在不在。',
  form: FoodForm.treat,
);

const _bComplex = FreshCard(
  id: 'b-complex',
  kind: FreshKind.supplement,
  title: '复合维生素 B',
  summary: '硫胺素每 1000 千卡至少 1.40 毫克，加工会大量损失。',
  paragraphs: [
    '加工和有些食材最多可破坏 90% 的硫胺素，配方要保证加工之后仍然达到最低量。生鱼里的硫胺素酶也会破坏它。Cornell 记录过：长期把给人的鱼罐头当饭，猫可能出现严重神经症状。',
    '猫需要的烟酸比很多动物更高，而且要用现成的维生素 A，不能靠转化。不要用一颗人用复合维生素代替营养师指定的产品。',
    aafcoScaleNote,
  ],
  nutrients: [
    FreshNutrient('硫胺素', 1.4, '毫克', '1.40'),
    FreshNutrient('核黄素', 1, '毫克', '1.00'),
    FreshNutrient('泛酸', 1.44, '毫克', '1.44'),
    FreshNutrient('烟酸', 15, '毫克', '15'),
    FreshNutrient('吡哆醇', 1, '毫克', '1.0'),
    FreshNutrient('叶酸', 0.2, '毫克', '0.20'),
    FreshNutrient('维生素 B12', 0.005, '毫克', '0.005'),
    FreshNutrient('胆碱', 600, '毫克', '600'),
  ],
  sources: [
    _aafco,
    _nrc,
    _tuftsCats,
    _tuftsNutrients,
    _cornellFeed,
    _wsavaCats,
  ],
  stockId: 'b-complex',
  holdDays: freshSupplementHolds,
  pantryName: '复合维生素 B',
  spec: '添加剂，按营养师方子',
  storage: '按产品密封保存。天数只是提醒你复查这瓶还在不在。',
  form: FoodForm.treat,
);

const _iodine = FreshCard(
  id: 'iodine',
  kind: FreshKind.supplement,
  title: '碘',
  summary: '每 1000 千卡至少 0.15 毫克。不要随手倒碘盐。',
  paragraphs: [
    '碘是 AAFCO / NRC 列出的必需矿物质。成猫维持最低量是每 1000 千卡 0.15 毫克，干物质基础大约每千克 0.6 毫克。',
    '不要用倒碘盐的办法代替算好的量。用量要和方子里其他矿物质一起由营养师定。',
    aafcoScaleNote,
  ],
  nutrients: [FreshNutrient('碘', 0.15, '毫克', '0.15')],
  sources: [_aafco, _nrc, _tuftsNutrients],
  stockId: 'iodine',
  holdDays: freshSupplementHolds,
  pantryName: '碘',
  spec: '添加剂，按营养师方子',
  storage: '按产品密封保存。天数只是提醒你复查这瓶还在不在。',
  form: FoodForm.treat,
);
