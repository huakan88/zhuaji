import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Home-screen widget. Android updates the launcher widget directly.
/// iOS stores the same JSON for `ios/TodayWidget` and opens `zhuaji://` routes.
/// Tests, and a build that has not registered the channel, ignore the miss.
class WidgetBridge {
  const WidgetBridge();

  static const channel = MethodChannel('zhuaji/widget');

  static Future<void> publish(Map<String, Object> payload) async {
    try {
      await channel.invokeMethod<void>('update', {'json': jsonEncode(payload)});
    } catch (error) {
      debugPrint('小组件没更新：$error');
    }
  }

  static void listen(void Function(String route) onOpen) {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'open' && call.arguments is String) {
        final route = call.arguments as String;
        if (route.isNotEmpty) onOpen(route);
      }
    });
  }

  static Future<String?> takeRoute() async {
    try {
      final route = await channel.invokeMethod<String>('takeRoute');
      if (route == null || route.isEmpty) return null;
      return route;
    } catch (error) {
      debugPrint('小组件入口没读到：$error');
      return null;
    }
  }
}
