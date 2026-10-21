# Flutter Proguard Rules

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Play Store Split / Deferred Components
-dontwarn com.google.android.play.core.**

# ML Kit Text Recognition (Missing optional language modules)
-dontwarn com.google.mlkit.vision.text.**

# Keep Drift/SQLite classes
-keep class net.sqlcipher.** { *; }
-keep class org.sqlite.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep In-App Purchase classes
-keep class com.android.billingclient.** { *; }

# Keep Kotlin coroutines & stdlib classes used by shared_preferences JNI/Pigeon interop
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }

