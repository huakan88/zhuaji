import 'package:flutter/services.dart';

/// Opens this app's system settings page so a denied camera can be allowed.
///
/// Tests and desktop runs have no handler. Callers then tell the person to
/// open 系统设置 by hand, and the form stays usable.
class SystemSettings {
  const SystemSettings();

  static const channel = MethodChannel('zhuaji/settings');

  Future<bool> open() async {
    try {
      await channel.invokeMethod<void>('open');
      return true;
    } catch (_) {
      return false;
    }
  }
}
