import '../models.dart';

/// Where the built-in reference ranges come from. Shown under every result.
const labRangeSource =
    '参考范围：IDEXX ProCyte Dx 血常规猫参考区间、IDEXX Catalyst 生化成年猫参考区间'
    '（含 SDMA、TT4）。不同医院和仪器的范围不同，化验单上印了范围时以单上的为准。';

const labDisclaimer = '仅供参考，以兽医诊断为准';

enum LabFlag { low, normal, high }

class LabUnit {
  const LabUnit(this.label, this.toBase, {this.aliases = const []});

  final String label;

  /// Multiply a value in this unit to get the analyte's base unit.
  final double toBase;
  final List<String> aliases;
}

class LabAnalyte {
  const LabAnalyte({
    required this.code,
    required this.name,
    required this.kind,
    required this.aliases,
    required this.units,
    required this.low,
    required this.high,
    required this.highText,
    required this.lowText,
    this.decimals = 1,
  });

  final String code;
  final String name;
  final LabKind kind;

  /// Names seen on Chinese and English reports. ASCII ones match as whole
  /// words, case-insensitive.
  final List<String> aliases;

  /// First unit is the base unit the ranges are written in.
  final List<LabUnit> units;
  final double low;
  final double high;
  final String highText;
  final String lowText;

  /// How many decimals to show and to offer on the wheels.
  final int decimals;

  LabUnit get base => units.first;

  LabUnit unitFor(String label) {
    final key = normalizeUnit(label);
    if (key.isEmpty) return base;
    for (final unit in units) {
      if (normalizeUnit(unit.label) == key) return unit;
      for (final alias in unit.aliases) {
        if (normalizeUnit(alias) == key) return unit;
      }
    }
    return base;
  }
}

String normalizeUnit(String raw) => raw
    .toLowerCase()
    .replaceAll(RegExp(r'\s'), '')
    .replaceAll('μ', 'u')
    .replaceAll('µ', 'u')
    .replaceAll('×', 'x')
    .replaceAll('*', '^')
    .replaceAll('x10', '10');

const _cell9 = [
  LabUnit(
    '10^9/L',
    1,
    aliases: ['10^9/l', '109/L', 'K/uL', '10^3/uL', '103/uL', 'x10^9/L'],
  ),
];

const _cell12 = [
  LabUnit(
    '10^12/L',
    1,
    aliases: ['1012/L', 'M/uL', '10^6/uL', '106/uL', 'x10^12/L'],
  ),
];

const _gPerL = [
  LabUnit('g/L', 1),
  LabUnit('g/dL', 10),
];

const _enzyme = [
  LabUnit('U/L', 1, aliases: ['IU/L']),
];

const labCatalog = <LabAnalyte>[
  LabAnalyte(
    code: 'WBC',
    name: '白细胞',
    kind: LabKind.cbc,
    aliases: ['WBC', '白细胞计数', '白细胞'],
    units: _cell9,
    low: 2.87,
    high: 17.02,
    decimals: 2,
    highText: '白细胞偏高，常见于炎症、感染，猫紧张时也会暂时升高。',
    lowText: '白细胞偏低，可能和病毒感染或骨髓问题有关，值得复查。',
  ),
  LabAnalyte(
    code: 'NEU',
    name: '中性粒细胞',
    kind: LabKind.cbc,
    aliases: ['NEU#', 'NEUT#', 'GRAN#', 'NEU', 'NEUT', 'GRAN', '中性粒细胞数', '中性粒细胞'],
    units: _cell9,
    low: 2.30,
    high: 10.29,
    decimals: 2,
    highText: '中性粒细胞偏高，多见于细菌感染、炎症或应激。',
    lowText: '中性粒细胞偏低，抵抗力可能下降，请让医生看看原因。',
  ),
  LabAnalyte(
    code: 'LYM',
    name: '淋巴细胞',
    kind: LabKind.cbc,
    aliases: ['LYM#', 'LYMPH#', 'LYM', 'LYMPH', '淋巴细胞数', '淋巴细胞'],
    units: _cell9,
    low: 0.92,
    high: 6.88,
    decimals: 2,
    highText: '淋巴细胞偏高，年轻猫和兴奋时常见，持续偏高要复查。',
    lowText: '淋巴细胞偏低，常见于紧张应激或生病时。',
  ),
  LabAnalyte(
    code: 'MONO',
    name: '单核细胞',
    kind: LabKind.cbc,
    aliases: ['MONO#', 'MON#', 'MONO', 'MON', '单核细胞数', '单核细胞'],
    units: _cell9,
    low: 0.05,
    high: 0.67,
    decimals: 2,
    highText: '单核细胞偏高，可能有慢性炎症或组织损伤。',
    lowText: '单核细胞偏低，单看这一项意义不大。',
  ),
  LabAnalyte(
    code: 'EOS',
    name: '嗜酸性粒细胞',
    kind: LabKind.cbc,
    aliases: ['EOS#', 'EOS', '嗜酸性粒细胞数', '嗜酸性粒细胞'],
    units: _cell9,
    low: 0.17,
    high: 1.57,
    decimals: 2,
    highText: '嗜酸性粒细胞偏高，常见于寄生虫、过敏或哮喘。',
    lowText: '嗜酸性粒细胞偏低，常见于应激，一般不用担心。',
  ),
  LabAnalyte(
    code: 'RBC',
    name: '红细胞',
    kind: LabKind.cbc,
    aliases: ['RBC', '红细胞计数', '红细胞'],
    units: _cell12,
    low: 6.54,
    high: 12.20,
    decimals: 2,
    highText: '红细胞偏高，常见于脱水，血液变浓了。',
    lowText: '红细胞偏低，可能有贫血。',
  ),
  LabAnalyte(
    code: 'HGB',
    name: '血红蛋白',
    kind: LabKind.cbc,
    aliases: ['HGB', 'HB', '血红蛋白'],
    units: _gPerL,
    low: 98,
    high: 162,
    decimals: 0,
    highText: '血红蛋白偏高，常见于脱水。',
    lowText: '血红蛋白偏低，可能有贫血。',
  ),
  LabAnalyte(
    code: 'HCT',
    name: '红细胞压积',
    kind: LabKind.cbc,
    aliases: ['HCT', 'PCV', '红细胞压积', '红细胞比容', '压积'],
    units: [
      LabUnit('%', 1),
      LabUnit('L/L', 100),
    ],
    low: 30.3,
    high: 52.3,
    highText: '红细胞压积偏高，常见于脱水。',
    lowText: '红细胞压积偏低，是贫血的常用指标，建议问医生是否要复查。',
  ),
  LabAnalyte(
    code: 'MCV',
    name: '平均红细胞体积',
    kind: LabKind.cbc,
    aliases: ['MCV', '平均红细胞体积'],
    units: [LabUnit('fL', 1, aliases: ['fl'])],
    low: 35.9,
    high: 53.1,
    highText: '红细胞个头偏大，有时见于再生性贫血或采血放置过久。',
    lowText: '红细胞个头偏小，可能和缺铁有关。',
  ),
  LabAnalyte(
    code: 'MCH',
    name: '平均血红蛋白量',
    kind: LabKind.cbc,
    aliases: ['MCH', '平均红细胞血红蛋白量', '平均血红蛋白量', '平均血红蛋白含量'],
    units: [LabUnit('pg', 1)],
    low: 11.8,
    high: 17.3,
    highText: '每个红细胞里的血红蛋白偏多，常见于溶血或样本问题。',
    lowText: '每个红细胞里的血红蛋白偏少，可能和缺铁有关。',
  ),
  LabAnalyte(
    code: 'MCHC',
    name: '平均血红蛋白浓度',
    kind: LabKind.cbc,
    aliases: ['MCHC', '平均红细胞血红蛋白浓度', '平均血红蛋白浓度'],
    units: _gPerL,
    low: 281,
    high: 358,
    decimals: 0,
    highText: '血红蛋白浓度偏高，多数是溶血或脂血等样本问题。',
    lowText: '血红蛋白浓度偏低，可能有再生性贫血或缺铁。',
  ),
  LabAnalyte(
    code: 'PLT',
    name: '血小板',
    kind: LabKind.cbc,
    aliases: ['PLT', '血小板计数', '血小板'],
    units: _cell9,
    low: 151,
    high: 600,
    decimals: 0,
    highText: '血小板偏高，偶见于炎症或应激。',
    lowText: '血小板偏低。猫的血小板采血时容易结块，常造成假性偏低，可请医生看血涂片。',
  ),
  LabAnalyte(
    code: 'ALT',
    name: '谷丙转氨酶',
    kind: LabKind.chem,
    aliases: ['ALT', 'GPT', '谷丙转氨酶', '丙氨酸氨基转移酶'],
    units: _enzyme,
    low: 12,
    high: 130,
    decimals: 0,
    highText: '肝细胞可能受损，常见于肝病、甲亢或用药后。',
    lowText: '偏低一般没有临床意义。',
  ),
  LabAnalyte(
    code: 'ALP',
    name: '碱性磷酸酶',
    kind: LabKind.chem,
    aliases: ['ALKP', 'ALP', '碱性磷酸酶'],
    units: _enzyme,
    low: 14,
    high: 111,
    decimals: 0,
    highText: '猫的碱性磷酸酶升高多和肝胆问题或甲亢有关，值得复查。',
    lowText: '偏低一般没有临床意义。',
  ),
  LabAnalyte(
    code: 'GGT',
    name: '谷氨酰转移酶',
    kind: LabKind.chem,
    aliases: ['GGT', 'γ-GT', 'r-GT', 'γ-谷氨酰转移酶', '谷氨酰转移酶', '谷氨酰转肽酶'],
    units: _enzyme,
    low: 0,
    high: 4,
    decimals: 0,
    highText: '胆道可能有问题，建议结合碱性磷酸酶和胆红素看。',
    lowText: '偏低没有临床意义。',
  ),
  LabAnalyte(
    code: 'TBIL',
    name: '总胆红素',
    kind: LabKind.chem,
    aliases: ['TBIL', 'T-BIL', 'TBILI', '总胆红素'],
    units: [
      LabUnit('µmol/L', 1, aliases: ['umol/L']),
      LabUnit('mg/dL', 17.1),
    ],
    low: 0,
    high: 15,
    highText: '胆红素偏高，可能和肝胆问题或溶血有关，皮肤眼白发黄要尽快看医生。',
    lowText: '偏低没有临床意义。',
  ),
  LabAnalyte(
    code: 'TP',
    name: '总蛋白',
    kind: LabKind.chem,
    aliases: ['TP', 'TPRO', '总蛋白'],
    units: _gPerL,
    low: 57,
    high: 89,
    decimals: 0,
    highText: '总蛋白偏高，常见于脱水或慢性炎症。',
    lowText: '总蛋白偏低，可能和营养、肠道或肾脏丢失蛋白有关。',
  ),
  LabAnalyte(
    code: 'ALB',
    name: '白蛋白',
    kind: LabKind.chem,
    aliases: ['ALB', '白蛋白'],
    units: _gPerL,
    low: 22,
    high: 40,
    decimals: 0,
    highText: '白蛋白偏高，通常是脱水。',
    lowText: '白蛋白偏低，可能和肝脏、肠道或肾脏有关。',
  ),
  LabAnalyte(
    code: 'GLOB',
    name: '球蛋白',
    kind: LabKind.chem,
    aliases: ['GLOB', 'GLO', '球蛋白'],
    units: _gPerL,
    low: 28,
    high: 51,
    decimals: 0,
    highText: '球蛋白偏高，常见于慢性炎症或感染，个别情况和猫传腹有关，请问医生。',
    lowText: '球蛋白偏低，幼猫常见，成年猫偏低请问医生。',
  ),
  LabAnalyte(
    code: 'BUN',
    name: '尿素氮',
    kind: LabKind.chem,
    aliases: ['BUN', 'UREA', '尿素氮', '尿素', '血尿素氮'],
    units: [
      LabUnit('mmol/L', 1),
      LabUnit('mg/dL', 0.357),
    ],
    low: 5.7,
    high: 12.9,
    highText: '肾脏排废可能变慢，脱水或刚吃过高蛋白也会升高，要结合肌酐看。',
    lowText: '尿素氮偏低，可能和蛋白吃得少或肝功能有关。',
  ),
  LabAnalyte(
    code: 'CREA',
    name: '肌酐',
    kind: LabKind.chem,
    aliases: ['CREA', 'CREAT', 'CRE', '肌酐'],
    units: [
      LabUnit('µmol/L', 1, aliases: ['umol/L']),
      LabUnit('mg/dL', 88.4),
    ],
    low: 71,
    high: 212,
    decimals: 0,
    highText: '肌酐偏高，肾功能可能下降，要结合 SDMA 和尿比重看。',
    lowText: '肌酐偏低，常见于肌肉量少的猫，一般不用担心。',
  ),
  LabAnalyte(
    code: 'SDMA',
    name: '对称二甲基精氨酸',
    kind: LabKind.chem,
    aliases: ['SDMA', '对称二甲基精氨酸'],
    units: [
      LabUnit('µg/dL', 1, aliases: ['ug/dL']),
    ],
    low: 0,
    high: 14,
    decimals: 0,
    highText: 'SDMA 偏高，是肾功能早期变化的信号，建议复查肾功能。',
    lowText: '偏低没有临床意义。',
  ),
  LabAnalyte(
    code: 'GLU',
    name: '血糖',
    kind: LabKind.chem,
    aliases: ['GLU', 'GLUC', '葡萄糖', '血糖'],
    units: [
      LabUnit('mmol/L', 1),
      LabUnit('mg/dL', 0.0555),
    ],
    low: 4.11,
    high: 8.83,
    highText: '血糖偏高，猫紧张时常见应激性升高，持续偏高要排查糖尿病。',
    lowText: '血糖偏低，精神差、发抖时要尽快联系医生。',
  ),
  LabAnalyte(
    code: 'PHOS',
    name: '磷',
    kind: LabKind.chem,
    aliases: ['PHOS', 'IP', '无机磷', '血磷', '磷'],
    units: [
      LabUnit('mmol/L', 1),
      LabUnit('mg/dL', 0.323),
    ],
    low: 1.00,
    high: 2.42,
    decimals: 2,
    highText: '血磷偏高，常见于肾功能下降，幼猫生长期也会偏高。',
    lowText: '血磷偏低，偶见于糖尿病治疗中或营养不良。',
  ),
  LabAnalyte(
    code: 'CA',
    name: '钙',
    kind: LabKind.chem,
    aliases: ['CA', '总钙', '血钙', '钙'],
    units: [
      LabUnit('mmol/L', 1),
      LabUnit('mg/dL', 0.25),
    ],
    low: 1.95,
    high: 2.83,
    decimals: 2,
    highText: '血钙偏高，原因较多（含特发性高钙），需要医生进一步检查。',
    lowText: '血钙偏低，常和白蛋白偏低一起出现，请医生判断。',
  ),
  LabAnalyte(
    code: 'CHOL',
    name: '胆固醇',
    kind: LabKind.chem,
    aliases: ['CHOL', 'TC', '总胆固醇', '胆固醇'],
    units: [
      LabUnit('mmol/L', 1),
      LabUnit('mg/dL', 0.0259),
    ],
    low: 1.68,
    high: 5.81,
    decimals: 2,
    highText: '胆固醇偏高，饭后采血、肥胖或内分泌问题都可能导致。',
    lowText: '胆固醇偏低，可能和营养或肝脏有关。',
  ),
  LabAnalyte(
    code: 'TT4',
    name: '总甲状腺素',
    kind: LabKind.chem,
    aliases: ['TT4', 'T4', '总T4', '甲状腺素'],
    units: [
      LabUnit('nmol/L', 1),
      LabUnit('µg/dL', 12.87, aliases: ['ug/dL']),
    ],
    low: 10,
    high: 60,
    highText: 'T4 偏高，老年猫要考虑甲亢，体重下降、吃得多时更要留意。',
    lowText: 'T4 偏低，生病的猫常见，单看这一项不能说明甲减。',
  ),
];

LabAnalyte? analyteByCode(String code) {
  for (final item in labCatalog) {
    if (item.code == code) return item;
  }
  return null;
}

List<LabAnalyte> analytesFor(LabKind kind) => [
  for (final item in labCatalog)
    if (item.kind == kind) item,
];

class LabReading {
  const LabReading({
    required this.analyte,
    required this.flag,
    required this.low,
    required this.high,
    required this.fromReport,
  });

  final LabAnalyte analyte;
  final LabFlag flag;

  /// Range used for the flag, in the value's own unit.
  final double low;
  final double high;

  /// True when the range came from the report rather than [labCatalog].
  final bool fromReport;

  String get flagLabel => switch (flag) {
    LabFlag.low => '偏低',
    LabFlag.normal => '正常',
    LabFlag.high => '偏高',
  };

  String get sentence => switch (flag) {
    LabFlag.low => analyte.lowText,
    LabFlag.normal => '在参考范围内。',
    LabFlag.high => analyte.highText,
  };
}

/// Flags one value against the report's own range when it has one,
/// otherwise against [labCatalog] converted into the value's unit.
LabReading? readLabValue(LabValue value) {
  final analyte = analyteByCode(value.code);
  if (analyte == null) return null;
  final printedLow = value.printedLow;
  final printedHigh = value.printedHigh;
  late final double low;
  late final double high;
  final fromReport =
      printedLow != null && printedHigh != null && printedHigh > printedLow;
  if (fromReport) {
    low = printedLow;
    high = printedHigh;
  } else {
    final unit = analyte.unitFor(value.unit);
    low = analyte.low / unit.toBase;
    high = analyte.high / unit.toBase;
  }
  final flag = value.value < low
      ? LabFlag.low
      : value.value > high
      ? LabFlag.high
      : LabFlag.normal;
  return LabReading(
    analyte: analyte,
    flag: flag,
    low: low,
    high: high,
    fromReport: fromReport,
  );
}

/// Value in the analyte's base unit, so trends across units line up.
double? baseValue(LabValue value) {
  final analyte = analyteByCode(value.code);
  if (analyte == null) return null;
  return value.value * analyte.unitFor(value.unit).toBase;
}

String formatLabNumber(double value, int decimals) {
  final text = value.toStringAsFixed(decimals);
  return text;
}
