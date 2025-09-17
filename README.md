# AI Trip Planner

AI Trip Planner is a production-ready Flutter app that helps users plan and manage trips with an AI-assisted experience. It integrates Firebase (Auth, Firestore, Storage, Messaging), Stripe payments, Google Maps, voice input (speech_to_text), TTS, biometrics, secure storage, preferences, and localization.

## Table of Contents
- Project Overview
- Technologies Used
- Cloud Services
- Prerequisites
- Local Environment Setup
- Android Emulator Setup
- iOS Simulator Setup (macOS)
- Firebase Setup
- Running the App
- Notifications (FCM + Local)
- Payments (Stripe)
- Useful Commands
- Repository Structure
- Security & Secrets
- Documentation

## Project Overview
- Cross-platform Flutter app: Android, iOS, Web, Desktop
- Rich features: authentication, profiles, trip planning, maps, voice, payments, notifications, theming, i18n

## Technologies Used
- Flutter 3 (Dart SDK ^3.8)
- State: provider
- Localization: easy_localization
- Storage & prefs: flutter_secure_storage, shared_preferences
- Biometrics: local_auth
- Voice: speech_to_text, flutter_tts
- Maps: google_maps_flutter
- Notifications: firebase_messaging, flutter_local_notifications
- Payments: flutter_stripe

## Cloud Services
- Firebase
  - Auth (email/password, Google Sign-In)
  - Firestore (profiles, payments history, saved trips)
  - Storage (profile images)
  - Cloud Messaging (FCM)
  - Cloud Functions (Node.js/Express) for Stripe API + webhooks
- Stripe
  - PaymentIntents
  - Saved payment methods
  - Webhooks

## Prerequisites
- Flutter SDK installed and in PATH
- Android Studio with Android SDK / Platform Tools
- For iOS (macOS): Xcode + CocoaPods
- GitHub CLI (optional) if contributing

## Local Environment Setup
1) Install dependencies
```bash
flutter pub get
```

2) Add Firebase configuration files (not committed)
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

3) (Optional) Configure Google Maps API key per platform
- Follow Google Maps Flutter setup docs to add API keys in Android/iOS configuration

## Android Emulator Setup
```bash
# List Android emulators
flutter emulators

# Launch an emulator (replace with your AVD ID)
flutter emulators --launch emulator-5554

# Verify connected devices
flutter devices
```

## iOS Simulator Setup (macOS)
```bash
# List simulators
xcrun simctl list devices

# Open Simulator app
open -a Simulator

# Run to a specific simulator
flutter run -d <simulator-id>
```

## Firebase Setup
- Ensure `lib/firebase_options.dart` exists (via FlutterFire CLI) or initialize in `FirebaseService`
- Android: confirm `android/app/google-services.json`
- iOS: confirm `ios/Runner/GoogleService-Info.plist`
- Enable FCM in Firebase Console

## Running the App
```bash
# Get dependencies
flutter pub get

# Run on Android emulator
flutter run -d emulator-5554

# List devices and run
flutter devices
flutter run -d <device-id>
```

## Notifications (FCM + Local)
- On first launch, grant notification permissions (Android 13+ / iOS)
- Foreground: FCM messages show a local notification
- Background/terminated: tapping the push navigates by `data.route` (and optional `data.args`)

Example HTTP v1 test payload:
```json
{
  "message": {
    "token": "DEVICE_FCM_TOKEN",
    "notification": { "title": "Trip Reminder", "body": "Your event starts soon" },
    "android": { "priority": "HIGH" },
    "data": { "route": "/new-event", "args": "{\"id\":\"123\"}" }
  }
}
```

## Payments (Stripe)
- Client uses `flutter_stripe`
- Backend Cloud Functions exposes `POST /create-payment-intent`, `GET /payment-methods` and a webhook `/stripeWebhook`
- Flow: create PaymentIntent → confirm on client → webhook records results in Firestore

## Useful Commands
```bash
# Analyze & format
flutter analyze
flutter format .

# Build Android APK
flutter build apk --release

# Clean & reset deps
flutter clean && flutter pub get
```

## Repository Structure
- `lib/` — UI screens, services, background handler
- `functions/` — Cloud Functions (Stripe API + webhook)
- `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/` — platform runners
- `assets/` — images and translations

## Security & Secrets
- `.gitignore` excludes Firebase configs, keystores, env files, signing info, service account JSONs, runtime configs, and common key formats
- Never commit credentials; use local files and CI/CD secrets (GitHub Actions, etc.)

## Documentation
- For a deeper technical dive, see `aitripplanner-docs.md` (architecture, services, flows, payload conventions).
