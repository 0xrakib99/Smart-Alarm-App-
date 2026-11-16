package com.jihan.dreamalarm.smart_alarm

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast

class FullScreenAlarmActivity : Activity() {

    private var alarmId: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setupWindowFlags()

        alarmId = intent.getStringExtra("id")
        val hour = intent.getIntExtra("hour", 7)
        val minute = intent.getIntExtra("minute", 0)
        val label = intent.getStringExtra("label") ?: "Alarm"

        setContentView(buildContentView(hour, minute, label))
    }

    private fun setupWindowFlags() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
            keyguardManager?.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }
    }

    private fun buildContentView(
        hour: Int,
        minute: Int,
        label: String
    ): View {
        val rootLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            fitsSystemWindows = true
            setBackgroundColor(Color.WHITE)
            setPadding(56, 80, 56, 80)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )
        }

        val timeString = String.format("%02d:%02d", hour, minute)
        val timeView = TextView(this).apply {
            text = timeString
            textSize = 64f
            setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD))
            setTextColor(Color.parseColor("#19141F"))
            gravity = Gravity.CENTER
        }
        rootLayout.addView(timeView)

        if (label.isNotBlank()) {
            val labelView = TextView(this).apply {
                text = label
                textSize = 20f
                setTextColor(Color.parseColor("#6C6477"))
                gravity = Gravity.CENTER
                setPadding(0, 16, 0, 0)
            }
            rootLayout.addView(labelView)
        }

        val missionBadge = TextView(this).apply {
            text = "MISSION REQUIRED TO DISMISS"
            textSize = 12f
            setTypeface(Typeface.DEFAULT_BOLD)
            setTextColor(Color.parseColor("#582493"))
            gravity = Gravity.CENTER
            setPadding(0, 24, 0, 48)
        }
        rootLayout.addView(missionBadge)

        // Start Mission Button (Strict Alarm Mode: No Snooze)
        val buttonBg = GradientDrawable().apply {
            setColor(Color.parseColor("#582493"))
            cornerRadius = 28f
        }
        val startMissionButton = Button(this).apply {
            text = "Start Mission"
            textSize = 17f
            isAllCaps = false
            setTextColor(Color.WHITE)
            background = buttonBg
            setPadding(0, 28, 0, 28)
            setOnClickListener {
                startMission()
            }
        }
        val buttonParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            bottomMargin = 24
        }
        rootLayout.addView(startMissionButton, buttonParams)

        return rootLayout
    }

    private fun startMission() {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("alarm_id", alarmId)
            putExtra("action", "start_mission")
        }
        startActivity(launchIntent)
        finish()
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
                    return true // Consume hardware key event
                }
            }
        }
        return super.dispatchKeyEvent(event)
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Prevent dismissal by back button without mission completion
    }
}
