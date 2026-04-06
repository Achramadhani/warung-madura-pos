plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.toko_rajawali"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Perbaikan: Gunakan string "17" langsung untuk menghindari error deprecated
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.toko_rajawali"
        
        // Perbaikan: Pilih salah satu. 
        // Jika ingin mengikuti standar Flutter, gunakan: flutter.minSdkVersion
        // Jika ingin memaksa ke versi 21, gunakan: 21
        minSdk = flutter.minSdkVersion 
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
