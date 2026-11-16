package com.jihan.dreamalarm.smart_alarm

import android.content.Context
import android.content.res.AssetFileDescriptor
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import java.io.File

class AlarmAudioPlayer(private val context: Context) {

    companion object {
        private const val TAG = "AlarmAudioPlayer"
        private const val SIREN_ASSET_PATH = "flutter_assets/assets/siren_sound.mp3"
    }

    private var mediaPlayer: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private var originalAlarmVolume: Int? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var legacyFocusListener: AudioManager.OnAudioFocusChangeListener? = null
    private var isManuallyPaused: Boolean = false

    val isPlaying: Boolean
        get() = mediaPlayer?.isPlaying == true

    fun play(volumePercent: Int = 80, soundId: String? = null, customSoundPath: String? = null): Boolean {
        stop()
        isManuallyPaused = false

        audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
        setupVolumeProtection(volumePercent)
        requestAudioFocus()

        // 1. Attempt to play custom sound if provided
        if (!customSoundPath.isNullOrBlank()) {
            val customFile = File(customSoundPath)
            if (customFile.exists() && customFile.canRead()) {
                try {
                    mediaPlayer = MediaPlayer().apply {
                        setDataSource(customFile.absolutePath)
                        setAudioAttributes(
                            AudioAttributes.Builder()
                                .setUsage(AudioAttributes.USAGE_ALARM)
                                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                .build()
                        )
                        isLooping = true
                        prepare()
                        start()
                    }
                    Log.i(TAG, "Custom alarm audio started successfully from: $customSoundPath")
                    return true
                } catch (e: Exception) {
                    Log.w(TAG, "Failed to play custom sound '$customSoundPath', falling back to built-in sound", e)
                    mediaPlayer = null
                }
            } else {
                Log.w(TAG, "Custom sound file not found or unreadable at '$customSoundPath', falling back to built-in sound")
            }
        }

        // 2. Play built-in sound asset or system alarm ringtone
        return try {
            try {
                val afd: AssetFileDescriptor = context.assets.openFd(SIREN_ASSET_PATH)
                mediaPlayer = MediaPlayer().apply {
                    setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                    afd.close()
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    isLooping = true
                    prepare()
                    start()
                }
                Log.i(TAG, "Alarm built-in playback started successfully using $SIREN_ASSET_PATH")
                true
            } catch (assetEx: Exception) {
                val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                mediaPlayer = MediaPlayer().apply {
                    setDataSource(context, defaultUri)
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    isLooping = true
                    prepare()
                    start()
                }
                Log.i(TAG, "Alarm playback started using system default ringtone")
                true
            }
        } catch (e: Exception) {
            Log.e(TAG, "FATAL: Failed to play any alarm audio", e)
            mediaPlayer = null
            false
        }
    }

    fun pause() {
        isManuallyPaused = true
        try {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.pause()
                    Log.i(TAG, "Alarm siren audio paused for mission challenge")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error pausing alarm playback", e)
        }
    }

    fun resume() {
        isManuallyPaused = false
        try {
            mediaPlayer?.let {
                if (!it.isPlaying) {
                    it.start()
                    Log.i(TAG, "Alarm siren audio resumed")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error resuming alarm playback", e)
        }
    }

    private fun setupVolumeProtection(volumePercent: Int) {
        val am = audioManager ?: return
        try {
            if (originalAlarmVolume == null) {
                originalAlarmVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
            }
            val maxVol = am.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            val target = ((volumePercent.coerceIn(1, 100) / 100f) * maxVol).toInt().coerceIn(1, maxVol)
            am.setStreamVolume(AudioManager.STREAM_ALARM, target, 0)
            Log.i(TAG, "Applied alarm volume: $target / $maxVol (Original was: $originalAlarmVolume)")
        } catch (e: Exception) {
            Log.w(TAG, "Could not set alarm stream volume: ${e.message}")
        }
    }

    private fun requestAudioFocus() {
        val am = audioManager ?: return
        try {
            val focusListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
                if (focusChange == AudioManager.AUDIOFOCUS_GAIN && !isManuallyPaused) {
                    resume()
                }
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val attributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()

                audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
                    .setAudioAttributes(attributes)
                    .setOnAudioFocusChangeListener(focusListener)
                    .build()
                am.requestAudioFocus(audioFocusRequest!!)
            } else {
                legacyFocusListener = focusListener
                @Suppress("DEPRECATION")
                am.requestAudioFocus(
                    focusListener,
                    AudioManager.STREAM_ALARM,
                    AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE
                )
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to request audio focus: ${e.message}")
        }
    }

    fun stop() {
        isManuallyPaused = false
        try {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.reset()
                it.release()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing MediaPlayer", e)
        } finally {
            mediaPlayer = null
        }

        // Abandon audio focus
        try {
            val am = audioManager
            if (am != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    audioFocusRequest?.let { am.abandonAudioFocusRequest(it) }
                } else {
                    legacyFocusListener?.let {
                        @Suppress("DEPRECATION")
                        am.abandonAudioFocus(it)
                    }
                    legacyFocusListener = null
                }
            }
        } catch (_: Exception) {}

        // Restore original system volume only on complete stop/dismiss
        val orig = originalAlarmVolume
        if (orig != null && audioManager != null) {
            try {
                audioManager?.setStreamVolume(AudioManager.STREAM_ALARM, orig, 0)
                Log.i(TAG, "Restored original alarm volume: $orig")
            } catch (e: Exception) {
                Log.w(TAG, "Failed to restore original alarm volume: ${e.message}")
            } finally {
                originalAlarmVolume = null
            }
        }
    }
}
