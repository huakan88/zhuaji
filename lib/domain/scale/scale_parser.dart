/// Byte parsers for Bluetooth bathroom scales. Pure Dart, no plugin types,
/// so every rule here is unit tested.
///
/// Written from public protocol notes, not checked against a real scale:
/// - Bluetooth SIG Weight Scale Service (0x181D), Weight Measurement 0x2A9D.
/// - Xiaomi Mi Body Composition Scale 2 (XMTZC02HM / XMTZC05HM), advertised
///   as 0x181B service data. Layout per openScale `BluetoothMiScale2` and
///   github.com/freenetwork/ble-in-xiaomi `huami.health.scale2.md`.
/// - Xiaomi Mi Scale 1 (XMTZC01HM), advertised as 0x181D service data.
library;

enum ScaleProtocol { miScale2, miScale1, standard }

enum ScaleUnit { kg, lb, jin }

const _poundKg = 0.45359237;

class ScaleReading {
  const ScaleReading({
    required this.kg,
    required this.stable,
    required this.protocol,
    this.unit = ScaleUnit.kg,
  });

  final double kg;

  /// The scale has settled (Xiaomi: the number blinks). Standard scales only
  /// send finished measurements, so theirs are always stable.
  final bool stable;
  final ScaleProtocol protocol;

  /// Unit shown on the scale display; [kg] is always converted to kilograms.
  final ScaleUnit unit;

  @override
  String toString() =>
      'ScaleReading(${kg.toStringAsFixed(3)} kg, stable: $stable, $protocol)';
}

const bodyCompositionService = '0000181b-0000-1000-8000-00805f9b34fb';
const weightScaleService = '0000181d-0000-1000-8000-00805f9b34fb';
const weightMeasurementChar = '00002a9d-0000-1000-8000-00805f9b34fb';

double _toKg(int raw, ScaleUnit unit) => switch (unit) {
  ScaleUnit.kg => raw / 200,
  ScaleUnit.lb => raw / 100 * _poundKg,
  ScaleUnit.jin => raw / 100 / 2,
};

int _u16(List<int> data, int offset) =>
    (data[offset] & 0xff) | ((data[offset + 1] & 0xff) << 8);

bool _bit(int byte, int bit) => (byte >> bit) & 1 == 1;

/// Mi Body Composition Scale 2, 13-byte 0x181B service data.
///
/// Byte 0 bit 0 = pounds. Byte 1: bit 7 = nothing on the scale, bit 6 = jin,
/// bit 5 = stabilized, bit 1 = impedance present. Bytes 11-12 weight, LE.
/// Returns null for short frames and empty-scale frames.
ScaleReading? parseMiScale2(List<int> data) {
  if (data.length < 13) return null;
  final control0 = data[0];
  final control1 = data[1];
  if (_bit(control1, 7)) return null;
  final unit = _bit(control0, 0)
      ? ScaleUnit.lb
      : _bit(control1, 6)
      ? ScaleUnit.jin
      : ScaleUnit.kg;
  final raw = _u16(data, 11);
  if (raw == 0) return null;
  return ScaleReading(
    kg: _toKg(raw, unit),
    stable: _bit(control1, 5),
    protocol: ScaleProtocol.miScale2,
    unit: unit,
  );
}

/// Mi Scale 1, 10-byte 0x181D service data.
///
/// Byte 0: bit 0 = pounds, bit 4 = jin, bit 5 = stabilized, bit 7 = removed.
/// Bytes 1-2 weight, LE.
ScaleReading? parseMiScale1(List<int> data) {
  if (data.length < 3) return null;
  final control = data[0];
  if (_bit(control, 7)) return null;
  final unit = _bit(control, 0)
      ? ScaleUnit.lb
      : _bit(control, 4)
      ? ScaleUnit.jin
      : ScaleUnit.kg;
  final raw = _u16(data, 1);
  if (raw == 0) return null;
  return ScaleReading(
    kg: _toKg(raw, unit),
    stable: _bit(control, 5),
    protocol: ScaleProtocol.miScale1,
    unit: unit,
  );
}

/// Bluetooth SIG Weight Measurement (0x2A9D), sent by indication.
///
/// Flags bit 0: 0 = SI (0.005 kg steps), 1 = imperial (0.01 lb steps).
/// Bit 1 time stamp (7 bytes), bit 2 user id (1), bit 3 BMI + height (4)
/// follow the weight, so they only change the minimum length.
/// 0xFFFF means "measurement unsuccessful".
ScaleReading? parseWeightMeasurement(List<int> data) {
  if (data.length < 3) return null;
  final flags = data[0];
  var needed = 3;
  if (_bit(flags, 1)) needed += 7;
  if (_bit(flags, 2)) needed += 1;
  if (_bit(flags, 3)) needed += 4;
  if (data.length < needed) return null;
  final raw = _u16(data, 1);
  if (raw == 0xffff || raw == 0) return null;
  final imperial = _bit(flags, 0);
  return ScaleReading(
    kg: imperial ? raw * 0.01 * _poundKg : raw * 0.005,
    stable: true,
    protocol: ScaleProtocol.standard,
    unit: imperial ? ScaleUnit.lb : ScaleUnit.kg,
  );
}

/// Picks the right parser from advertised service data, keyed by the
/// 128-bit service UUID in lower case.
ScaleReading? parseAdvertisement(Map<String, List<int>> serviceData) {
  final mi2 = serviceData[bodyCompositionService];
  if (mi2 != null) return parseMiScale2(mi2);
  final mi1 = serviceData[weightScaleService];
  if (mi1 != null && mi1.length >= 10) return parseMiScale1(mi1);
  return null;
}

/// Cat weight from 「抱猫称」 minus the owner alone, in kg with two decimals.
/// Null when the difference cannot be a cat (forgot the cat, wrong order).
double? catWeightFrom({required double togetherKg, required double ownerKg}) {
  final diff = togetherKg - ownerKg;
  if (diff < minCatKg || diff > maxCatKg) return null;
  // Grams first, so float noise like 4.35499999 still rounds to 4.36.
  final grams = (diff * 1000).round();
  return (grams / 10).round() / 100;
}

const minCatKg = 0.3;
const maxCatKg = 15.0;
