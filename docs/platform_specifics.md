# Platform Support & Configuration

vPay is developed using Flutter, enabling cross-platform builds from a single codebase. This document details platform-specific configurations, plugin registrations, and support notes for the various operating systems targeted by the application.

## General

* **Cross-Platform Build:** Flutter facilitates building for Android, iOS, Web, Windows, macOS, and Linux. Dedicated setup files and configurations are present in the project for each of these platforms.

## Android

* **Configuration:**
  * Minimum SDK, Target SDK, Version Code, and Version Name are configured in `android/app/build.gradle.kts`.
  * Application ID: `dev.vpay.vpay_flutter`.
* **Permissions:**
  * Standard `INTERNET` permission is included.
  * `PROCESS_TEXT` query has been added (likely for specific text processing features or plugins).
* **Plugins Registered (Illustrative List - may vary with updates):**
  * `app_links`
  * `firebase_core`, `firebase_messaging`
  * `flutter_local_notifications`
  * `flutter_secure_storage`
  * `google_maps_flutter_android`
  * `image_picker_android`
  * `local_auth_android`
  * `path_provider_android`
  * `pay_android` (likely for Google Pay or similar)
  * `qr_code_scanner`
  * `shared_preferences_android`
  * `sqflite_android`
  * `upi_india`
  * `url_launcher_android`
* **Gradle Version:** 8.10.2 (as per original documentation).

## iOS

* **Configuration:**
  * Build settings are configured via Xcode project files (`ios/Runner.xcworkspace`) and potentially `flutter_export_environment.sh`.
* **Plugins Registered (Illustrative List - may vary with updates):**
  * `app_links`
  * `firebase_core`, `firebase_messaging`
  * `flutter_local_notifications`
  * `flutter_secure_storage`
  * `maps_flutter_ios`
  * `image_picker_ios`
  * `local_auth_darwin` (for Touch ID, Face ID)
  * `path_provider_foundation`
  * `pay_ios` (likely for Apple Pay)
  * `qr_code_scanner`
  * `shared_preferences_foundation`
  * `sqflite_darwin`
  * `url_launcher_ios`

## Web

* **Configuration:**
  * Basic setup with `web/index.html` and `web/manifest.json`.
  * Flutter web support enables running the application in modern web browsers.

## Windows

* **Build System:** Uses CMake.
* **Runner:** Implements `Win32Window` for hosting the Flutter view.
* **Plugins Registered (Illustrative List - may vary with updates):**
  * `app_links`
  * `file_selector_windows`
  * `firebase_core` (limited functionality on desktop)
  * `flutter_secure_storage_windows`
  * `local_auth_windows`
  * `url_launcher_windows`

## macOS

* **Build System:** Uses CMake and Swift for the runner application.
* **Plugins Registered (Illustrative List - may vary with updates):**
  * `app_links`
  * `file_selector_macos`
  * `firebase_core`, `firebase_messaging` (macOS support for some Firebase services)
  * `flutter_local_notifications`
  * `flutter_secure_storage_macos`
  * `local_auth_darwin`
  * `path_provider_foundation`
  * `shared_preferences_foundation`
  * `sqflite_darwin`
  * `url_launcher_macos`

## Linux

* **Build System:** Uses CMake and C++ for the runner application.
* **Application ID:** `dev.vpay.vpay_flutter` (same as Android, consistency for some services).
* **Plugins Registered (Illustrative List - may vary with updates):**
  * `file_selector_linux`
  * `flutter_secure_storage_linux`
  * `gtk` (for GTK+ specific integrations if any)
  * `url_launcher_linux`

**Note:** The lists of registered plugins are based on the information available in the original project documentation (`docs/project_details.md`, Section 4) and may have evolved. For the most current list, always refer to the `pubspec.yaml` file and platform-specific configuration files (e.g., `MainActivity.kt`/`AppDelegate.swift`). The actual capabilities of plugins on desktop platforms (Windows, macOS, Linux) can sometimes be more limited than on mobile.
