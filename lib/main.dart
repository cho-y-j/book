import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  // 앱 전체 에러 캐치 — 검은 화면/크래시 방지
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Flutter 프레임워크 에러 → 로그만 출력 (검은 화면 X)
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint('FlutterError: ${details.exception}');
      }
    };

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final notificationService = NotificationService();
    await notificationService.init();

    runApp(
      const ProviderScope(
        child: BookGajiApp(),
      ),
    );
  }, (error, stackTrace) {
    // Zone 밖 비동기 에러 캐치
    if (kDebugMode) {
      debugPrint('Uncaught error: $error');
      debugPrint('$stackTrace');
    }
  });
}
