import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.registerBackgroundHandler();
  final app = await AppBootstrap.initialize();
  runApp(app);
}
