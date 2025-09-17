# Firebase Setup Instructions

## 🔥 Firebase Configuration

This app is ready for Firebase integration! Follow these steps to set up Firebase:

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `ai-trip-planner` (or your preferred name)
4. Enable Google Analytics (optional)
5. Create project

### 2. Add Apps to Firebase Project

#### Android App:
1. Click "Add app" → Android
2. Package name: `com.example.ai_trip_planner`
3. Download `google-services.json`
4. Place it in `android/app/` directory

#### Web App:
1. Click "Add app" → Web
2. App nickname: `AI Trip Planner Web`
3. Copy the Firebase config object

### 3. Enable Authentication
1. Go to Authentication → Sign-in method
2. Enable **Email/Password**
3. Enable **Google** sign-in
4. Add your domain for web (localhost for development)

### 4. Enable Firestore Database
1. Go to Firestore Database
2. Click "Create database"
3. Start in **test mode** (for development)
4. Choose a location close to your users

### 5. Enable Firebase Storage
1. Go to Storage
2. Click "Get started"
3. Start in **test mode** (for development)
4. Choose the same location as Firestore
5. This will store user profile pictures and other media

### 6. Update Firebase Configuration

#### Option A: Using FlutterFire CLI (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

#### Option B: Manual Configuration
Replace the placeholder values in `lib/firebase_options.dart`:

```dart
// Replace these placeholder values with your actual Firebase config
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_WEB_API_KEY',
  appId: 'YOUR_ACTUAL_WEB_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
  projectId: 'your-actual-project-id',
  authDomain: 'your-actual-project-id.firebaseapp.com',
  storageBucket: 'your-actual-project-id.appspot.com',
  measurementId: 'YOUR_ACTUAL_MEASUREMENT_ID',
);

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_ANDROID_API_KEY',
  appId: 'YOUR_ACTUAL_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
  projectId: 'your-actual-project-id',
  storageBucket: 'your-actual-project-id.appspot.com',
);
```

### 7. Google Sign-In Setup

#### Android:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to APIs & Services → Credentials
4. Create OAuth 2.0 Client ID for Android
5. Add your SHA-1 fingerprint

#### Web:
1. In Google Cloud Console
2. Create OAuth 2.0 Client ID for Web application
3. Add authorized domains

### 8. Test Firebase Integration

Once configured, the app will:
- ✅ Initialize Firebase on startup
- ✅ Handle email/password authentication
- ✅ Handle Google Sign-In
- ✅ Store user profiles in Firestore
- ✅ Upload profile pictures to Firebase Storage
- ✅ Show proper error messages

### 8. Development vs Production

#### Development:
- Use test mode for Firestore
- Add localhost to authorized domains
- Use debug SHA-1 fingerprints

#### Production:
- Set up Firestore security rules
- Add production domains
- Use release SHA-1 fingerprints
- Enable App Check for security

## 🚀 Ready to Go!

After completing these steps, your AI Trip Planner app will have full Firebase integration with:
- User authentication (Email/Password + Google)
- User profile storage
- Real-time database
- Error handling
- Cross-platform support (Android + Web)

## 📱 Current App Features

- ✅ Beautiful splash screen with image carousel
- ✅ Login screen with Firebase integration
- ✅ Google SSO ready
- ✅ Responsive design for mobile and web
- ✅ Material Design 3 theming
- ✅ Error handling and loading states

## 🔄 Next Steps

1. Set up Firebase (follow instructions above)
2. Create user onboarding/profile setup screen
3. Add home screen
4. Implement trip preferences
5. Add Google Maps integration
6. Build AI trip planning features

---

**Note:** The app will run without Firebase configuration, but authentication features will show appropriate error messages until Firebase is properly set up.
