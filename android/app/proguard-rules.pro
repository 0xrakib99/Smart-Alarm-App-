# Flutter wrapper & embedding rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Suppress Play Core deferred component warnings when dynamic features are unused
-dontwarn com.google.android.play.core.**

# Keep Smart Alarm Kotlin entrypoints, MethodChannel classes, and receivers
-keep class com.jihan.dreamalarm.smart_alarm.** { *; }

# Gson generic TypeToken and Map deserialization used by AlarmStorage
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
