import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_background_handler.dart';

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
    'ai_trip_notifications',
    'AI Trip Notifications',
    description: 'General notifications for AI Trip Planner',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    // Local notifications init
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse resp) {
        _handleNotificationTapPayload(resp.payload);
      },
      onDidReceiveBackgroundNotificationResponse: (NotificationResponse resp) {
        _handleNotificationTapPayload(resp.payload);
      },
    );

    // Create channel on Android
    await _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_defaultChannel);

    // Ask notification permission (Android 13+ and iOS)
    await _requestPermission();

    // FCM foreground messages -> show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      final RemoteNotification? notif = msg.notification;
      final AndroidNotification? android = notif?.android;
      if (notif != null && (Platform.isAndroid ? android != null : true)) {
        _local.show(
          notif.hashCode,
          notif.title,
          notif.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'ai_trip_notifications',
              'AI Trip Notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: _encodePayloadFromMessage(msg),
        );
      }
    });

    // App opened from a notification while in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleRemoteMessageNavigation(message);
    });

    // App opened from a terminated state via notification tap
    final RemoteMessage? initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleRemoteMessageNavigation(initial);
    }

    // Ensure token is available (you can send to backend)
    final String? token = await _messaging.getToken();
    debugPrint('[FCM] Device token: ' + (token ?? 'null'));
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void _handleNotificationTapPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return;
    }
    try {
      final Map<String, dynamic> decoded = json.decode(payload) as Map<String, dynamic>;
      final String? route = decoded['route'] as String?;
      final dynamic args = decoded['args'];
      if (route != null && navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushNamed(route, arguments: args);
      }
    } catch (_) {
      // Ignore malformed payloads
    }
  }

  void _handleRemoteMessageNavigation(RemoteMessage message) {
    final Map<String, dynamic> data = message.data;
    final String? route = data['route'] ?? data['deeplink'];
    final String? argsJson = data['args'];
    dynamic args;
    if (argsJson != null) {
      try {
        args = json.decode(argsJson);
      } catch (_) {}
    }
    if (route != null && navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed(route, arguments: args);
    }
  }

  String _encodePayloadFromMessage(RemoteMessage message) {
    final Map<String, dynamic> data = message.data;
    final String? route = data['route'] ?? data['deeplink'];
    final String? args = data['args'];
    return json.encode({
      if (route != null) 'route': route,
      if (args != null) 'args': _tryDecode(args) ?? args,
    });
  }

  dynamic _tryDecode(String value) {
    try {
      return json.decode(value);
    } catch (_) {
      return null;
    }
  }
}


