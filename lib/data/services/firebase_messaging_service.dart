import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_camera/data/network/api/user_token_api_service.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/local/preference/notification_preference.dart';
import 'package:flutter_camera/domain/model/user.dart';
import 'package:flutter_camera/presentation/routes/app_routes.dart';
import 'package:flutter_camera/main.dart' as main_app;
import 'package:injectable/injectable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler - phải là top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Firebase: Background message received');
  print('📨 Firebase: messageId: ${message.messageId}');
  print('📨 Firebase: Title: ${message.notification?.title}');
  print('📨 Firebase: Body: ${message.notification?.body}');
  print('📨 Firebase: Data: ${message.data}');
}

@singleton
class FirebaseMessagingService {
  FirebaseMessaging? _messaging;
  final UserTokenApiService _userTokenApi;
  final AuthLocalPreference _authPreference;
  final NotificationPreference _notificationPreference;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;
  User? _currentUser;

  FirebaseMessagingService(this._userTokenApi, this._authPreference, this._notificationPreference);

  FirebaseMessaging get messaging {
    if (_messaging == null) {
      throw Exception('Firebase messaging not initialized. Call initialize() first.');
    }
    return _messaging!;
  }

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;
  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    try {
      print('🔥 Firebase: Initializing messaging...');

      // Initialize Firebase Messaging instance
      _messaging = FirebaseMessaging.instance;
      print('🔥 Firebase: Messaging instance created');

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      print('🔥 Firebase: Background handler registered');

      // Request permission for notifications
      print('🔔 Firebase: Requesting notification permission...');
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📱 Firebase: Permission status: ${settings.authorizationStatus}');
      print('📱 Firebase: Alert enabled: ${settings.alert}');
      print('📱 Firebase: Badge enabled: ${settings.badge}');
      print('📱 Firebase: Sound enabled: ${settings.sound}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Firebase: Permission authorized, setting up token...');
        await _setupToken();
        await _setupMessageHandlers();
        _isInitialized = true;
        print('✅ Firebase: Messaging initialization complete');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ Firebase: Permission is provisional');
        await _setupToken();
        await _setupMessageHandlers();
        _isInitialized = true;
        print('✅ Firebase: Messaging initialization complete (provisional)');
      } else {
        print('❌ Firebase: Permission denied or not determined');
        print('❌ Firebase: Status: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print('❌ Firebase: Initialization error: $e');
    }
  }

  Future<void> _setupToken() async {
    try {
      print('🔑 Firebase: Getting FCM token...');

      // On iOS, we need to wait a bit for APNS token to be registered
      if (Platform.isIOS) {
        print('⏳ Firebase: Waiting for APNS token (iOS)...');
        await Future.delayed(const Duration(seconds: 2));
      }

      _fcmToken = await messaging.getToken();
      print('🔑 Firebase: FCM Token received: $_fcmToken');
      print('📋 Firebase: Token length: ${_fcmToken?.length ?? 0} characters');

      if (_fcmToken != null) {
        print('📤 Firebase: Registering token with server...');
        await _sendTokenToServer();
      } else {
        print('⚠️ Firebase: FCM Token is null!');
        print('⚠️ Firebase: This might be because APNS token is not set yet');
        print('⚠️ Firebase: Make sure Push Notifications capability is enabled in Xcode');
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen((String token) async {
        print('🔄 Firebase: Token refreshed: $token');
        print('📋 Firebase: New token length: ${token.length} characters');
        _fcmToken = token;
        await _sendTokenToServer();
      });
    } catch (e) {
      print('❌ Firebase: Token setup error: $e');
      print('❌ Firebase: Error type: ${e.runtimeType}');
      if (e.toString().contains('apns-token-not-set')) {
        print('❌ Firebase: APNS token not set - this is expected in simulator');
        print('❌ Firebase: Please test on a real iOS device');
      }
    }
  }

  Future<void> _sendTokenToServer() async {
    if (_fcmToken == null) return;

    try {
      final tokens = _authPreference.getTokens();
      if (tokens?.accessToken == null) {
        print('⚠️ Firebase: No auth token available, skipping server registration');
        return;
      }

      // Use current user ID if available, otherwise skip registration
      if (_currentUser == null) {
        print('⚠️ Firebase: No current user available, skipping server registration');
        return;
      }

      // Lấy FCM token cũ đã lưu
      final savedToken = _authPreference.getFcmToken();

      // So sánh token cũ và mới
      if (savedToken == _fcmToken) {
        print('ℹ️ Firebase: Token unchanged, skipping server registration');
        print('📋 Firebase: Saved token: ${savedToken?.substring(0, 20)}...');
        print('📋 Firebase: Current token: ${_fcmToken?.substring(0, 20)}...');
        return;
      }

      print('🔄 Firebase: Token changed, sending to server...');
      if (savedToken != null) {
        print('📋 Firebase: Old token: ${savedToken.substring(0, 20)}...');
      } else {
        print('📋 Firebase: No saved token found (first time)');
      }
      print('📋 Firebase: New token: ${_fcmToken!.substring(0, 20)}...');

      final success = await _userTokenApi.postUserToken(
        userId: _currentUser!.id.toString(),
        deviceType: Platform.isAndroid ? "android" : "ios",
        token: _fcmToken!,
        areaIds: [],
        isAdmin: _currentUser!.roleNames.toLowerCase().contains('admin'),
        authToken: tokens?.accessToken ?? '',
      );

      if (success) {
        // Lưu token mới vào SharedPreferences sau khi gửi thành công
        await _authPreference.saveFcmToken(_fcmToken!);
        print(
          '✅ Firebase: Token registered with server successfully for user ${_currentUser!.username}',
        );
        print('💾 Firebase: New token saved to local storage');
      } else {
        print('❌ Firebase: Failed to register token with server');
      }
    } catch (e) {
      print('❌ Firebase: Error sending token to server: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      print('🔔 Initializing local notifications...');

      // Android initialization settings
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create Android notification channel
      if (Platform.isAndroid) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          await androidPlugin.createNotificationChannel(channel);
          print('✅ Android notification channel created');
        }
      }

      print('✅ Local notifications initialized');
    } catch (e) {
      print('⚠️ Local notifications initialization failed: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped');
    print('🔔 Payload: ${response.payload}');

    // Handle navigation based on payload
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        // Parse payload: "type|id|dataTime"
        final parts = response.payload!.split('|');
        if (parts.length >= 3) {
          final type = parts[0];
          final id = parts[1];
          final dataTime = parts[2];

          print('🧭 Navigating to notification detail');
          print('🧭 Type: $type, ID: $id, DataTime: $dataTime');

          // Navigate to notification detail page
          main_app.navigatorKey.currentState?.pushNamed(
            AppRoutes.notificationDetail,
            arguments: {'id': id, 'dataTime': dataTime},
          );
        } else {
          print('⚠️ Invalid payload format: ${response.payload}');
        }
      } catch (e) {
        print('❌ Error parsing notification payload: $e');
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    // ✅ Check notification settings first
    if (!_notificationPreference.notificationsEnabled) {
      print('🔕 Notifications are disabled by user, skipping notification');
      return;
    }

    // Check if it's quiet hours
    if (_notificationPreference.isQuietHours()) {
      print('😴 Quiet hours active, skipping notification');
      return;
    }

    final notification = message.notification;
    if (notification == null) {
      print('⚠️ No notification data to display');
      return;
    }

    print('🔔 Showing local notification');
    print('🔔 Title: ${notification.title}');
    print('🔔 Body: ${notification.body}');
    print('🔔 Data: ${message.data}');

    // Extract notification data for navigation
    final String? id = message.data['id'];
    final String? dataTime = message.data['dataTime'];
    final String? type = message.data['type'];

    // Create payload for navigation
    String? payload;
    if (id != null && dataTime != null) {
      payload = '$type|$id|$dataTime';
      print('🔔 Payload created: $payload');
    }

    // Android notification details - respect user settings
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: _notificationPreference.soundEnabled,
      enableVibration: _notificationPreference.vibrationEnabled,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
      ticker: 'New notification',
    );

    // iOS notification details - respect user settings
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: _notificationPreference.soundEnabled,
      sound: _notificationPreference.soundEnabled ? 'default' : null,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.show(
        message.hashCode,
        notification.title ?? 'Thông báo',
        notification.body ?? '',
        details,
        payload: payload,
      );

      print(
        '✅ Local notification shown (sound: ${_notificationPreference.soundEnabled}, vibration: ${_notificationPreference.vibrationEnabled})',
      );
    } catch (e) {
      print('⚠️ Failed to show notification: $e');
    }
  }

  Future<void> _setupMessageHandlers() async {
    print('📨 Firebase: Setting up message handlers...');

    // Handle message when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Firebase: Message received (foreground)');
      print('📨 Firebase: messageId: ${message.messageId}');
      print('📨 Firebase: From: ${message.from}');
      print('📨 Firebase: Title: ${message.notification?.title}');
      print('📨 Firebase: Body: ${message.notification?.body}');
      print('📨 Firebase: Data: ${message.data}');
      print('📨 Firebase: Category: ${message.category}');
      print('📨 Firebase: CollapseKey: ${message.collapseKey}');

      // ✅ Show local notification when app is in foreground
      _showLocalNotification(message);

      _handleMessage(message);
    });

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📨 Firebase: Message opened app');
      print('📨 Firebase: messageId: ${message.messageId}');
      print('📨 Firebase: Title: ${message.notification?.title}');
      print('📨 Firebase: Body: ${message.notification?.body}');
      print('📨 Firebase: Data: ${message.data}');

      _handleMessage(message);
    });

    // Check if app was opened from a notification (when app was terminated)
    // Note: We don't auto-navigate here - user needs to tap the notification
    // from the notification shade to trigger navigation
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print('📨 Firebase: App opened from notification (terminated state)');
      print('📨 Firebase: messageId: ${initialMessage.messageId}');
      // Don't call _handleMessage() here - let user tap notification instead
    }

    print('✅ Firebase: Message handlers setup complete');
  }

  void _handleMessage(RemoteMessage message) {
    // Process notification data and navigate if needed
    print('📨 Handling message with data: ${message.data}');

    // Navigate to notification detail if we have the required data
    final String? id = message.data['id'];
    final String? dataTime = message.data['dataTime'];
    final String? type = message.data['type'];

    if (id != null && dataTime != null) {
      print('🧭 Navigating to notification detail from background/terminated state');
      print('🧭 Type: $type, ID: $id, DataTime: $dataTime');

      // Use a slight delay to ensure navigation is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        main_app.navigatorKey.currentState?.pushNamed(
          AppRoutes.notificationDetail,
          arguments: {'id': id, 'dataTime': dataTime},
        );
      });
    }

    // Additional handling based on type
    if (message.data.containsKey('type')) {
      switch (message.data['type']) {
        case 'vision_alert':
          print('🤖 Handling vision alert notification');
          break;
        case 'temperature_alert':
          print('🌡️ Handling temperature alert notification');
          break;
        default:
          print('📨 Handling generic notification');
      }
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await messaging.subscribeToTopic(topic);
      print('✅ Firebase: Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Firebase: Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await messaging.unsubscribeFromTopic(topic);
      print('✅ Firebase: Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Firebase: Error unsubscribing from topic $topic: $e');
    }
  }

  /// Cập nhật thông tin user hiện tại và đăng ký lại FCM token
  Future<void> updateCurrentUser(User user) async {
    print('👤 Firebase: Updating current user to ${user.username} (ID: ${user.id})');
    _currentUser = user;

    // Re-register FCM token with new user
    if (_fcmToken != null) {
      await _sendTokenToServer();
    }
  }

  /// Hủy đăng ký FCM token khi logout
  /// Note: Server không có API delete token, chỉ clear local
  Future<void> unregisterToken() async {
    if (_fcmToken == null) {
      print('⚠️ Firebase: No FCM token to unregister');
      return;
    }

    try {
      print('🧹 Firebase: Clearing FCM token from local storage...');

      // Server không có API delete token
      // Token sẽ tự động invalid khi user logout hoặc server tự clean up

      // Clear local FCM token
      await _authPreference.clearFcmToken();
      print('✅ Firebase: FCM token cleared from local storage');

      // Clear current user
      _currentUser = null;
      print('✅ Firebase: Current user cleared');
    } catch (e) {
      print('❌ Firebase: Error clearing FCM token: $e');
      // Still clear current user even if clear token fails
      _currentUser = null;
    }
  }

  /// Đăng ký lại FCM token cho user mới (sau khi login)
  Future<void> registerTokenForNewUser(User user) async {
    print('🔄 Firebase: Registering token for new user ${user.username}');
    await updateCurrentUser(user);
  }

  /// Xóa thông tin user hiện tại (khi logout)
  void clearCurrentUser() {
    print('🧹 Firebase: Clearing current user');
    _currentUser = null;
  }
}
