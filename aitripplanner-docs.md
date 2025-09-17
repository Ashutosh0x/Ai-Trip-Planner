# AI Trip Planner — Technical Documentation

This document explains the architecture, features, and integrated services in the AI Trip Planner app, plus setup and operational notes.

## Overview
- Cross-platform Flutter app (Android, iOS, Web, Desktop)
- Firebase: Auth, Firestore, Storage, Messaging (FCM)
- Stripe payments
- Google Maps, voice input (speech_to_text), TTS, biometrics, secure storage, preferences, localization

## Project Structure
- lib/
  - main.dart: Bootstrap, theming, routes, localization, navigatorKey
  - firebase_background_handler.dart: FCM background entrypoint
  - screens/: UI flows
  - services/: Firebase, payments, notifications, storage, theme, profile
  - widgets/: Reusable components
- functions/: Cloud Functions (Stripe webhook, API)
- platform folders: android/, ios/, macos/, linux/, windows/, web/
- assets/: images, translations

## Core Features
### Authentication
- Firebase Auth: email/password, Google Sign-In
- Services/UI: lib/services/auth_service.dart, login/signup/reset screens
- Cloud Function seeds user profile on create (functions/index.js)

### Firestore
- User profiles, payments history, saved trips
- lib/services/firestore_schema_service.dart centralizes schema/helpers

### Storage
- Firebase Storage for profile photos/media
- lib/services/storage_service.dart handles upload/download

### Secure Storage & Biometrics
- flutter_secure_storage for sensitive values
- local_auth for biometrics
- lib/services/secure_payment_service.dart, biometric_auth_service.dart

### Payments (Stripe)
- Client: flutter_stripe
- Backend: functions/index.js (Express) endpoints and webhook
- Flow: create PaymentIntent → confirm on client → webhook records to Firestore

### Maps & Exploration
- google_maps_flutter; used in explore/planning screens

### Voice & TTS
- speech_to_text for input; flutter_tts for playback

### Localization
- easy_localization with assets/translations/ (ar, de, en, es, fr, hi, ja, pt, ru, zh)

### Theming
- Material 3 light/dark; lib/services/theme_service.dart persists preference

### Notifications (FCM + Local)
- Firebase Messaging + flutter_local_notifications
- Files: lib/services/notifications_service.dart, lib/firebase_background_handler.dart
- Android metadata in android/app/src/main/AndroidManifest.xml
- Behavior:
  - Foreground: show local notification for FCM notifications
  - Background/terminated: tap navigates via data payload
- Payload conventions:
  - data.route: Flutter named route (e.g., /new-event)
  - data.args: JSON string of route args (optional)

### Profile, Settings, Trips
- Screens for profile edit, settings, payments, billing history, trip planning/saved trips/new events

## Services Deep Dive
### Firebase Initialization
- lib/services/firebase_service.dart called from main.dart

### NotificationsService
- Registers onBackgroundMessage handler
- Initializes local notifications, creates Android channel ai_trip_notifications
- Requests permissions (Android 13+/iOS)
- onMessage → local notification with payload
- Handles tap (foreground/local and FCM tap) and navigates using navigatorKey

### PaymentsService
- Talks to Cloud Functions for intents and lists methods
- Works with SecurePaymentService for sensitive steps

### StorageService / ProfileService
- StorageService: uploads/URLs
- ProfileService: Firestore CRUD

### ThemeService
- Reads/writes shared_preferences and notifies MaterialApp

## Routing
- Declared in main.dart
- Notable routes: /, /login, /signup, /onboarding, /home, /explore, /trips, /profile, /edit-profile, /trip-planning, /saved-trips, /ai-picks, /trip-preferences, /budget-preferences, /start-riding, /confirm-pay, /saved-payment-methods, /settings, /billing-history, /payment-methods, /new-event, /search (String arg)
- Notifications may navigate to any route via data.route + optional data.args

## Android Notes
- Permissions: POST_NOTIFICATIONS (Android 13+), RECORD_AUDIO (speech)
- FCM metadata: default channel, icon, color (values/colors.xml → #4ECDC4)
- Service and MainActivity configured

## Secrets & Credentials
- .gitignore excludes: **/google-services.json, **/GoogleService-Info.plist, **/serviceAccount*.json, functions/.runtimeconfig.json, *.jks, *.keystore, android/key.properties, signing.txt, .env*, *.pem/p12/p8, logs
- Never commit credentials; use local files or CI secrets

## Cloud Functions
- functions/index.js
- Endpoints: POST /create-payment-intent, GET /payment-methods (auth required)
- Webhook: POST /stripeWebhook → writes payment/invoice records to Firestore

## Build & Run
- flutter pub get
- flutter run -d <device>
- Android: ensure android/app/google-services.json exists locally
- iOS: ensure ios/Runner/GoogleService-Info.plist exists locally

## Notifications Testing
- Accept permission on first launch
- Foreground shows local notification
- Background/terminated tap navigates via data.route
- HTTP v1 example payload (replace placeholders):
{
  "message": {
    "token": "DEVICE_FCM_TOKEN",
    "notification": { "title": "Trip Reminder", "body": "Your event starts soon" },
    "android": { "priority": "HIGH" },
    "data": { "route": "/new-event", "args": "{\"id\":\"123\"}" }
  }
}

## Extensibility
- Add screens under lib/screens and register a route
- Extend NotificationsService for custom routing logic
- Add Cloud Function endpoints and client wrappers for new backend features

## Notes
- Keep firebaseMessagingBackgroundHandler lightweight
- Android 13+ POST_NOTIFICATIONS runtime permission is required
- Configure Maps API keys per platform
- Keep dependencies up to date and compatible
