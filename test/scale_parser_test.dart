// Frames are built by hand from the protocol notes cited in
// lib/domain/scale/scale_parser.dart. Not captured from a real scale.
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/scale/scale_parser.dart';

/// 13-byte Mi Body Composition Scale 2 service data.
List<int> mi2({
  required int raw,
  int control0 = 0x02,
  int control1 = 0x22,
  int impedance = 500,
}) => [
  control0,
  control1,
  0xEA, 0x07, // 2026
  10, 12, 9, 30, 0,
  impedance & 0xff, impedance >> 8,
  raw & 0xff, raw >> 8,
];

/// 10-byte Mi Scale 1 service data.
List<int> mi1({required int raw, int control = 0x22}) => [
  control,
  raw & 0xff,
  raw >> 8,
  0xEA,
  0x07,
  10,
  12,
  9,
  30,
  0,
];

void main() {
  group('Mi Body Composition Scale 2 (0x181B)', () {
    test('stable kg frame: raw / 200', () {
      final reading = parseMiScale2(mi2(raw: 12480))!;
      expect(reading.kg, closeTo(62.40, 1e-9));
      expect(reading.stable, isTrue);
      expect(reading.unit, ScaleUnit.kg);
      expect(reading.protocol, ScaleProtocol.miScale2);
    });

    test('a cat-sized weight keeps 0.005 kg resolution', () {
      expect(parseMiScale2(mi2(raw: 871))!.kg, closeTo(4.355, 1e-9));
    });

    test('still settling: not stable', () {
      final reading = parseMiScale2(mi2(raw: 12480, control1: 0x02))!;
      expect(reading.stable, isFalse);
      expect(reading.kg, closeTo(62.40, 1e-9));
    });

    test('empty load (byte 1 bit 7) is dropped', () {
      expect(parseMiScale2(mi2(raw: 12480, control1: 0xA2)), isNull);
    });

    test('jin (byte 1 bit 6): raw / 100 / 2', () {
      final reading = parseMiScale2(mi2(raw: 12480, control1: 0x62))!;
      expect(reading.unit, ScaleUnit.jin);
      expect(reading.kg, closeTo(62.40, 1e-9));
    });

    test('pounds (byte 0 bit 0): raw / 100 lb', () {
      final reading = parseMiScale2(mi2(raw: 13757, control0: 0x03))!;
      expect(reading.unit, ScaleUnit.lb);
      expect(reading.kg, closeTo(62.40, 0.005));
    });

    test('weight is little endian at bytes 11-12', () {
      final frame = mi2(raw: 0x30C0);
      expect(frame[11], 0xC0);
      expect(frame[12], 0x30);
      expect(parseMiScale2(frame)!.kg, closeTo(0x30C0 / 200, 1e-9));
    });

    test('short or zero frames are ignored', () {
      expect(parseMiScale2(mi2(raw: 12480).sublist(0, 12)), isNull);
      expect(parseMiScale2(const []), isNull);
      expect(parseMiScale2(mi2(raw: 0)), isNull);
    });
  });

  group('Mi Scale 1 (0x181D service data)', () {
    test('stable kg', () {
      final reading = parseMiScale1(mi1(raw: 12480))!;
      expect(reading.kg, closeTo(62.40, 1e-9));
      expect(reading.stable, isTrue);
      expect(reading.protocol, ScaleProtocol.miScale1);
    });

    test('jin and pounds', () {
      expect(parseMiScale1(mi1(raw: 12480, control: 0x32))!.kg, 62.40);
      expect(
        parseMiScale1(mi1(raw: 13757, control: 0x23))!.kg,
        closeTo(62.40, 0.005),
      );
    });

    test('removed (bit 7) and unstable', () {
      expect(parseMiScale1(mi1(raw: 12480, control: 0xA2)), isNull);
      expect(parseMiScale1(mi1(raw: 12480, control: 0x02))!.stable, isFalse);
    });
  });

  group('Bluetooth SIG Weight Measurement (0x2A9D)', () {
    test('SI: 0.005 kg per step', () {
      final reading = parseWeightMeasurement([0x00, 0xC0, 0x30])!;
      expect(reading.kg, closeTo(62.40, 1e-9));
      expect(reading.stable, isTrue);
      expect(reading.unit, ScaleUnit.kg);
      expect(reading.protocol, ScaleProtocol.standard);
    });

    test('imperial: 0.01 lb per step', () {
      final reading = parseWeightMeasurement([0x01, 0xBD, 0x35])!;
      expect(reading.unit, ScaleUnit.lb);
      expect(reading.kg, closeTo(62.40, 0.005));
    });

    test('time stamp, user id, BMI and height after the weight', () {
      final full = [
        0x0E,
        0xC0, 0x30,
        0xEA, 0x07, 10, 12, 9, 30, 0, // time stamp
        0x01, // user
        0xF4, 0x00, 0x2E, 0x06, // BMI 24.4, height 1.582 m
      ];
      expect(parseWeightMeasurement(full)!.kg, closeTo(62.40, 1e-9));
      expect(parseWeightMeasurement(full.sublist(0, 14)), isNull);
    });

    test('0xFFFF means the measurement failed', () {
      expect(parseWeightMeasurement([0x00, 0xFF, 0xFF]), isNull);
    });

    test('too short', () {
      expect(parseWeightMeasurement([0x00, 0xC0]), isNull);
      expect(parseWeightMeasurement([0x02, 0xC0, 0x30, 0xEA]), isNull);
    });
  });

  group('advertisement dispatch', () {
    test('0x181B goes to Mi Scale 2', () {
      final reading = parseAdvertisement({
        bodyCompositionService: mi2(raw: 12480),
      })!;
      expect(reading.protocol, ScaleProtocol.miScale2);
    });

    test('0x181D service data goes to Mi Scale 1', () {
      final reading = parseAdvertisement({weightScaleService: mi1(raw: 900)})!;
      expect(reading.protocol, ScaleProtocol.miScale1);
      expect(reading.kg, closeTo(4.5, 1e-9));
    });

    test('anything else is not a scale', () {
      expect(parseAdvertisement({}), isNull);
      expect(
        parseAdvertisement({
          '0000fe95-0000-1000-8000-00805f9b34fb': [1, 2, 3],
        }),
        isNull,
      );
      expect(
        parseAdvertisement({
          weightScaleService: const [0x22, 1],
        }),
        isNull,
      );
    });
  });

  group('抱猫称 minus 自己', () {
    test('keeps two decimals', () {
      expect(catWeightFrom(togetherKg: 66.755, ownerKg: 62.40), 4.36);
      expect(catWeightFrom(togetherKg: 66.75, ownerKg: 62.40), 4.35);
    });

    test('rejects a difference that cannot be a cat', () {
      expect(catWeightFrom(togetherKg: 62.50, ownerKg: 62.40), isNull);
      expect(catWeightFrom(togetherKg: 60, ownerKg: 62.40), isNull);
      expect(catWeightFrom(togetherKg: 80, ownerKg: 62.40), isNull);
    });
  });
}
