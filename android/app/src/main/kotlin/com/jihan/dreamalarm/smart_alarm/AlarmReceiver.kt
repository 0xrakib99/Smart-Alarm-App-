package com.jihan.dreamalarm.smart_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import androidx.core.content.ContextCompat

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
        val wakeLock = powerManager?.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
            "SmartAlarm:AlarmReceiverWakeLock"
        )
        wakeLock?.acquire(15000L) // hold up to 15s

        try {
            val serviceIntent = Intent(context, AlarmService::class.java).apply {
                action = AlarmService.ACTION_START_ALARM
                putExtras(intent)
            }
            ContextCompat.startForegroundService(context, serviceIntent)
        } finally {
            if (wakeLock != null && wakeLock.isHeld) {
                wakeLock.release()
            }
        }
    }
}
