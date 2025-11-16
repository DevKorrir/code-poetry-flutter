plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Read Firebase project ID from google-services.json
// This function extracts the project_id from the google-services.json file
fun getFirebaseProjectId(): String {
    val googleServicesFile = file("${projectDir}/google-services.json")
    return try {
        if (googleServicesFile.exists()) {
            val content = googleServicesFile.readText()
            val projectIdMatch = Regex("\"project_id\"\\s*:\\s*\"([^\"]+)\"").find(content)
            projectIdMatch?.groupValues?.get(1) ?: "codepoetry-80a07"
        } else {
            // Fallback if google-services.json doesn't exist
            "codepoetry-80a07"
        }
    } catch (e: Exception) {
        // Fallback on any error
        "codepoetry-80a07"
    }
}

android {
    namespace = "com.example.codepoetry"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID - define once and reuse
        val appId = "com.example.codepoetry"
        
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = appId
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Get Firebase project ID from google-services.json
        val firebaseProjectId = getFirebaseProjectId()
        
        // Configure manifest placeholders for OAuth deep links
        // These values are injected into AndroidManifest.xml at build time
        // This eliminates hardcoded values and makes the configuration portable
        manifestPlaceholders["firebaseAuthHost"] = "${firebaseProjectId}.firebaseapp.com"
        manifestPlaceholders["firebaseDynamicLinkHost"] = "${firebaseProjectId}.page.link"
        manifestPlaceholders["appAuthScheme"] = appId
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
