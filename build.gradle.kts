// AGP 9 ships built-in Kotlin for the Android app module, so no separate
// `org.jetbrains.kotlin.android` plugin is applied there. The shared
// module is Kotlin Multiplatform (Android + iOS) with Compose Multiplatform.
plugins {
    id("com.android.application") version "9.0.1" apply false
    id("com.android.kotlin.multiplatform.library") version "9.0.1" apply false
    id("org.jetbrains.kotlin.multiplatform") version "2.3.20" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.3.20" apply false
    id("org.jetbrains.compose") version "1.11.1" apply false
}
