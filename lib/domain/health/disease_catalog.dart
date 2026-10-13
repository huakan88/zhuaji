class DiseaseInfo {
  const DiseaseInfo({
    required this.id,
    required this.name,
    required this.summary,
    required this.diet,
    required this.water,
    required this.medication,
    required this.recheck,
    required this.recheckDays,
    required this.monitoring,
    required this.redFlags,
    required this.sources,
    this.stages = const [],
    this.trackWater = false,
  });

  final String id;
  final String name;
  final String summary;
  final String diet;
  final String water;
  final String medication;
  final String recheck;
  final int recheckDays;
  final String monitoring;
  final List<String> redFlags;
  final String sources;
  final List<String> stages;
  final bool trackWater;
}

const diseaseCatalog = <DiseaseInfo>[
  DiseaseInfo(
    id: 'ckd',
    name: '慢性肾病',
    summary: '慢性肾病（CKD）要由兽医按 IRIS 分期。分期会参考肌酐、SDMA、尿蛋白和血压，不能只凭一次饮水变多来判断。',
    diet: '兽医常在 IRIS 2 期及以后讨论肾脏处方粮，重点是适量优质蛋白、控制磷，并保证吃得下去。不要用狗粮或网上的“肾衰食谱”替换处方。',
    water: '鼓励喝水：湿粮、多处水碗、流动饮水机。突然喝很多或几乎不喝，都要告诉兽医。',
    medication: '降磷剂、降压药、补钾、食欲和抗恶心药物都只能按处方使用。不要自行加用人用药物。',
    recheck: '早期多为每 3–6 个月复查血压、血液和尿液；分期更高或刚换药时会更密。以医嘱为准。',
    recheckDays: 90,
    monitoring: '在家记体重、食欲、呕吐次数、饮水量和精神。体重持续下降比单日波动更重要。',
    redFlags: ['完全不吃超过一顿主餐', '反复呕吐', '虚弱、站不稳或抽搐', '几乎无尿', '呼吸急或张口喘'],
    sources: 'IRIS CKD 分期与管理；ISFM 猫慢性肾病共识',
    stages: ['IRIS 1', 'IRIS 2', 'IRIS 3', 'IRIS 4'],
    trackWater: true,
  ),
  DiseaseInfo(
    id: 'flutd',
    name: '下泌尿道疾病',
    summary: 'FLUTD 包括特发性膀胱炎、尿石、结晶和尿路感染等。公猫频繁进砂盆却尿不出，要按急症处理，可能是尿道阻塞。',
    diet: '溶解或预防结石的处方粮必须和结石类型匹配。兽医确认类型之前，不要长期乱换“泌尿粮”。',
    water: '增加饮水、湿粮，是多数膀胱炎和部分结石方案里的基础。记一下每天大概喝多少。',
    medication: '止痛、缓解尿道痉挛和抗生素都要处方。没有感染证据时，不应自行使用抗生素。',
    recheck: '急性发作后常在数日到 2–4 周复查尿液；反复发作则讨论影像和长期饮食。',
    recheckDays: 30,
    monitoring: '砂盆里的尿量、带血、频繁蹲盆、舔下腹、哭叫。公猫无尿是紧急情况。',
    redFlags: ['反复蹲盆但几乎没有尿', '腹痛、哭叫', '呕吐、精神很差', '尿闭超过兽医交代的观察时限'],
    sources: 'ISFM 猫特发性膀胱炎与泌尿道共识',
    trackWater: true,
  ),
  DiseaseInfo(
    id: 'diabetes',
    name: '糖尿病',
    summary: '猫糖尿病的胰岛素和饮食由兽医制定。有的猫在控制后可以缓解，但这不是停药的理由，必须复查后再决定。',
    diet: '许多方案会用低碳水、高蛋白的食物，但肾病等并存病会改变选择。不要同时频繁更换粮食和胰岛素。',
    water: '多饮是常见表现，也是居家观察指标。喝水突然大增或几乎不喝，都要反馈。',
    medication: '胰岛素种类和剂量只按处方。漏打、打重或自己改单位都可能危险。出现低血糖先联系兽医或急诊。',
    recheck: '调整期可能数天到 2 周就要复查血糖曲线；稳定后多为数周到 3 个月，含果糖胺或连续血糖。',
    recheckDays: 30,
    monitoring: '食欲、饮水、尿量、体重，以及兽医教过的居家血糖。软弱、走路不稳、抽搐要当成可能的低血糖。',
    redFlags: ['抽搐、虚脱', '完全不吃', '呕吐且精神差', '呼吸深或有烂苹果样气味'],
    sources: 'ISFM 猫糖尿病共识；AAHA 糖尿病管理原则',
    trackWater: true,
  ),
  DiseaseInfo(
    id: 'hyperthyroid',
    name: '甲亢',
    summary: '老年猫更常见。治疗可以是药物、处方饮食或放射性碘等，选哪种要看心肾情况和兽医的评估。',
    diet: '碘限制处方粮若被选用，必须作为几乎唯一的食物，不能同时大量吃别的零食。是否适用由兽医决定。',
    water: '甲亢和治疗后的肾功能变化都可能影响饮水。继续记录饮水和体重。',
    medication: '抗甲状腺药要按时按剂量给。不要因为“看起来胖回来了”就自己减药。',
    recheck: '开始药物后通常 2–3 周复查 T4 和肾功能，稳定后约每 3 个月，或按医嘱。',
    recheckDays: 21,
    monitoring: '体重、食欲、呕吐、饮水量、心率如果兽医教过。治疗后体重上升往往是预期变化。',
    redFlags: ['极度虚弱', '呼吸困难', '脖子处明显肿胀或疼痛', '完全拒食'],
    sources: 'AAFP 猫甲亢管理指南',
    trackWater: true,
  ),
  DiseaseInfo(
    id: 'hcm',
    name: '肥厚型心肌病',
    summary: 'HCM 需要超声诊断。缅因猫、布偶等品种风险更高，但任何猫都可能发生。听诊没有杂音也不能排除。',
    diet: '没有一种家用“护心粮”能替代心脏病随访。有心衰时，钠和水分管理听心脏病医生的。',
    water: '不要为了“减轻心脏负担”而限制喝水，除非兽医明确要求。',
    medication: '预防血栓、控制心率或利尿的药物都是处方。猫不能吃人用的许多止痛药和心脏病偏方。',
    recheck: '无症状时常见约每 6–12 个月超声；已经用药或有心衰史则更密。',
    recheckDays: 180,
    monitoring: '安静时的呼吸频率（兽医教过再数）、活动耐力、后肢突然疼痛或发凉。',
    redFlags: ['张口呼吸、腹式急促呼吸', '牙龈发紫或发白', '后肢突然不能走、冰凉', '晕倒'],
    sources: 'ACVIM 心肌病共识；品种猫筛查实践',
  ),
  DiseaseInfo(
    id: 'stomatitis',
    name: '口炎与牙病',
    summary: '口炎、牙吸收和牙周病都会让猫疼到不吃。家庭刷牙不能代替口腔检查，更不能代替麻醉下治疗。',
    diet: '疼痛时兽医可能短期建议软食或湿粮。长期饮食要在口腔处理后重新评估，避免只喂零食。',
    water: '嘴疼的猫可能少喝水。可以提供浅碗湿粮，并观察饮水是否下降。',
    medication: '止痛和抗炎必须使用猫能用的处方。对乙酰氨基酚、布洛芬等对人安全的药可能让猫中毒。',
    recheck: '治疗后常在 1–2 周复查口腔；稳定后每 6–12 个月，或一出现口臭、流涎就提前。',
    recheckDays: 180,
    monitoring: '口臭、流涎、用爪抓嘴、偏侧咀嚼、吃两口就走开、体重下降。',
    redFlags: ['完全拒食', '口腔大量出血', '脸部明显肿胀', '精神很差'],
    sources: 'AAHA 牙科护理指南中适用于猫的原则；牙科处置需全身麻醉',
  ),
  DiseaseInfo(
    id: 'obesity',
    name: '肥胖',
    summary: '肥胖增加糖尿病、关节和泌尿问题的风险。减重目标应由兽医按体态评分来定，不要追求某一个“标准体重”。',
    diet: '减重粮或减量都要算进零食。减得太快有脂肪肝风险，所以不要突然断粮或大幅减量。',
    water: '湿粮有助于增加水分，但不能替代兽医制定的热量。继续记体重，而不是只看碗空了没有。',
    medication: '没有可以自行购买的“减肥药”推荐。任何药物都要排除甲亢、糖尿病等原因后再说。',
    recheck: '减重期间建议每 2–4 周称一次体重，并按兽医约定复诊，确认下降速度安全。',
    recheckDays: 28,
    monitoring: '每周体重、体态、食欲和活动。下降过快或突然不吃都要停下来问兽医。',
    redFlags: ['突然拒食', '皮肤和眼白发黄', '虚弱', '减重过程中呕吐'],
    sources: 'AAHA 体重管理指南中适用于猫的原则；猫脂肪肝风险',
    trackWater: false,
  ),
  DiseaseInfo(
    id: 'ibd',
    name: '肠道炎症与胰腺炎',
    summary: 'IBD 和胰腺炎可以同时存在，症状都像呕吐、腹泻、食欲差。确诊通常要排除寄生虫、感染和其它器官问题。',
    diet: '兽医可能试用易消化或水解蛋白食物。一次只改一个变量，不要隔天换牌子。',
    water: '呕吐和腹泻会丢水。主动喝水是好事，但精神差时不要只在家补水观察。',
    medication: '止吐、止痛、维生素 B12 或抗炎治疗都按处方。不要自行使用激素或抗生素。',
    recheck: '发作缓解后常在 2–6 周复查体重和症状；慢性病例按医嘱拉长。',
    recheckDays: 42,
    monitoring: '呕吐和腹泻次数、大便形态、食欲、体重。便血或黑便要记录清楚。',
    redFlags: ['持续呕吐', '血便或黑便', '腹痛、弓背', '完全不吃或精神崩溃'],
    sources: 'ISFM 猫慢性肠道病与胰腺炎相关共识',
  ),
  DiseaseInfo(
    id: 'fip',
    name: '猫传染性腹膜炎',
    summary: 'FIP 的诊断和抗病毒治疗都必须由兽医确认和监测。不要自行购买来源不明的药物或照搬别人的剂量。',
    diet: '治疗期间优先保证吃得下：适口性好、兽医没有禁止的完整猫粮。体重上升是重要的居家信号。',
    water: '有胸水或腹水时不要自行“排水”或限制饮水。饮水变少合并不吃，要马上联系兽医。',
    medication: '抗病毒药、支持治疗和对症药物只在兽医方案里使用。疗程中的剂量调整不是家庭决定。',
    recheck: '治疗早期可能每 1–2 周复查血液和体重，之后按方案拉长。停药与否由兽医判断。',
    recheckDays: 14,
    monitoring: '体重、体温（若兽医要求）、食欲、腹围、呼吸和活动。把数值记下来比形容“好一点”有用。',
    redFlags: ['呼吸困难', '腹围迅速增大', '高热不退且不吃', '黄疸、抽搐或虚脱'],
    sources: 'AAFP 等关于猫冠状病毒与 FIP 的临床指引；治疗方案以当面兽医为准',
  ),
  DiseaseInfo(
    id: 'uri',
    name: '上呼吸道感染',
    summary: '猫鼻支（疱疹病毒）和杯状病毒是常见原因。多数轻症需要支持护理，但幼猫、不吃或呼吸费力时不能只在家观察。',
    diet: '鼻子堵时闻不到味道，可以短期把湿粮稍微温热。食欲超过兽医给的时限还没恢复，就要复诊。',
    water: '保持饮水。环境可以适度加湿，但雾化用药必须先问兽医，不要用人用吸入剂。',
    medication: '是否使用抗病毒滴眼液、止痛或抗生素，由兽医根据结膜、口腔溃疡和全身情况决定。',
    recheck: '轻症若按医嘱在家护理，常在 7–14 天内评估；加重则提前。',
    recheckDays: 14,
    monitoring: '喷嚏、鼻涕颜色、眼睛分泌物、口腔溃疡、食欲。和其他猫隔离，直到兽医认为风险下降。',
    redFlags: ['张口呼吸', '完全不吃', '幼猫沉郁', '眼睛明显疼痛或角膜发白'],
    sources: 'AAFP 猫上呼吸道感染与疱疹病毒指引',
  ),
  DiseaseInfo(
    id: 'skin',
    name: '皮肤病与过敏',
    summary: '瘙痒可能是跳蚤、食物、环境过敏、寄生虫或感染。在确认原因前，不要长期使用含激素的喷剂。',
    diet: '食物排除试验要严格、足够长，并由兽医设计。试验期间不能加零食和化毛膏。',
    water: '皮肤病本身不靠喝水治疗。若猫因为戴圈或口腔不适少喝，再单独记录。',
    medication: '外驱、抗组胺或免疫调节都要处方。狗用的驱虫和皮肤药可能对猫有毒。',
    recheck: '排除试验或新药开始后，常见约 2–4 周复查皮肤和瘙痒程度。',
    recheckDays: 28,
    monitoring: '瘙痒部位、脱毛、结痂、是否还在抓。拍照比回忆更可靠。',
    redFlags: ['脸部或耳部迅速肿胀', '呼吸困难', '皮肤大面积破溃、流脓', '精神差并发烧'],
    sources: 'ISFM 等猫过敏性皮炎实践；跳蚤防控是评估的一部分',
  ),
  DiseaseInfo(
    id: 'arthritis',
    name: '关节炎',
    summary: '猫的关节痛经常表现为不再跳上桌子、毛发变乱、砂盆旁失误，而不是明显跛行。诊断需要兽医，老年猫更常见。',
    diet: '超重会加重关节负担。减重计划见肥胖条目，速度由兽医控制。关节保健品不能替代止痛评估。',
    water: '把水碗放到不必跳高的位置。饮水变化仍要记录，以便和肾病、甲亢区分。',
    medication: '止痛药只能用兽医开的猫用制剂。人用布洛芬、对乙酰氨基酚等会导致猫中毒。',
    recheck: '开始止痛后常在 2–4 周评估效果和血液；稳定后约每 3–6 个月。',
    recheckDays: 90,
    monitoring: '跳跃高度、砂盆使用、理毛、脾气和体重。可以按周记一次“还能跳上哪里”。',
    redFlags: ['突然不能走路', '后肢冰凉、疼痛（要排除血栓）', '用药后呕吐、不吃', '黑便'],
    sources: 'AAFP/ISFM 关于猫退行性关节病的护理原则',
    trackWater: true,
  ),
];

DiseaseInfo? diseaseById(String id) {
  for (final disease in diseaseCatalog) {
    if (disease.id == id) return disease;
  }
  return null;
}
