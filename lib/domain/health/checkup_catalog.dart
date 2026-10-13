import 'life_stage.dart';

class StagePlan {
  const StagePlan({required this.frequency, required this.intervalDays});

  final String frequency;
  final int intervalDays;
}

class CheckupItem {
  const CheckupItem({
    required this.id,
    required this.name,
    required this.why,
    required this.source,
    required this.byStage,
    this.breedKeys = const [],
    this.breedReason = '',
  });

  final String id;
  final String name;
  final String why;
  final String source;
  final Map<LifeStage, StagePlan> byStage;
  final List<String> breedKeys;
  final String breedReason;
}

class CheckupAdvice {
  const CheckupAdvice({
    required this.item,
    required this.plan,
    required this.becauseOfBreed,
  });

  final CheckupItem item;
  final StagePlan plan;
  final bool becauseOfBreed;
}

class CheckupPlan {
  const CheckupPlan({
    required this.stage,
    required this.birthdayMissing,
    required this.items,
  });

  final LifeStage stage;
  final bool birthdayMissing;
  final List<CheckupAdvice> items;
}

const checkupCatalog = <CheckupItem>[
  CheckupItem(
    id: 'exam',
    name: '全面体格检查',
    why: '体重、体态、心肺、口腔、淋巴结和关节都要兽医当面看，家庭记录代替不了。',
    source: 'AAHA/AAFP 猫生命阶段指南',
    byStage: {
      LifeStage.kitten: StagePlan(frequency: '幼猫系列期间约每 3–4 周一次，直到基础免疫和绝育评估完成', intervalDays: 28),
      LifeStage.adult: StagePlan(frequency: '至少每年 1 次', intervalDays: 365),
      LifeStage.mature: StagePlan(frequency: '至少每 6–12 个月', intervalDays: 180),
      LifeStage.senior: StagePlan(frequency: '建议每 6 个月', intervalDays: 180),
    },
  ),
  CheckupItem(
    id: 'cbc',
    name: '血常规',
    why: '看贫血、炎症和血小板。成熟和老年猫更需要定期对比。',
    source: 'AAHA/AAFP 猫生命阶段指南',
    byStage: {
      LifeStage.kitten: StagePlan(frequency: '绝育或生病时由兽医决定，不必自行开单', intervalDays: 365),
      LifeStage.adult: StagePlan(frequency: '每年讨论一次基线', intervalDays: 365),
      LifeStage.mature: StagePlan(frequency: '每 6–12 个月', intervalDays: 180),
      LifeStage.senior: StagePlan(frequency: '每 6 个月', intervalDays: 180),
    },
  ),
  CheckupItem(
    id: 'chem',
    name: '血液生化',
    why: '肝肾、血糖、电解质等。和尿检、SDMA 一起看，比单看一个数字可靠。',
    source: 'AAHA/AAFP；IRIS 建议肾功能不要只看肌酐',
    byStage: {
      LifeStage.kitten: StagePlan(frequency: '生病或麻醉前按兽医安排', intervalDays: 365),
      LifeStage.adult: StagePlan(frequency: '每年一次基线', intervalDays: 365),
      LifeStage.mature: StagePlan(frequency: '每 6–12 个月', intervalDays: 180),
      LifeStage.senior: StagePlan(frequency: '每 6 个月', intervalDays: 180),
    },
  ),
  CheckupItem(
    id: 'sdma',
    name: 'SDMA / 肾功能',
    why: 'SDMA 有助于更早发现肾功能变化，仍要结合尿比重、血压和影像。',
    source: 'IRIS 慢性肾病分期；AAHA/AAFP',
    byStage: {
      LifeStage.adult: StagePlan(frequency: '每年随生化讨论', intervalDays: 365),
      LifeStage.mature: StagePlan(frequency: '每 6–12 个月', intervalDays: 180),
      LifeStage.senior: StagePlan(frequency: '每 6 个月', intervalDays: 180),
    },
  ),
  CheckupItem(
    id: 't4',
    name: 'T4 甲状腺',
    why: '老年猫甲亢常见。体重下降、多吃、多饮、呕吐或心率快时更要查。',
    source: 'AAFP 甲亢共识；AAHA/AAFP 生命阶段指南',
    byStage: {
      LifeStage.adult: StagePlan(frequency: '非常规。出现消瘦、多饮多尿时请兽医评估', intervalDays: 365),
      LifeStage.mature: StagePlan(frequency: '7 岁起每 6–12 个月讨论', intervalDays: 180),
      LifeStage.senior: StagePlan(frequency: '每 6 个月', intervalDays: 180),
    },
  ),
  CheckupItem(
    id: 'ua',
    name: '尿检',
    why: '尿比重、蛋白、沉渣和细菌信息，肾病、泌尿和糖尿病都会用到。',
    source: 'ISFM 泌尿与肾病相关共识；AAHA/AAFP',
    byStage: {
      LifeStage.adult: StagePlan(frequency: '每年一次基线', intervalDays: 365),
      LifeStage.mature: StagePlan(frequency: '每 6–12 个月', intervalDays: 180),
      LifeStage.senior: StagePlan(frequency: '每 6 个月', intervalDays: 180),
    },
  ),
  CheckupItem(
    id: 'bp',
    name: '血压',
    why: '肾病、甲亢和老年猫更容易高血压。测量需要在诊所按规范做。',
    source: 'ISFM 猫高血压共识；IRIS',
    byStage: {
      LifeStage.adult: StagePlan(frequency: '肾病、甲亢或麻醉评估时测量', intervalDays: 365),
      LifeStage.mature: StagePlan(frequency: '每 6–12 个月', intervalDays: 180),
      LifeStage.senior: StagePlan(frequency: '每 6 个月', intervalDays: 180),
    },
  ),
  CheckupItem(
    id: 'dental',
    name: '口腔检查',
    why: '牙结石、口炎和牙吸收很常见。口臭、流涎、偏侧咀嚼要提前看诊。',
    source: 'AAHA/AAFP；牙科处置必须麻醉下由兽医完成',
    byStage: {
      LifeStage.kitten: StagePlan(frequency: '每次幼猫体检都看牙和咬合', intervalDays: 180),
      LifeStage.adult: StagePlan(frequency: '每年至少 1 次', intervalDays: 365),
      LifeStage.mature: StagePlan(frequency: '每 6–12 个月', intervalDays: 180),
      LifeStage.senior: StagePlan(frequency: '每 6 个月，或更早', intervalDays: 180),
    },
  ),
  CheckupItem(
    id: 'vaccine',
    name: '疫苗',
    why: '核心疫苗的种类和间隔由兽医按风险、法规和抗体情况决定。',
    source: 'WSAVA 犬猫疫苗指南；当地法规优先',
    byStage: {
      LifeStage.kitten: StagePlan(frequency: '幼猫系列通常从 6–8 周龄开始，每 2–4 周一次，直到 16 周龄或兽医指定的末剂', intervalDays: 28),
      LifeStage.adult: StagePlan(frequency: '加强间隔常见为 1 年或 3 年，以兽医和当地要求为准', intervalDays: 365),
      LifeStage.mature: StagePlan(frequency: '继续按兽医制定的核心疫苗计划', intervalDays: 365),
      LifeStage.senior: StagePlan(frequency: '不要自行停用。高龄、免疫和风险由兽医评估', intervalDays: 365),
    },
  ),
  CheckupItem(
    id: 'deworm',
    name: '驱虫',
    why: '体内外寄生虫和生活方式有关。幼猫、外出和多猫家庭通常更密。',
    source: 'ESCCAP / WSAVA 寄生虫防控思路；产品由兽医选择',
    byStage: {
      LifeStage.kitten: StagePlan(frequency: '幼猫阶段更频繁，具体间隔听兽医的', intervalDays: 30),
      LifeStage.adult: StagePlan(frequency: '常见讨论间隔约 1–3 个月，视外出和猎食而定', intervalDays: 90),
      LifeStage.mature: StagePlan(frequency: '继续按风险，不要套用狗的药', intervalDays: 90),
      LifeStage.senior: StagePlan(frequency: '按风险，同时留意肝肾能否承受药物', intervalDays: 90),
    },
  ),
  CheckupItem(
    id: 'hcm',
    name: '心脏超声（HCM 筛查）',
    why: '缅因猫和布偶有肥厚型心肌病的品种风险。听诊正常也不能排除，筛查靠超声。',
    source: 'ACVIM 心肌病共识对品种猫筛查的讨论；AAHA/AAFP',
    breedKeys: ['缅因', '布偶', 'maine', 'ragdoll'],
    breedReason: '品种与 HCM 相关',
    byStage: {
      LifeStage.kitten: StagePlan(frequency: '繁殖体检或兽医听到杂音时再安排，不必在家判断', intervalDays: 365),
      LifeStage.adult: StagePlan(frequency: '1 岁后与心脏病方向的兽医讨论超声，之后常按每年或按上次结果缩短', intervalDays: 365),
      LifeStage.mature: StagePlan(frequency: '继续按上次超声结果复查', intervalDays: 365),
      LifeStage.senior: StagePlan(frequency: '有杂音、呼吸加快或既往异常时提前', intervalDays: 180),
    },
  ),
  CheckupItem(
    id: 'pkd',
    name: 'PKD 基因或肾脏超声',
    why: '波斯猫和英国短毛猫所在的波斯品种群更容易多囊肾。基因或超声用来确认，不能在家诊断。',
    source: '品种相关多囊肾筛查实践；IRIS 用于阳性猫的后续监测',
    breedKeys: ['波斯', '英短', '英国短毛', 'persian', 'british'],
    breedReason: '品种与多囊肾相关',
    byStage: {
      LifeStage.kitten: StagePlan(frequency: '可与兽医讨论一次 PKD1 基因或超声，不必重复抽血“看看”', intervalDays: 365),
      LifeStage.adult: StagePlan(frequency: '未知状态时做一次确认；阳性后改为肾病监测', intervalDays: 365),
      LifeStage.mature: StagePlan(frequency: '若尚未筛查，仍可做一次；阳性猫按肾病复查', intervalDays: 365),
      LifeStage.senior: StagePlan(frequency: '阳性或未知时把血压、尿检和 SDMA 纳入老年体检', intervalDays: 180),
    },
  ),
];

CheckupItem? checkupById(String id) {
  for (final item in checkupCatalog) {
    if (item.id == id) return item;
  }
  return null;
}

bool breedMatches(String? breed, List<String> keys) {
  if (keys.isEmpty) return true;
  if (breed == null || breed.trim().isEmpty) return false;
  final hay = breed.toLowerCase().replaceAll(' ', '');
  for (final key in keys) {
    if (hay.contains(key.toLowerCase().replaceAll(' ', ''))) return true;
  }
  return false;
}

CheckupPlan recommendCheckups({
  required DateTime? birthday,
  required String? breed,
  required DateTime now,
}) {
  final stage = lifeStageFor(birthday, now);
  final items = <CheckupAdvice>[];
  for (final item in checkupCatalog) {
    final plan = item.byStage[stage];
    if (plan == null) continue;
    if (item.breedKeys.isNotEmpty && !breedMatches(breed, item.breedKeys)) {
      continue;
    }
    items.add(
      CheckupAdvice(
        item: item,
        plan: plan,
        becauseOfBreed: item.breedKeys.isNotEmpty,
      ),
    );
  }
  return CheckupPlan(
    stage: stage,
    birthdayMissing: birthday == null,
    items: items,
  );
}
