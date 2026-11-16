package com.jihan.dreamalarm.smart_alarm

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

object  AlarmStorage {
    private const val PREFS_NAME = "smart_alarm_native_store"
    private const val KEY_ALARMS = "saved_alarms_json"
    private const val KEY_ACTIVE_ALARM = "active_alarm_json"
    private val gson = Gson()

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    fun saveAlarms(context: Context, alarmsList: List<Map<String, Any?>>) {
        val json = gson.toJson(alarmsList)
        getPrefs(context).edit().putString(KEY_ALARMS, json).apply()
    }

    fun getAlarms(context: Context): List<Map<String, Any?>> {
        val json = getPrefs(context).getString(KEY_ALARMS, null) ?: return emptyList()
        return try {
            val type = object : TypeToken<List<Map<String, Any?>>>() {}.type
            gson.fromJson(json, type) ?: emptyList()
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun getAlarmById(context: Context, id: String): Map<String, Any?>? {
        return getAlarms(context).firstOrNull { it["id"] == id }
    }

    fun saveAlarm(context: Context, alarm: Map<String, Any?>) {
        val id = alarm["id"] as? String ?: return
        val current = getAlarms(context).toMutableList()
        val index = current.indexOfFirst { it["id"] == id }
        if (index >= 0) {
            current[index] = alarm
        } else {
            current.add(alarm)
        }
        saveAlarms(context, current)
    }

    fun removeAlarm(context: Context, id: String) {
        val current = getAlarms(context).toMutableList()
        val removed = current.removeAll { it["id"] == id }
        if (removed) {
            saveAlarms(context, current)
        }
    }

    fun saveActiveAlarm(context: Context, alarm: Map<String, Any?>?) {
        if (alarm == null) {
            getPrefs(context).edit().remove(KEY_ACTIVE_ALARM).apply()
        } else {
            val json = gson.toJson(alarm)
            getPrefs(context).edit().putString(KEY_ACTIVE_ALARM, json).apply()
        }
    }

    fun getActiveAlarm(context: Context): Map<String, Any?>? {
        val json = getPrefs(context).getString(KEY_ACTIVE_ALARM, null) ?: return null
        return try {
            val type = object : TypeToken<Map<String, Any?>>() {}.type
            gson.fromJson(json, type)
        } catch (_: Exception) {
            null
        }
    }
}
