<div align="center">

<img src="assets/resources/images/logo_fit.png" alt="Oshi Logo" width="120" />

# Oshi

**A modern, cross-platform client for school e-registers.**  
Built with Flutter, Material 3 & Cupertino, and an extensible Dart runtime.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Android Release](https://img.shields.io/badge/Android-APK_Download-3DDC84?logo=android&logoColor=white)](https://github.com/Ogaku/Oshi/releases/latest/download/Oshi.apk)
[![iOS Release](https://img.shields.io/badge/iOS-IPA_Download-000000?logo=apple&logoColor=white)](https://github.com/Ogaku/Oshi/releases/latest/download/Oshi.ipa)
[![Web App](https://img.shields.io/badge/Web_App-PWA-F7DF1E?logo=pwa&logoColor=black)](https://github.com/Ogaku/Oshi/wiki/Web-app)
[![Support us!](https://img.shields.io/badge/Support_us!-Ko--fi-FF5E5B?logo=kofi&logoColor=white)](https://ko-fi.com/ogaku_oshi)

</div>

---

## ✨ Features

- 🎨 **Adaptive Design**: Native-feeling Material 3 design on Android and Cupertino on iOS, complete with dynamic accent colors and dark theme support.
- 🧩 **Modular Extensions**: Register providers (Librus Synergia, eduVULCAN / UONET+, and community additions) run in a sandboxed Dart runtime powered by [`d4rt`](https://pub.dev/packages/d4rt). Install or update providers in-app without waiting for full app updates.
- 📬 **Full Messaging Support**: Compose, reply, forward, and manage attachments with dedicated composers for both Material and Cupertino.
- 📅 **Interactive Timetable & Calendar**: Track lessons, substitutions, homework, bell countdowns, and upcoming tests.
- 📊 **Grades & Averages**: Weighted and term average calculations, grade history, and detailed breakdowns per subject.
- 🔔 **Background Notifications**: Stay updated on new grades, timetable changes, messages, and announcements.
- ⚡ **Multi-Session Support**: Seamlessly switch between multiple accounts and students.

---

## 📱 Screenshots

<div align="center">
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/f2864546-db1c-49f5-9426-2287adec8324" width="15%" />
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/580be1d8-1ff6-4757-88fb-03deb051ffd2" width="15%" />
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/183fb108-8571-4049-87c4-e73d45b8d9d1" width="15%" />
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/f1415647-8764-40a9-9e18-88fdd54b57d0" width="15%" />
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/88c9999b-49de-4bad-b937-dd3ba537e41e" width="15%" />
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/64bcdecc-25a3-40af-8752-20ccd4f685ba" width="15%" />
</div>

<div align="center">
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/5962dbc5-afdb-484f-83a4-ca488cfcc8c3" width="15%" />
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/ba6f63a2-068c-4814-a42f-9fab9531a873" width="15%" />
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/ffdacb23-c7ea-48c9-9c53-ccbf147d9a53" width="15%" />
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/bf81833e-f66e-4404-8195-800cb30116f1" width="15%" />
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/0ecee0dc-dd8f-4421-8148-f5b5efda24ba" width="15%" />
  <img src="https://github.com/Ogaku/Oshi/assets/50022719/01e5cdc3-b0f8-4b84-9dc9-2b8f7d15964f" width="15%" />
</div>

---

## 📥 Downloads & Installation

### Android
Download the latest APK directly from the [Releases](https://github.com/Ogaku/Oshi/releases/latest) page:
- **[Oshi.apk (Direct Download)](https://github.com/Ogaku/Oshi/releases/latest/download/Oshi.apk)**

> [!NOTE]
> The app includes an in-app updater that checks for official releases and verifies the APK signature and version code before installing.

### iOS
Download the decrypted IPA or add our community sources:
- **[Oshi.ipa (Direct Download)](https://github.com/Ogaku/Oshi/releases/latest/download/Oshi.ipa)**
- **AltStore / SideStore**: [Add Source](https://raw.githubusercontent.com/Ogaku/Toudai/main/altstore_repo.json)
- **Scarlet**: [Add Source](https://raw.githubusercontent.com/Ogaku/Toudai/main/scarlet_repo.json)

### Web (PWA)
Follow the [Web App Guide](https://github.com/Ogaku/Oshi/wiki/Web-app) to run Oshi in any browser or install it as a Progressive Web App.

---

## 🧩 Provider Extensions

Oshi uses a repository-based extension system similar to Tachiyomi / Mangayomi. On first launch, you can browse and install school register providers directly inside the app:

- **Official Extensions Repository**: [`Ogaku/Oshi-Extensions`](https://github.com/Ogaku/Oshi-Extensions)
- **Supported Providers**: Librus Synergia, eduVULCAN / UONET+, Sample/Demo provider
- **Custom Repositories**: Add your own GitHub repository URL or raw `index.json` link in **Settings → Dostawcy i repozytoria** or during initial register setup.
- **Deep Links**: Tap any `oshi://add-repo?url=...` link to install new sources automatically.

For instructions on authoring your own provider in Dart, check [`extensions_repo/CONTRIBUTING-DART.md`](extensions_repo/CONTRIBUTING-DART.md).

---

## 🛠️ Development & Building

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended)
- Java 17 (JDK) & Android SDK (API 21+)
- VS Code or Android Studio with Flutter/Dart plugins
- Recommended Dart column line limit: **125**

### Quick Start
```bash
# Clone the repository
git clone https://github.com/Ogaku/Oshi.git
cd Oshi

# Install dependencies
flutter pub get

# Run static analysis
dart analyze

# Run unit and extension tests
flutter test

# Build debug APK
flutter build apk --debug --android-skip-build-dependency-validation
```

### Release Signing
Release builds require a keystore. Refer to [`docs/signing.md`](docs/signing.md) for generating and configuring your upload keystore.

---

## 📄 License & Disclaimer

This project is open-source under the [GPL-3.0 License](LICENSE).  
All registered trademarks, logos, and brand names belong to their respective owners. Oshi is an independent open-source client and is not affiliated with or endorsed by any educational platform.
