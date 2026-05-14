# Pick Tracker

A native Android app for recording warehouse picking efficiency at the case-count level. Built for ALDI Distribution Centre day-shift pickers who use a voice headset hands-free and can only interact with their phone between orders.

Single-screen calculator-style entry, full local history (day / week / month), end-of-shift summary with personal bests and streaks, JSON + CSV exports. Zero network calls, zero telemetry, all data on-device.

## Install

1. Download `app-debug.apk` from this repo's releases page (or build from source, see below).
2. On your Android device, enable "Install unknown apps" for whichever app you used to receive the APK (browser, Files, Drive, Mail).
3. Tap the APK and confirm install.

## Features

- **12-button keypad** for fast between-orders entry (0–9, ⌫, NEXT) — calculator layout
- **Per-order auto-timing** — case count + automatic start/end timestamps from NEXT presses
- **Auto shift detection** — new shift starts on first order; idle gap >120 min auto-closes
- **Outlier detection** — orders below 30/hr or longer than 30 min are flagged and excluded from average rate
- **Day / Week / Month history** with per-shift sparklines and a month heatmap
- **End-of-Shift Summary** with shift rate, active rate, best/slowest orders, streak
- **JSON + CSV exports** via the Android share sheet
- **VIC public-holiday awareness** — pre-loaded for 2026
- **Wake-lock** keeps the screen on during an active shift (toggleable)
- **Premium dark theme** with signature amber (`#FFB300`) accent, tabular figures, gradient progress bar

## Privacy

This app makes **zero network calls**. Zero telemetry. Zero analytics. All data is stored locally in a private SQLite database on the device.

Permissions requested:
- Storage (for app data + JSON/CSV exports)

## Build from source

Requires Flutter 3.x with the Android toolchain.

```sh
git clone <this repo>
cd pick_tracker
flutter pub get
flutter build apk --debug          # development build
flutter build apk --release        # production build (requires signing config)
```

The debug APK lands at `build/app/outputs/flutter-apk/app-debug.apk`.

### Release signing (one-time setup)

For a properly signed release build, generate a keystore and add a `key.properties` file:

```sh
mkdir -p ~/keystores
keytool -genkey -v -keystore ~/keystores/pick_tracker.jks \
  -alias pick_tracker -keyalg RSA -keysize 2048 -validity 10000
```

Create `android/key.properties` (gitignored) with:

```
storeFile=/Users/<you>/keystores/pick_tracker.jks
storePassword=<store-password>
keyAlias=pick_tracker
keyPassword=<key-password>
```

Wire it into `android/app/build.gradle.kts` per Flutter's [Android deployment guide](https://docs.flutter.dev/deployment/android#signing-the-app). Then `flutter build apk --release` produces a signed APK at `build/app/outputs/flutter-apk/app-release.apk`.

## Tests

```sh
flutter test         # 48 unit + widget tests
flutter analyze      # static analysis
```

## License

MIT
