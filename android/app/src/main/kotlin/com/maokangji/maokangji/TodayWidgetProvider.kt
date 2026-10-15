package com.maokangji.maokangji

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.widget.RemoteViews
import org.json.JSONObject

class TodayWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) {
            update(context, appWidgetManager, id)
        }
    }

    companion object {
        const val PREFS = "zhuaji_widget"
        const val KEY = "payload"
        const val EXTRA_ROUTE = "route"

        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, TodayWidgetProvider::class.java),
            )
            for (id in ids) update(context, manager, id)
        }

        fun update(context: Context, manager: AppWidgetManager, id: Int) {
            val raw = context
                .getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .getString(KEY, null)
            val payload = parse(raw)
            val views = RemoteViews(context.packageName, R.layout.widget_today)
            views.setTextViewText(R.id.widget_today, payload.today)
            views.setTextViewText(R.id.widget_next, payload.next)
            applyForcedColors(context, views, payload.appearance)
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra(EXTRA_ROUTE, payload.route)
            }
            val pending = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pending)
            manager.updateAppWidget(id, views)
        }

        private fun parse(raw: String?): Payload {
            if (raw.isNullOrBlank()) {
                return Payload("今天没什么要办", "下一个：还没有", "/calendar", "system")
            }
            return try {
                val json = JSONObject(raw)
                val lines = mutableListOf<String>()
                val today = json.optJSONArray("today")
                if (today != null) {
                    for (index in 0 until today.length()) {
                        val line = today.optString(index)
                        if (line.isNotBlank()) lines.add(line)
                    }
                }
                val body = if (lines.isEmpty()) "今天没什么要办" else lines.joinToString("\n")
                val next = json.optString("next").ifBlank { "还没有" }
                val route = json.optString("route").ifBlank { "/calendar" }
                val appearance = json.optString("appearance").ifBlank { "system" }
                Payload(body, "下一个：$next", route, appearance)
            } catch (_: Exception) {
                Payload("今天没什么要办", "下一个：还没有", "/calendar", "system")
            }
        }

        private fun applyForcedColors(context: Context, views: RemoteViews, appearance: String) {
            val forcedNight = when (appearance) {
                "dark" -> true
                "light" -> false
                else -> return
            }
            val systemNight = (context.resources.configuration.uiMode and
                Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
            if (forcedNight == systemNight) return
            val config = Configuration(context.resources.configuration)
            val night = if (forcedNight) {
                Configuration.UI_MODE_NIGHT_YES
            } else {
                Configuration.UI_MODE_NIGHT_NO
            }
            config.uiMode = (config.uiMode and Configuration.UI_MODE_NIGHT_MASK.inv()) or night
            val themed = context.createConfigurationContext(config)
            fun color(id: Int) = themed.getColor(id)
            views.setInt(R.id.widget_root, "setBackgroundColor", color(R.color.widget_paper))
            views.setTextColor(R.id.widget_brand, color(R.color.widget_muted))
            views.setTextColor(R.id.widget_today, color(R.color.widget_ink))
            views.setTextColor(R.id.widget_next, color(R.color.widget_muted))
        }
    }
}

private data class Payload(
    val today: String,
    val next: String,
    val route: String,
    val appearance: String,
)
