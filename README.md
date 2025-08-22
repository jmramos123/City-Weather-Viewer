# City Weather Viewer — README

Repository
----------
https://github.com/jmramos123/City-Weather-Viewer

Project summary
---------------
A small Flutter app that fetches current weather for a user-entered city using the OpenWeatherMap Current Weather API and displays temperature, a short description, and an icon.

Prerequisites
-------------
- Flutter SDK (stable) installed and on your PATH — https://flutter.dev/docs/get-started/install
- Android Studio (recommended) for emulators and Android builds, or Xcode for iOS builds
- Android SDK & platform-tools (adb). Ensure `ANDROID_SDK_ROOT` or `ANDROID_HOME` is set and the tools are on your PATH.
- Git to clone the repo

Quick clone
-----------
```bash
git clone https://github.com/jmramos123/City-Weather-Viewer.git
cd City-Weather-Viewer
```

Install dependencies
--------------------
Make sure `pubspec.yaml` contains the `http` dependency. Then:
```bash
flutter pub get
```

Android configuration
---------------------
Add Internet permission (Android only). In `android/app/src/main/AndroidManifest.xml` inside the `<manifest>` tag add:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

API key (DO NOT commit)
-----------------------
The app expects the OpenWeatherMap API key to be provided at build/run time. **Do not** commit API keys to version control.

Recommended options:

**1) Use `--dart-define` (recommended for CI/local builds)**
- Run/debug locally (example):
  ```bash
  flutter run -d <DEVICE_ID> --dart-define=OPENWEATHER_API_KEY=YOUR_REAL_KEY
  ```
- Build release with the key injected:
  ```bash
  flutter build apk --dart-define=OPENWEATHER_API_KEY=YOUR_REAL_KEY
  ```

**2) Use `.env` with `flutter_dotenv` (local file, add to .gitignore)**
- Add `flutter_dotenv` to `pubspec.yaml`, create a `.env` containing `OPENWEATHER_API_KEY=your_key`, load it in `main()`.

Running the app (examples)
--------------------------
### Start an emulator (CLI)
List AVDs:
```bash
emulator -list-avds
```
Start emulator and force DNS to Google (optional):
```bash
emulator -avd <AVD_NAME> -dns-server 8.8.8.8,8.8.4.4 &
```
(Windows PowerShell users: replace `&` usage with running the emulator directly or use `Start-Process`.)

### Confirm device id
```bash
adb devices
# or
flutter devices
```

### Run the app (from project root)
```bash
flutter run -d <DEVICE_ID> --dart-define=OPENWEATHER_API_KEY=YOUR_REAL_KEY
```
If you omit `-d`, `flutter run` will prompt to select a device.

Running from Android Studio
---------------------------
1. Open Android Studio and **Open** the project folder (or run `studio .` if you created the command-line launcher).
2. Let Gradle sync and indexing finish.
3. Use the device selector to pick your emulator/physical device.
4. To inject the API key when running from Android Studio, set the VM/Flutter run arguments in run configurations:
   - Edit Configurations → Additional run args (or in the run configuration's "Dart entrypoint arguments") add:
     `--dart-define=OPENWEATHER_API_KEY=YOUR_REAL_KEY`

Usage
  ![weather](https://github.com/user-attachments/assets/ccbc83b7-afcd-49bf-b150-2c985da03da1)


Web compatibility
-----------------
The current app uses `dart:io` to detect `SocketException`. If you want to compile for Flutter Web, remove `dart:io` imports and rely on generic `Exception` handling so the web build succeeds.

Troubleshooting
---------------
- If `package:http/http.dart` can't be found: ensure `http:` is in `pubspec.yaml` and run `flutter pub get`.
- If the app cannot find the API key at runtime: make sure you used `--dart-define` or loaded `.env` before running.
- If the emulator isn't detected: run `adb devices` and ensure the emulator is fully booted; restart adb (`adb kill-server && adb start-server`) if needed.

Security notes
--------------
- Rotate/revoke the API key if it has been exposed publicly.
- Add `.env` to `.gitignore` and never commit secrets.
- In CI, store the key as a secret and inject it via `--dart-define` at build time.

Contributing
------------
PRs welcome. Before opening a PR:
1. Fork the repo and create a branch.
2. Run `flutter pub get` and ensure the app builds.
3. Add tests for new features when applicable.

License
-------
Choose and add a license file (e.g., MIT, Apache-2.0) to the repository.

Contact
-------
Repo: https://github.com/jmramos123/City-Weather-Viewer

