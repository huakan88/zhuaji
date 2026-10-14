import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/health/lab_catalog.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/domain/parsing/lab_report_parser.dart';
import 'package:maokangji/domain/parsing/ocr_lines.dart';

void main() {
  const parser = LabReportParser();

  test('a Chinese CBC and chemistry sheet is read and flagged', () {
    final values = parser.parsePlain('''
白细胞 WBC 18.20 ×10^9/L 2.87-17.02
红细胞 RBC 8.10 10^12/L 6.54-12.20
血红蛋白 HGB 132 g/L 98-162
红细胞压积 HCT 41.2 % 30.3-52.3
血小板 PLT 88 10^9/L 151-600
谷丙转氨酶 ALT 210 U/L 12-130
碱性磷酸酶 ALP 40 U/L 14-111
尿素氮 BUN 9.2 mmol/L 5.7-12.9
肌酐 CREA 160 µmol/L 71-212
血糖 GLU 6.1 mmol/L 4.11-8.83
SDMA 18 µg/dL 0-14
中性粒细胞% NEU% 78.0
''');
    double valueOf(String code) =>
        values.firstWhere((item) => item.code == code).value;

    expect(valueOf('WBC'), 18.20);
    expect(valueOf('RBC'), 8.10);
    expect(valueOf('HGB'), 132);
    expect(valueOf('HCT'), 41.2);
    expect(valueOf('PLT'), 88);
    expect(valueOf('ALT'), 210);
    expect(valueOf('ALP'), 40);
    expect(valueOf('BUN'), 9.2);
    expect(valueOf('CREA'), 160);
    expect(valueOf('GLU'), 6.1);
    expect(valueOf('SDMA'), 18);
    expect(values.any((item) => item.code == 'NEU'), isFalse);
    expect(values.any((item) => item.code == 'PHOS'), isFalse);

    LabFlag flagOf(String code) => readLabValue(
      values.firstWhere((item) => item.code == code),
    )!.flag;
    expect(flagOf('WBC'), LabFlag.high);
    expect(flagOf('PLT'), LabFlag.low);
    expect(flagOf('ALT'), LabFlag.high);
    expect(flagOf('CREA'), LabFlag.normal);
    expect(flagOf('SDMA'), LabFlag.high);
    expect(flagOf('ALP'), LabFlag.normal);
  });

  test('MCHC is not read as MCH, and a missing number is skipped', () {
    final values = parser.parsePlain('''
MCHC 33.2 g/dL 28.1-35.8
MCH 14.2 pg 11.8-17.3
WBC
''');
    expect(values.map((item) => item.code), ['MCH', 'MCHC']);
    expect(values.firstWhere((item) => item.code == 'MCHC').value, 33.2);
    expect(values.firstWhere((item) => item.code == 'MCH').value, 14.2);
  });

  test('a value without a unit is read in the fitting unit', () {
    final hgb = parser.parseRow('HGB 14.2');
    expect(hgb, isNotNull);
    expect(hgb!.unit, 'g/dL');
    final reading = readLabValue(hgb);
    expect(reading!.flag, LabFlag.normal);

    final crea = parser.parseRow('CREA 1.6');
    expect(crea!.unit, 'mg/dL');
    expect(readLabValue(crea)!.flag, LabFlag.normal);
  });

  test('the printed range is used when the sheet has one', () {
    final value = parser.parseRow('ALT 20 U/L 5-15')!;
    final reading = readLabValue(value)!;
    expect(reading.fromReport, isTrue);
    expect(reading.flag, LabFlag.high);
    expect(reading.sentence, contains('肝'));
  });

  test('cells of one printed row are joined before parsing', () {
    final rows = rowsFromLines(const [
      OcrLine('WBC', left: 10, top: 10, right: 40, bottom: 28),
      OcrLine('18.2', left: 80, top: 12, right: 120, bottom: 30),
      OcrLine('2.87-17.02', left: 140, top: 11, right: 220, bottom: 29),
      OcrLine('RBC', left: 10, top: 40, right: 40, bottom: 58),
      OcrLine('8.1', left: 80, top: 41, right: 110, bottom: 59),
    ]);
    expect(rows, ['WBC  18.2  2.87-17.02', 'RBC  8.1']);
    final values = parser.parse(OcrText(const [
      OcrLine('WBC', left: 10, top: 10, right: 40, bottom: 28),
      OcrLine('18.2', left: 80, top: 12, right: 120, bottom: 30),
    ]));
    expect(values.single.value, 18.2);
  });

  test('plain sentences name the flag and the source is recorded', () {
    final high = readLabValue(
      const LabValue(code: 'GLU', value: 12, unit: 'mmol/L'),
    )!;
    expect(high.flagLabel, '偏高');
    expect(high.sentence, contains('血糖'));
    expect(labDisclaimer, '仅供参考，以兽医诊断为准');
    expect(labRangeSource, contains('IDEXX'));
    expect(labRangeSource, contains('ProCyte'));
    expect(labRangeSource, contains('Catalyst'));
  });
}
