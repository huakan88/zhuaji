package com.maokangji.maokangji

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "zhuaji/widget"
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "update" -> {
                    val json = call.argument<String>("json") ?: ""
                    getSharedPreferences(TodayWidgetProvider.PREFS, MODE_PRIVATE)
                        .edit()
                        .putString(TodayWidgetProvider.KEY, json)
                        .apply()
                    TodayWidgetProvider.refresh(this)
                    result.success(null)
                }
                "takeRoute" -> result.success(consumeRoute(intent))
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val route = consumeRoute(intent) ?: return
        channel?.invokeMethod("open", route)
    }

    private fun consumeRoute(source: Intent?): String? {
        val route = source?.getStringExtra(TodayWidgetProvider.EXTRA_ROUTE)
        if (route.isNullOrBlank()) return null
        source.removeExtra(TodayWidgetProvider.EXTRA_ROUTE)
        return route
    }
}
