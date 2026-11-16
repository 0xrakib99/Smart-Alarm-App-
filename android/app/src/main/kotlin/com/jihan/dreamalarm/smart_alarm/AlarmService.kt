package com.jihan.dreamalarm.smart_alarm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class AlarmService : Service() {

    companion object {
        const val ACTION_START_ALARM = "com.jihan.smart_alarm.ACTION_START_ALARM"
        const val ACTION_STOP_ALARM = "com.jihan.smart_alarm.ACTION_STOP_ALARM"
        const val ACTION_PAUSE_AUDIO = "com.jihan.smart_alarm.ACTION_PAUSE_AUDIO"
        const val ACTION_RESUME_AUDIO = "com.jihan.smart_alarm.ACTION_RESUME_AUDIO"
        const val ACTION_SNOOZE_ALARM = "com.jihan.smart_alarm.ACTION_SNOOZE_ALARM"

        const val CHANNEL_ID = "smart_alarm_high_priority_channel"
        const val NOTIFICATION_ID = 40401

        var isRinging = false
            private set
        var currentAlarmId: String? = null
            private set
    }

    private var audioPlayer: AlarmAudioPlayer? = null
    private var vibrator: AlarmVibrator? = null
    private var currentVibrationEnabled: Boolean = true

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        audioPlayer = AlarmAudioPlayer(this)
        vibrator = AlarmVibrator(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: return START_NOT_STICKY

        when (action) {
            ACTION_START_ALARM -> handleStartAlarm(intent)
            ACTION_PAUSE_AUDIO -> handlePauseAudio()
            ACTION_RESUME_AUDIO -> handleResumeAudio()
            ACTION_STOP_ALARM -> handleStopAlarm()
            ACTION_SNOOZE_ALARM -> handleSnoozeAlarm(intent)
        }

        return START_NOT_STICKY
    }

    private fun handleStartAlarm(intent: Intent) {
        val id = intent.getStringExtra("id") ?: "unknown"
        val hour = intent.getIntExtra("hour", 7)
        val minute = intent.getIntExtra("minute", 0)
        val label = intent.getStringExtra("label") ?: "Alarm"
        val soundId = intent.getStringExtra("soundId") ?: "default"
        val vibrationEnabled = intent.getBooleanExtra("vibrationEnabled", true)
        val snoozeEnabled = intent.getBooleanExtra("snoozeEnabled", false)
        val snoozeMinutes = intent.getIntExtra("snoozeMinutes", 5)
        val volumePercent = intent.getIntExtra("volume", 80)
        val customSoundPath = intent.getStringExtra("customSoundPath")
        val customSoundName = intent.getStringExtra("customSoundName")

        isRinging = true
        currentAlarmId = id
        currentVibrationEnabled = vibrationEnabled

        val storedAlarm = AlarmStorage.getAlarmById(this, id)?.toMutableMap() ?: mutableMapOf()
        val effectiveCustomPath = customSoundPath ?: (storedAlarm["customSoundPath"] as? String)
        val effectiveCustomName = customSoundName ?: (storedAlarm["customSoundName"] as? String)

        val alarmData = storedAlarm.apply {
            put("id", id)
            put("hour", hour)
            put("minute", minute)
            put("label", label)
            put("soundId", soundId)
            put("vibrationEnabled", vibrationEnabled)
            put("snoozeEnabled", snoozeEnabled)
            put("snoozeMinutes", snoozeMinutes)
            put("volume", volumePercent)
            if (effectiveCustomPath != null) put("customSoundPath", effectiveCustomPath)
            if (effectiveCustomName != null) put("customSoundName", effectiveCustomName)
        }
        AlarmStorage.saveActiveAlarm(this, alarmData)

        // Start audio & vibration
        val audioStarted = audioPlayer?.play(volumePercent, soundId, effectiveCustomPath) ?: false
        if (vibrationEnabled) {
            vibrator?.start()
        }

        // Build notification with Full Screen Intent (Strict mode: NO Snooze action button)
        val notification = buildNotification(id, hour, minute, label, audioFailed = !audioStarted)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        if (!audioStarted) {
            MainActivity.notifyAlarmError("Alarm audio asset failed to load. Check bundled siren_sound.mp3.")
        }

        // Notify Flutter if active
        MainActivity.notifyAlarmTriggered(alarmData)
    }

    private fun handlePauseAudio() {
        // Pauses ringtone during active mission interaction while foreground service stays alive
        audioPlayer?.pause()
        vibrator?.stop()
    }

    private fun handleResumeAudio() {
        // Resumes ringtone playback on inactivity timeout or max duration
        audioPlayer?.resume()
        val shouldVibrate = AlarmStorage.getActiveAlarm(this)?.get("vibrationEnabled") as? Boolean
            ?: currentVibrationEnabled
        if (shouldVibrate) {
            vibrator?.start()
        }
    }

    private fun handleStopAlarm() {
        audioPlayer?.stop()
        vibrator?.stop()
        AlarmStorage.saveActiveAlarm(this, null)
        isRinging = false
        currentAlarmId = null

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    private fun handleSnoozeAlarm(intent: Intent) {
        val id = intent.getStringExtra("id") ?: currentAlarmId
        val snoozeMinutes = intent.getIntExtra("snoozeMinutes", 5)

        handleStopAlarm()

        if (id != null) {
            val alarm = AlarmStorage.getAlarmById(this, id)
            if (alarm != null) {
                val triggerTime = System.currentTimeMillis() + (snoozeMinutes * 60 * 1000L)
                val snoozedAlarm = alarm.toMutableMap().apply {
                    put("triggerTimeMillis", triggerTime)
                }
                AlarmManagerHelper.scheduleAlarm(this, snoozedAlarm)
            }
        }
    }

    private fun buildNotification(
        id: String,
        hour: Int,
        minute: Int,
        label: String,
        audioFailed: Boolean = false
    ): Notification {
        val timeString = String.format("%02d:%02d", hour, minute)
        val displayTitle = if (label.isNotBlank()) "$timeString — $label" else "$timeString — Alarm"
        val contentBody = if (audioFailed) {
            "Audio asset error: verify alarm sound. Tap to complete mission."
        } else {
            "Complete your mission and tap Dismiss to turn off alarm"
        }

        // Full Screen Intent to FullScreenAlarmActivity
        val fullScreenIntent = Intent(this, FullScreenAlarmActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("id", id)
            putExtra("hour", hour)
            putExtra("minute", minute)
            putExtra("label", label)
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            id.hashCode(),
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Tap content intent pointing directly to Flutter MainActivity
        val contentIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("alarm_id", id)
            putExtra("action", "ring")
        }
        val contentPendingIntent = PendingIntent.getActivity(
            this,
            id.hashCode() + 1,
            contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(displayTitle)
            .setContentText(contentBody)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setContentIntent(contentPendingIntent)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Smart Alarm Clock"
            val descriptionText = "High priority full-screen alarms"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                enableVibration(true)
                setSound(null, null) // Sound is handled directly by AlarmAudioPlayer
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        audioPlayer?.stop()
        vibrator?.stop()
        isRinging = false
        super.onDestroy()
    }
}
