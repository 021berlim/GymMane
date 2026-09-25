// Fix AGP conflicting environment variables (ANDROID_PREFS_ROOT vs ANDROID_USER_HOME)
@Suppress("UNCHECKED_CAST")
try {
    val processEnvironment = Class.forName("java.lang.ProcessEnvironment")
    val envField = processEnvironment.getDeclaredField("theEnvironment").apply { isAccessible = true }
    (envField.get(null) as? MutableMap<String, String>)?.remove("ANDROID_PREFS_ROOT")

    val ciEnvField = processEnvironment.getDeclaredField("theCaseInsensitiveEnvironment").apply { isAccessible = true }
    (ciEnvField.get(null) as? MutableMap<String, String>)?.remove("ANDROID_PREFS_ROOT")
} catch (_: Throwable) {
}

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            val localPropertiesFile = file("local.properties")
            if (localPropertiesFile.exists()) {
                localPropertiesFile.inputStream().use { properties.load(it) }
            }
            properties.getProperty("flutter.sdk")
                ?: System.getenv("FLUTTER_ROOT")
                ?: "C:/flutter"
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
