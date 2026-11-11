# Flutter App Installer

A Flutter plugin for installing app on Android.
The plugin supports both install with Android intent and silently install.

## Getting Started

Add this to your package's pubspec.yaml file:


```yaml
dependencies:
  flutter_app_installer: ^2.0.0
```

### Android

**Install with Android Intent**

You need to add the provider inside your `AndroidManifest.xml` application section.

```
<!-- Provider -->
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileProvider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

You need to create one `android/app/src/main/res/xml/file_paths.xml` with the following content.

Please replace the packageName with your app package's name.

```
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path path="Android/data/packageName/" name="files_root" />
    <external-path path="." name="external_storage_root" />
</paths>
```

If your application API level is above 25, please remember to add the permission in `AndroidManifest.xml` file.

```
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

**Install silently**

In order to install the APK silently, your app must be a system application or has root permission on your emulator.

You need to add permissions in `AndroidManifest.xml` file.

```
<!-- Install/delete permissions, only granted to system apps -->
<uses-permission android:name="android.permission.INSTALL_PACKAGES" />
<uses-permission android:name="android.permission.DELETE_PACKAGES" />
```

## Usage

Import the package with

```dart
import 'package:flutter_app_installer/flutter_app_installer.dart';
```

Install your apk with Android Intent.

```dart
final FlutterAppInstaller flutterAppInstaller = FlutterAppInstaller();
flutterAppInstaller.installApk(
  filePath: apk_file_full_path_here,
);
```

Install your apk silently.

```dart
final FlutterAppInstaller flutterAppInstaller = FlutterAppInstaller();
flutterAppInstaller.installApk(
  filePath: apk_file_full_path_here,
  silently: true,
);
```

## Upgrade from v0 to v1

The installApk function call is changed from static method to non-static method.

Please remember to change the installApk function call in your application.