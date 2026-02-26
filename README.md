# Myflutter

Flutter base template with:
- Common constants/strings
- Multi-language (English + Hindi) localization
- API calls for all common types:
  - `GET/POST/PUT/PATCH/DELETE`
  - with header / without header
  - JSON body + form-data/multipart
- User defaults (native storage wrapper)
- Light/Dark/System theme support
- Firebase push notifications (FCM) base setup
- Local notifications base setup

## Structure

```text
lib/
  app.dart
  main.dart
  core/
    constants/
    localization/
    network/
    notifications/
    storage/
    theme/
  features/
    home/
```

## Core files

- `lib/core/constants/app_strings.dart`: shared text constants and language codes.
- `lib/core/localization/*`: localization delegate + in-app translation map + locale controller.
- `lib/core/network/api_client.dart`: reusable Dio client with:
  - all HTTP methods: `get/post/put/patch/delete`
  - with header and without header helpers
  - multipart/form-data helpers (`post/put/patch`)
- `lib/core/notifications/notification_service.dart`: common push + local notification entrypoint.
- `lib/core/notifications/firebase_options.dart`: placeholder Firebase options file.
- `lib/core/storage/user_defaults.dart`: native key-value wrapper (token, fcm token, locale, theme mode).
- `lib/core/theme/*`: reusable light/dark theme and runtime theme controller.

## Firebase Setup

1. Configure your Firebase project:
   ```bash
   flutterfire configure
   ```
2. Replace `lib/core/notifications/firebase_options.dart` with generated values and set:
   ```dart
   static bool get isConfigured => true;
   ```
3. Add platform Firebase config files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

## Run

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Start app:
   ```bash
   flutter run
   ```
