# Kids Adventure

A Flutter application with Firebase Authentication and go_router navigation.

## 🔐 Authentication System

This project uses Firebase Authentication with multiple sign-in methods:

- **Email & Password**: Traditional login/registration
- **Google Sign-In**: OAuth authentication using Google
- **Anonymous Sign-In**: Quick access without registration (for development)

## 🧭 Navigation System

The app uses go_router for navigation with the following features:

- **Route Guards**: Protected routes that require authentication
- **Animated Transitions**: Custom transitions between screens
- **Deep Linking**: Support for deep links and query parameters

## 📱 App Screens

- **Splash Screen**: Initial loading screen with authentication check
- **Login Screen**: Email/password and Google sign-in options
- **Register Screen**: New user registration with form validation
- **Home Screen**: Main dashboard after authentication
- **Category Screen**: Display quiz categories
- **Quiz Screen**: Interactive quiz experience
- **Result Screen**: Display quiz results
- **Profile Screen**: User profile management
- **Settings Screen**: App settings and preferences

## 🛠️ Project Structure

```
lib/
├── constants/
│   └── app_constants.dart       # App-wide constants and route names
├── models/
│   ├── category.dart            # Category data model
│   └── user_profile.dart        # User profile data model
├── providers/
│   ├── auth_provider.dart       # Authentication state management
│   ├── quiz_provider.dart       # Quiz state management
│   └── theme_provider.dart      # Theme state management
├── routes/
│   └── app_router.dart          # go_router configuration
├── screens/
│   ├── splash_screen.dart       # Initial loading screen
│   ├── login_screen.dart        # Login screen
│   ├── register_screen.dart     # Registration screen
│   └── [other screens]          # Additional app screens
├── services/
│   ├── auth_service.dart        # Firebase authentication service
│   └── user_service.dart        # User data management
├── theme/
│   └── app_theme.dart           # App theme configuration
├── utils/
│   └── sound_manager.dart       # Sound effects management
└── main.dart                    # App entry point
```

## ⚙️ Setup Instructions

1. **Clone the repository**:
   ```
   git clone <repository-url>
   ```

2. **Install dependencies**:
   ```
   flutter pub get
   ```

3. **Configure Firebase**:
   - Create a Firebase project
   - Add Android/iOS apps to your Firebase project
   - Download the configuration files (google-services.json for Android, GoogleService-Info.plist for iOS)
   - Place them in the appropriate locations
   - Enable Email/Password and Google Sign-In authentication methods

4. **Run the app**:
   ```
   flutter run
   ```

## 📦 Dependencies

- **firebase_core**: Firebase core functionality
- **firebase_auth**: Firebase authentication
- **cloud_firestore**: Cloud Firestore database
- **google_sign_in**: Google authentication
- **provider**: State management
- **go_router**: Advanced routing
- **lottie**: Animations
- **shared_preferences**: Local storage

## 🌟 Features

- **User Authentication**: Secure login and registration
- **Profile Management**: User profile customization
- **Progress Tracking**: Track quiz performance and XP
- **Adaptive Themes**: Light and dark mode support
- **Sound Effects**: Interactive audio feedback

## 🔍 Future Improvements

- Add more authentication providers (Apple, Facebook)
- Implement offline quiz mode
- Add localization support
- Improve accessibility features
