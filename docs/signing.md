# Android release signing

Android only installs an update when the new APK is signed with the **same key** as the installed app.
If the key changes, the system answers *"App not installed"* with no further explanation.

Release builds (`build.yml` and `fox.yml`) therefore **require** a keystore and fail without one -
they never fall back to the debug key (which is regenerated on every CI runner).

## One-time setup

1. Generate a keystore (keep it somewhere safe and **back it up** - if it is lost, existing users can never update again):

   ```powershell
   keytool -genkeypair -v -keystore oshi-release.jks -alias oshi -keyalg RSA -keysize 4096 -validity 10000
   ```

2. Base64 the file (PowerShell):

   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("oshi-release.jks")) | Set-Clipboard
   ```

3. Add these repository secrets (Settings -> Secrets and variables -> Actions):

   | Secret | Value |
   | --- | --- |
   | `KEYSTORE_FILE_BASE64` | the base64 text from step 2 |
   | `KEYSTORE_KEY_ALIAS` | `oshi` (the alias from step 1) |
   | `KEYSTORE_PASSWORD` | the store password |
   | `KEYSTORE_KEY_PASSWORD` | the key password |

4. Never commit the `.jks` file or `keystore.properties` (both are git-ignored).

## Migrating existing installs

Users who currently run a build signed with a different (debug) key must **uninstall once** and install a build
signed with the new key. After that, in-app updates work. The app now checks the downloaded APK
(package, version code, signature) before installing and explains the exact reason when it would be rejected.

## Version codes

CI sets the Android `versionCode` to the Unix time of the build, so it strictly increases for every build on every
channel (stable and FOX).

## FOX channel

`fox.yml` publishes builds of the `FOX` branch as GitHub **pre-releases** tagged `fox-<version>` (only the last 5 are kept).
`releases/latest` ignores pre-releases, so regular users are never prompted to update to them. A build produced by `fox.yml`
knows it belongs to the FOX channel (`Share.updateChannel == 'fox'`) and only follows the `fox-*` pre-releases.
To try FOX, install the `Oshi-FOX.apk` from such a pre-release over the existing app (same package and key).

