package com.jihan.dreamalarm.smart_alarm

import android.app.Activity
import android.app.AlarmManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.res.AssetFileDescriptor
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.OpenableColumns
import android.provider.Settings
import android.util.Log
import android.view.KeyEvent
import android.widget.Toast
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL_NAME = "com.jihan.dreamalarm.smart_alarm/alarm"
        private const val REQUEST_CODE_PICK_AUDIO = 202
        private const val SIREN_ASSET_PATH = "flutter_assets/assets/siren_sound.mp3"

        private var methodChannel: MethodChannel? = null
        private var pendingAlarmData: Map<String, Any?>? = null
        private var pendingAlarmError: String? = null

        fun notifyAlarmTriggered(alarmData: Map<String, Any?>) {
            val channel = methodChannel
            if (channel != null) {
                channel.invokeMethod("onAlarmTriggered", alarmData)
            } else {
                pendingAlarmData = alarmData
            }
        }

        fun notifyAlarmError(message: String) {
            val channel = methodChannel
            if (channel != null) {
                channel.invokeMethod("onAlarmError", message)
            } else {
                pendingAlarmError = message
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setupLockScreenFlags()
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun setupLockScreenFlags() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                android.view.WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                android.view.WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                android.view.WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }
    }

    private fun handleIntent(intent: Intent?) {
        val alarmId = intent?.getStringExtra("alarm_id") ?: return
        val action = intent.getStringExtra("action") ?: "ring"

        val alarmData = AlarmStorage.getAlarmById(this, alarmId) ?: mapOf(
            "id" to alarmId,
            "action" to action
        )
        val payload = alarmData.toMutableMap().apply {
            put("action", action)
        }
        notifyAlarmTriggered(payload)
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (AlarmService.isRinging) {
            when (event.keyCode) {
                KeyEvent.KEYCODE_VOLUME_DOWN,
                KeyEvent.KEYCODE_VOLUME_UP,
                KeyEvent.KEYCODE_VOLUME_MUTE -> {
                    if (event.action == KeyEvent.ACTION_DOWN) {
                        Toast.makeText(this, "Alarm volume is protected during active alarm", Toast.LENGTH_SHORT).show()
                    }
                    return true // Consume hardware key event during active alarm
                }
            }
        }
        return super.dispatchKeyEvent(event)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermissions" -> {
                    val exactAlarmAllowed = AlarmManagerHelper.canScheduleExactAlarms(this)
                    val notificationsAllowed = NotificationManagerCompat.from(this).areNotificationsEnabled()
                    val fullScreenAllowed = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                        nm?.canUseFullScreenIntent() ?: true
                    } else {
                        true
                    }
                    result.success(
                        mapOf(
                            "exactAlarm" to exactAlarmAllowed,
                            "notification" to notificationsAllowed,
                            "fullScreenIntent" to fullScreenAllowed
                        )
                    )
                }

                "canScheduleExactAlarms" -> {
                    result.success(AlarmManagerHelper.canScheduleExactAlarms(this))
                }

                "requestExactAlarmPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                data = Uri.parse("package:$packageName")
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    } else {
                        result.success(true)
                    }
                }

                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 101)
                        result.success(true)
                    } else {
                        result.success(true)
                    }
                }

                "requestFullScreenIntentPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                        try {
                            val intent = Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT).apply {
                                data = Uri.parse("package:$packageName")
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (_: Exception) {
                            openAppDetailsSettings()
                            result.success(false)
                        }
                    } else {
                        result.success(true)
                    }
                }

                "openAppSettings" -> {
                    openAppDetailsSettings()
                    result.success(true)
                }

                "scheduleAlarm" -> {
                    val alarmMap = call.argument<Map<String, Any?>>("alarm")
                    if (alarmMap != null) {
                        val success = AlarmManagerHelper.scheduleAlarm(this, alarmMap)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGS", "Alarm map cannot be null", null)
                    }
                }

                "cancelAlarm" -> {
                    val id = call.argument<String>("id")
                    if (id != null) {
                        AlarmManagerHelper.cancelAlarm(this, id)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "Alarm id cannot be null", null)
                    }
                }

                "syncAlarms" -> {
                    val alarmsList = call.argument<List<Map<String, Any?>>>("alarms")
                    if (alarmsList != null) {
                        AlarmStorage.saveAlarms(this, alarmsList)
                        for (alarm in alarmsList) {
                            val enabled = alarm["enabled"] as? Boolean ?: true
                            if (enabled) {
                                AlarmManagerHelper.scheduleAlarm(this, alarm)
                            } else {
                                val id = alarm["id"] as? String
                                if (id != null) {
                                    AlarmManagerHelper.cancelAlarm(this, id)
                                }
                            }
                        }
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "Alarms list cannot be null", null)
                    }
                }

                "pauseAlarmAudio" -> {
                    try {
                        val pauseIntent = Intent(this, AlarmService::class.java).apply {
                            action = AlarmService.ACTION_PAUSE_AUDIO
                        }
                        startService(pauseIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_ERROR", e.message, null)
                    }
                }

                "resumeAlarmAudio" -> {
                    try {
                        val resumeIntent = Intent(this, AlarmService::class.java).apply {
                            action = AlarmService.ACTION_RESUME_AUDIO
                        }
                        startService(resumeIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_ERROR", e.message, null)
                    }
                }

                "stopAlarm" -> {
                    try {
                        val stopIntent = Intent(this, AlarmService::class.java).apply {
                            action = AlarmService.ACTION_STOP_ALARM
                        }
                        startService(stopIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_ERROR", e.message, null)
                    }
                }

                "snoozeAlarm" -> {
                    try {
                        val id = call.argument<String>("id")
                        val snoozeMinutes = call.argument<Int>("snoozeMinutes") ?: 5
                        val snoozeIntent = Intent(this, AlarmService::class.java).apply {
                            action = AlarmService.ACTION_SNOOZE_ALARM
                            putExtra("id", id)
                            putExtra("snoozeMinutes", snoozeMinutes)
                        }
                        startService(snoozeIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_ERROR", e.message, null)
                    }
                }

                "getActiveAlarm" -> {
                    val active = AlarmStorage.getActiveAlarm(this)
                    result.success(active)
                }

                "pickCustomSound" -> {
                    pickCustomAudioFile(result)
                }

                "playAudioPreview" -> {
                    val path = call.argument<String>("path")
                    val soundId = call.argument<String>("soundId")
                    val volume = call.argument<Int>("volume")
                    playAudioPreview(path, soundId, volume, result)
                }

                "pauseAudioPreview" -> {
                    pauseAudioPreview(result)
                }

                "resumeAudioPreview" -> {
                    resumeAudioPreview(result)
                }

                "stopAudioPreview" -> {
                    stopAudioPreview(result)
                }

                else -> result.notImplemented()
            }
        }

        // Deliver pending alarm data or error if triggered before engine was initialized
        pendingAlarmData?.let {
            methodChannel?.invokeMethod("onAlarmTriggered", it)
            pendingAlarmData = null
        }
        pendingAlarmError?.let {
            methodChannel?.invokeMethod("onAlarmError", it)
            pendingAlarmError = null
        }
    }

    private var pendingPickerResult: MethodChannel.Result? = null
    private var previewPlayer: MediaPlayer? = null

    private fun pickCustomAudioFile(result: MethodChannel.Result) {
        if (pendingPickerResult != null) {
            result.error("BUSY", "Another file picker request is already in progress", null)
            return
        }
        pendingPickerResult = result

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "audio/*"
            val mimeTypes = arrayOf(
                "audio/mpeg",
                "audio/mp3",
                "audio/wav",
                "audio/x-wav",
                "audio/m4a",
                "audio/x-m4a",
                "audio/aac",
                "audio/ogg",
                "audio/flac",
                "audio/mid",
                "audio/x-matroska"
            )
            putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes)
        }

        try {
            startActivityForResult(intent, REQUEST_CODE_PICK_AUDIO)
        } catch (e: Exception) {
            try {
                val fallbackIntent = Intent(Intent.ACTION_GET_CONTENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "audio/*"
                }
                startActivityForResult(fallbackIntent, REQUEST_CODE_PICK_AUDIO)
            } catch (e2: Exception) {
                pendingPickerResult = null
                result.error("PICKER_ERROR", "Cannot open device audio picker: ${e2.message}", null)
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_PICK_AUDIO) {
            val channelResult = pendingPickerResult
            pendingPickerResult = null

            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val uri = data.data!!
                try {
                    var displayName = "custom_sound.mp3"
                    contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                        val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                        if (nameIndex != -1 && cursor.moveToFirst()) {
                            val name = cursor.getString(nameIndex)
                            if (!name.isNullOrBlank()) {
                                displayName = name
                            }
                        }
                    }

                    val soundsDir = File(filesDir, "custom_sounds").apply { mkdirs() }
                    val cleanName = displayName.replace("[^a-zA-Z0-9._-]".toRegex(), "_")
                    val destFile = File(soundsDir, "sound_${System.currentTimeMillis()}_$cleanName")

                    contentResolver.openInputStream(uri)?.use { input ->
                        destFile.outputStream().use { output ->
                            input.copyTo(output)
                        }
                    } ?: throw IOException("Could not open input stream from uri: $uri")

                    // Validate audio file with MediaPlayer
                    val testPlayer = MediaPlayer()
                    testPlayer.setDataSource(destFile.absolutePath)
                    testPlayer.prepare()
                    val durationMs = testPlayer.duration
                    testPlayer.release()

                    channelResult?.success(mapOf(
                        "path" to destFile.absolutePath,
                        "name" to displayName,
                        "size" to destFile.length(),
                        "duration" to durationMs
                    ))
                } catch (e: Exception) {
                    Log.e("MainActivity", "Failed to load selected audio file", e)
                    channelResult?.error("INVALID_AUDIO", "Failed to load audio file: ${e.message}", null)
                }
            } else {
                channelResult?.success(null)
            }
        }
    }

    private fun playAudioPreview(path: String?, soundId: String?, volumePercent: Int?, result: MethodChannel.Result) {
        stopAudioPreview()

        try {
            val player = MediaPlayer()
            val volume = volumePercent ?: 80

            if (!path.isNullOrBlank()) {
                val file = File(path)
                if (!file.exists() || !file.canRead()) {
                    result.error("FILE_NOT_FOUND", "Audio file not found at path: $path", null)
                    return
                }
                player.setDataSource(file.absolutePath)
            } else {
                try {
                    val afd: AssetFileDescriptor = assets.openFd(SIREN_ASSET_PATH)
                    player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                    afd.close()
                } catch (_: Exception) {
                    val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                        ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                    player.setDataSource(this, defaultUri)
                }
            }

            player.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            val floatVol = (volume.coerceIn(1, 100) / 100f)
            player.setVolume(floatVol, floatVol)
            player.isLooping = false
            player.setOnCompletionListener {
                stopAudioPreview()
                methodChannel?.invokeMethod("onAudioPreviewStopped", null)
            }
            player.setOnErrorListener { _, _, _ ->
                stopAudioPreview()
                methodChannel?.invokeMethod("onAudioPreviewStopped", null)
                true
            }
            player.prepare()
            player.start()
            previewPlayer = player
            result.success(true)
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to play audio preview", e)
            stopAudioPreview()
            result.error("PLAYBACK_ERROR", "Could not play audio preview: ${e.message}", null)
        }
    }

    private fun pauseAudioPreview(result: MethodChannel.Result) {
        try {
            previewPlayer?.let {
                if (it.isPlaying) {
                    it.pause()
                }
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("PAUSE_ERROR", e.message, null)
        }
    }

    private fun resumeAudioPreview(result: MethodChannel.Result) {
        try {
            previewPlayer?.let {
                if (!it.isPlaying) {
                    it.start()
                }
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("RESUME_ERROR", e.message, null)
        }
    }

    private fun stopAudioPreview(result: MethodChannel.Result? = null) {
        try {
            previewPlayer?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.reset()
                it.release()
            }
        } catch (_: Exception) {}
        previewPlayer = null
        result?.success(true)
    }

    private fun openAppDetailsSettings() {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
        } catch (_: Exception) {
        }
    }

    override fun onStop() {
        super.onStop()
        stopAudioPreview()
    }

    override fun onDestroy() {
        stopAudioPreview()
        methodChannel = null
        super.onDestroy()
    }
}
