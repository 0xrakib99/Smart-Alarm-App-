package com.jihan.dreamalarm.smart_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return

        when (action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            "android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED" -> {
                rescheduleAllAlarms(context)
            }
        }
    }

    private fun rescheduleAllAlarms(context: Context) {
        val alarms = AlarmStorage.getAlarms(context)
        for (alarm in alarms) {
            try {
                val enabled = alarm["enabled"] as? Boolean ?: true
                if (enabled) {
                    // Recompute next occurrence and setAlarmClock
                    val recomputedTriggerTime = AlarmManagerHelper.computeNextTriggerTime(alarm)
                    val updatedAlarm = alarm.toMutableMap().apply {
                        put("triggerTimeMillis", recomputedTriggerTime)
                    }
                    AlarmManagerHelper.scheduleAlarm(context, updatedAlarm)
                }
            } catch (_: Exception) {
                // Skip malformed entry while keeping remaining alarms scheduled
            }
        }
    }
}
