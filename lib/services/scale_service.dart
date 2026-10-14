import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../domain/scale/scale_parser.dart';

enum ScaleStatus { ready, off, unsupported, denied }

/// Where the scale page gets weights from. The page never talks to the
/// Bluetooth plugin directly, so tests can feed readings by hand.
abstract class ScaleSource {
  Future<ScaleStatus> prepare();

  /// Readings from any supported scale nearby, until [stop].
  /// Errors on the stream mean the scan itself failed (permission, radio).
  Stream<ScaleReading> readings();

  Future<void> stop();
}

class BleScaleSource implements ScaleSource {
  StreamController<ScaleReading>? _out;
  StreamSubscription<List<ScanResult>>? _scan;
  StreamSubscription<List<int>>? _values;
  BluetoothDevice? _device;
  var _connecting = false;

  @override
  Future<ScaleStatus> prepare() async {
    try {
      if (!await FlutterBluePlus.isSupported) return ScaleStatus.unsupported;
      var state = await FlutterBluePlus.adapterState
          .where((value) => value != BluetoothAdapterState.unknown)
          .first
          .timeout(const Duration(seconds: 3));
      if (state == BluetoothAdapterState.unauthorized) {
        return ScaleStatus.denied;
      }
      if (state != BluetoothAdapterState.on &&
          defaultTargetPlatform == TargetPlatform.android) {
        try {
          await FlutterBluePlus.turnOn();
          state = await FlutterBluePlus.adapterState
              .firstWhere((value) => value == BluetoothAdapterState.on)
              .timeout(const Duration(seconds: 8));
        } catch (_) {
          return ScaleStatus.off;
        }
      }
      return state == BluetoothAdapterState.on
          ? ScaleStatus.ready
          : ScaleStatus.off;
    } on TimeoutException {
      return ScaleStatus.off;
    } catch (error) {
      debugPrint('蓝牙准备失败：$error');
      return ScaleStatus.unsupported;
    }
  }

  @override
  Stream<ScaleReading> readings() {
    _out?.close();
    final out = _out = StreamController<ScaleReading>();
    _start(out);
    return out.stream;
  }

  Future<void> _start(StreamController<ScaleReading> out) async {
    try {
      _scan = FlutterBluePlus.onScanResults.listen((results) {
        for (final result in results) {
          _handle(result, out);
        }
      }, onError: out.addError);
      await FlutterBluePlus.startScan(
        continuousUpdates: true,
        timeout: const Duration(minutes: 3),
      );
    } catch (error) {
      if (!out.isClosed) out.addError(error);
    }
  }

  void _handle(ScanResult result, StreamController<ScaleReading> out) {
    final ad = result.advertisementData;
    final data = {
      for (final entry in ad.serviceData.entries)
        entry.key.str128.toLowerCase(): entry.value,
    };
    final reading = parseAdvertisement(data);
    if (reading != null) {
      if (!out.isClosed) out.add(reading);
      return;
    }
    final standard = ad.serviceUuids.any(
      (uuid) => uuid.str128.toLowerCase() == weightScaleService,
    );
    if (standard && !data.containsKey(weightScaleService)) {
      _connectStandard(result.device, out);
    }
  }

  /// Standard scales keep the weight behind a GATT indication.
  Future<void> _connectStandard(
    BluetoothDevice device,
    StreamController<ScaleReading> out,
  ) async {
    if (_connecting || _device != null) return;
    _connecting = true;
    try {
      await FlutterBluePlus.stopScan();
      await device.connect(timeout: const Duration(seconds: 12), mtu: null);
      _device = device;
      final services = await device.discoverServices();
      for (final service in services) {
        if (service.uuid.str128.toLowerCase() != weightScaleService) continue;
        for (final char in service.characteristics) {
          if (char.uuid.str128.toLowerCase() != weightMeasurementChar) {
            continue;
          }
          _values = char.onValueReceived.listen((value) {
            final reading = parseWeightMeasurement(value);
            if (reading != null && !out.isClosed) out.add(reading);
          });
          device.cancelWhenDisconnected(_values!);
          await char.setNotifyValue(true);
          return;
        }
      }
      throw StateError('这台秤没有体重数据');
    } catch (error) {
      if (!out.isClosed) out.addError(error);
    } finally {
      _connecting = false;
    }
  }

  @override
  Future<void> stop() async {
    await _scan?.cancel();
    _scan = null;
    await _values?.cancel();
    _values = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    final device = _device;
    _device = null;
    if (device != null) {
      try {
        await device.disconnect();
      } catch (_) {}
    }
    await _out?.close();
    _out = null;
  }
}
