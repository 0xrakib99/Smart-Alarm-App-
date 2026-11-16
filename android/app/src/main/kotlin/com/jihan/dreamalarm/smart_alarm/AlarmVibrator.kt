package com.jihan.dreamalarm.smart_alarm

import android.content.Context
import android.os.Build
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

class AlarmVibrator(private val context: Context) {
    private var vibrator: Vibrator? = null

    init {
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
            vibratorManager?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
    }

    fun start() {
        val v = vibrator ?: return
        if (!v.hasVibrator()) return
        stop()

        val pattern = longArrayOf(0, 500, 400, 500, 400)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val effect = VibrationEffect.createWaveform(pattern, 1)
            val attrs = VibrationAttributes.Builder()
                .setUsage(VibrationAttributes.USAGE_ALARM)
                .build()
            v.vibrate(effect, attrs)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val effect = VibrationEffect.createWaveform(pattern, 1)
            v.vibrate(effect)
        } else {
            @Suppress("DEPRECATION")
            v.vibrate(pattern, 1)
        }
    }

    fun stop() {
        vibrator?.cancel()
    }
}
