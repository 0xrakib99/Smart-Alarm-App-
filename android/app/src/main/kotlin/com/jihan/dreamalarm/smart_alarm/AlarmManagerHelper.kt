package com.jihan.dreamalarm.smart_alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.Calendar

object AlarmManagerHelper {

    fun canScheduleExactAlarms(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            return alarmManager?.canScheduleExactAlarms() ?: false
        }
        return true
    }

    fun scheduleAlarm(context: Context, alarm: Map<String, Any?>): Boolean {
        val id = alarm["id"] as? String ?: return false
        val enabled = alarm["enabled"] as? Boolean ?: true
        if (!enabled) {
            cancelAlarm(context, id)
            return true
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return false

        // Determine trigger time
        val triggerTimeMillis = (alarm["triggerTimeMillis"] as? Number)?.toLong()
            ?: computeNextTriggerTime(alarm)

        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = "com.jihan.smart_alarm.ACTION_ALARM_TRIGGER"
            putExtra("id", id)
            putExtra("hour", (alarm["hour"] as? Number)?.toInt() ?: 7)
            putExtra("minute", (alarm["minute"] as? Number)?.toInt() ?: 0)
            putExtra("label", alarm["label"] as? String ?: "")
            putExtra("soundId", alarm["soundId"] as? String ?: "default")
            putExtra("customSoundPath", alarm["customSoundPath"] as? String)
            putExtra("customSoundName", alarm["customSoundName"] as? String)
            putExtra("vibrationEnabled", alarm["vibrationEnabled"] as? Boolean ?: true)
            putExtra("volume", (alarm["volume"] as? Number)?.toInt() ?: 80)
            putExtra("snoozeEnabled", alarm["snoozeEnabled"] as? Boolean ?: true)
            putExtra("snoozeMinutes", (alarm["snoozeMinutes"] as? Number)?.toInt() ?: 5)
        }

        val requestCode = id.hashCode()
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            flags
        )

        // Show intent for lock-screen alarm clock indicator
        val showIntent = Intent(context, MainActivity::class.java).apply {
            setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("alarm_id", id)
        }
        val showPendingIntent = PendingIntent.getActivity(
            context,
            requestCode,
            showIntent,
            flags
        )

        try {
            val clockInfo = AlarmManager.AlarmClockInfo(triggerTimeMillis, showPendingIntent)
            alarmManager.setAlarmClock(clockInfo, pendingIntent)
            AlarmStorage.saveAlarm(context, alarm)
            return true
        } catch (e: SecurityException) {
            // Can happen if SCHEDULE_EXACT_ALARM permission is revoked
            return false
        } catch (_: Exception) {
            return false
        }
    }

    fun cancelAlarm(context: Context, id: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = "com.jihan.smart_alarm.ACTION_ALARM_TRIGGER"
        }
        val requestCode = id.hashCode()
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        val pendingIntent = PendingIntent.getBroadcast(context, requestCode, intent, flags)

        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
        AlarmStorage.removeAlarm(context, id)
    }

    fun computeNextTriggerTime(alarm: Map<String, Any?>): Long {
        val hour = (alarm["hour"] as? Number)?.toInt() ?: 7
        val minute = (alarm["minute"] as? Number)?.toInt() ?: 0
        val repeatDays = ((alarm["repeatDays"] as? List<*>) ?: emptyList<Any>()).mapNotNull { (it as? Number)?.toInt() }.toSet()

        val now = Calendar.getInstance()
        val target = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        if (repeatDays.isEmpty()) {
            // One-time alarm
            if (!target.after(now)) {
                target.add(Calendar.DAY_OF_YEAR, 1)
            }
            return target.timeInMillis
        }

        // Repeating alarm: check up to 7 days ahead
        for (i in 0..7) {
            val candidate = (target.clone() as Calendar).apply {
                add(Calendar.DAY_OF_YEAR, i)
            }
            // Calendar.DAY_OF_WEEK: Sunday=1, Monday=2, ..., Saturday=7
            val weekday = when (candidate.get(Calendar.DAY_OF_WEEK)) {
                Calendar.MONDAY -> 1
                Calendar.TUESDAY -> 2
                Calendar.WEDNESDAY -> 3
                Calendar.THURSDAY -> 4
                Calendar.FRIDAY -> 5
                Calendar.SATURDAY -> 6
                Calendar.SUNDAY -> 7
                else -> 1
            }
            if (repeatDays.contains(weekday) && candidate.after(now)) {
                return candidate.timeInMillis
            }
        }

        target.add(Calendar.DAY_OF_YEAR, 1)
        return target.timeInMillis
    }
}
