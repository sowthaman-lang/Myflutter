import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  // Set to true after adding real Firebase options from FlutterFire CLI.
  static bool get isConfigured => false;

  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase is not configured. Run: flutterfire configure '
      'and update lib/core/notifications/firebase_options.dart',
    );
  }
}
