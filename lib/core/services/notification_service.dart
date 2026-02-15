import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Navigator key for routing on notification tap
  static String? pendingRoute;

  Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Initialize local notifications (mobile only)
    if (!kIsWeb) {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _localNotifications.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
    }

    // Save FCM token to Firestore
    final token = await _messaging.getToken();
    await _saveTokenToFirestore(token);

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated message opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'fcmToken': token, 'fcmTokenUpdatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    if (!kIsWeb) {
      // Read user's preferred sound from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final soundFile = prefs.getString('notificationSound') ?? 'notification_default.mp3';

      final AndroidNotificationDetails androidDetails;
      if (soundFile.isEmpty) {
        // Silent
        androidDetails = const AndroidNotificationDetails(
          'bookbridge_silent',
          '책가지 알림 (무음)',
          channelDescription: '알림음 없이 표시됩니다',
          playSound: false,
          importance: Importance.high,
          priority: Priority.high,
        );
      } else {
        final channelId = 'bookbridge_${soundFile.replaceAll('.mp3', '').replaceAll('.wav', '')}';
        androidDetails = AndroidNotificationDetails(
          channelId,
          '책가지 알림',
          channelDescription: '교환 요청, 매칭, 채팅 등 알림',
          sound: RawResourceAndroidNotificationSound(
            soundFile.replaceAll('.mp3', '').replaceAll('.wav', ''),
          ),
          importance: Importance.high,
          priority: Priority.high,
        );
      }

      _localNotifications.show(
        notification.hashCode,
        notification.title ?? '책가지',
        notification.body ?? '',
        NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: soundFile.isNotEmpty,
            sound: soundFile.isNotEmpty ? soundFile : null,
          ),
        ),
        payload: _buildPayload(message.data),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    if (type != null && id != null) {
      switch (type) {
        case 'exchange_request':
        case 'match':
          pendingRoute = '/incoming-requests';
          break;
        case 'chat':
          pendingRoute = '/chat-room/$id';
          break;
        case 'wishlist_match':
          pendingRoute = '/book/$id';
          break;
        default:
          pendingRoute = '/notifications';
      }
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      pendingRoute = response.payload;
    }
  }

  String _buildPayload(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;
    if (type == 'chat' && id != null) return '/chat-room/$id';
    if (type == 'wishlist_match' && id != null) return '/book/$id';
    if (type == 'exchange_request') return '/incoming-requests';
    return '/notifications';
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> subscribeToTopic(String topic) => _messaging.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) => _messaging.unsubscribeFromTopic(topic);
}
