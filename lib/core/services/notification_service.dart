import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _messaging.getToken();
    // TODO: Save token to Firestore for the current user
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // TODO: Show local notification
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // TODO: Navigate to relevant screen
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> subscribeToTopic(String topic) => _messaging.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) => _messaging.unsubscribeFromTopic(topic);
}
