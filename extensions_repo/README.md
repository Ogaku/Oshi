# Oshi Extensions Hub & Developer Guide

Welcome to the **Oshi Extensions Hub**! This repository serves as the central directory, catalog, and developer guide for school register extensions compatible with [**Oshi**](https://github.com/Ogaku/Oshi).

Every register provider extension in Oshi is maintained in its **own dedicated repository** and loaded dynamically inside the app using the [`d4rt`](https://pub.dev/packages/d4rt) Dart interpreter (modeled after Mangayomi extensions).

---

## 📚 Official Extensions Directory

Each extension is developed, maintained, and versioned in its own independent repository:

| Register Provider | Extension Repository | Direct Script URL | Supported Platform |
| :--- | :--- | :--- | :--- |
| **Librus Synergia** | [Ogaku/Oshi-Extension-Librus](https://github.com/Ogaku/Oshi-Extension-Librus) | [`extension.dart`](https://raw.githubusercontent.com/Ogaku/Oshi-Extension-Librus/main/extension.dart) | Synergia API |
| **eduVULCAN / UONET+** | [Ogaku/Oshi-Extension-Vulcan](https://github.com/Ogaku/Oshi-Extension-Vulcan) | [`extension.dart`](https://raw.githubusercontent.com/Ogaku/Oshi-Extension-Vulcan/main/extension.dart) | eduVULCAN API |
| **Sample / Starter Template** | [Ogaku/Oshi-Extension-Sample](https://github.com/Ogaku/Oshi-Extension-Sample) | [`extension.dart`](https://raw.githubusercontent.com/Ogaku/Oshi-Extension-Sample/main/extension.dart) | Demo / Mock |

---

## 🚀 How to Add This Repository to Oshi

The official extensions catalog is loaded by default in Oshi. If you ever need to re-add it or install it manually:

1. Open **Oshi**.
2. Go to **Settings > Extensions & Repositories** (or during the initial welcome setup).
3. Click **Add Repository** and enter:
   ```text
   https://raw.githubusercontent.com/Ogaku/Oshi-Extensions/main/index.json
   ```
   *(You can also simply enter the GitHub repo URL: `https://github.com/Ogaku/Oshi-Extensions`)*

4. You can also use the one-click deep link:
   ```text
   oshi://add-repo?repo_name=Oshi-Extensions&repo_url=https://raw.githubusercontent.com/Ogaku/Oshi-Extensions/main/index.json
   ```

---

## 🛠️ Developer Guide: Creating Your Own Extension

Want to support your school's custom register, university portal, or alternative platform? Follow the steps below!

### 1. Create a Repository for Your Extension
Create a new public GitHub repository for your extension (e.g. `your-username/oshi-extension-myschool`).

### 2. Extension Anatomy (`extension.dart`)
An Oshi extension is a single Dart script. It begins with metadata tags in the header:

```dart
// @id PROVGUID-CUSTOM-MYSCHOOL
// @name My School Register
// @version 1.0.0
// @lang pl
// @author YourName
// @baseUrl https://register.myschool.edu
// @loginType 20
// @description Custom school register extension for Oshi.
```

### 3. Required API Contract
Your extension should expose standard lifecycle functions invoked by Oshi's runtime bridge:

```dart
// 1. Authenticate with credentials provided by the user
Future<Map<String, dynamic>> login(Map<String, String> credentials) async {
  // Use httpGet / httpPost provided by Oshi's bridge context
  return {'success': true};
}

// 2. Fetch fresh register data (timetable, grades, messages)
Future<Map<String, dynamic>> refresh({String? weekStart}) async {
  return {'success': true};
}

// 3. Provide downloaded data in Oshi ProviderData JSON schema
Map<String, dynamic> getRegisterDataJson() {
  return {
    "student": {
      "account": {"firstName": "Jan", "lastName": "Kowalski"},
      "mainClass": {"name": "3A", "symbol": "3A"}
    },
    "timetables": {},
    "messages": {}
  };
}
```

### 4. Installing Directly from Your Repository
Users can install your extension directly by pasting your raw `extension.dart` URL into Oshi:
```text
https://raw.githubusercontent.com/your-username/oshi-extension-myschool/main/extension.dart
```

### 5. Submitting to the Official Catalog
To make your extension discoverable by all Oshi users:
1. Fork this repository (`Ogaku/Oshi-Extensions`).
2. Add your extension's entry to [`index.json`](./index.json).
3. Submit a Pull Request.

---

## 📄 License
This repository and its official extensions are licensed under the MIT License.
