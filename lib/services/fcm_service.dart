import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    NotificationSettings settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      if (token != null) {
        await SharedPreferences.getInstance().then((prefs) => prefs.setString('fcmToken', token));
        // Send token to backend to update user doc
        await ApiService.updateFCMToken(token);  // Implement in API
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show in-app notification
      print('Foreground message: ${message.notification?.title}');
      // Use flutter_local_notifications for UI
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate based on message data (e.g., order update)
    });
  }
}