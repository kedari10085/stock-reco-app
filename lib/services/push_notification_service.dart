import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Initialize push notifications
  static Future<void> initialize() async {
    try {
      debugPrint('🔔 Initializing Push Notification Service...');
      
      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      debugPrint('🔔 Permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Initialize local notifications
        await _initializeLocalNotifications();
        
        // Get FCM token
        String? token = await _firebaseMessaging.getToken();
        debugPrint('🔔 FCM Token: $token');
        
        // Configure message handlers
        _configureMessageHandlers();
        
        debugPrint('✅ Push Notification Service initialized successfully');
      } else {
        debugPrint('⚠️ Notification permission denied');
      }
    } catch (e) {
      debugPrint('❌ Error initializing push notifications: $e');
    }
  }
  
  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'stock_reco_channel',
      'Stock Recommendations',
      description: 'Notifications for stock recommendations and market updates',
      importance: Importance.high,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  // Configure Firebase message handlers
  static void _configureMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });
    
    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Background message tapped: ${message.notification?.title}');
      _handleNotificationTap(message.data);
    });
    
    // Handle app launch from terminated state
    _handleAppLaunchFromNotification();
  }
  
  // Show local notification when app is in foreground
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'stock_reco_channel',
      'Stock Recommendations',
      channelDescription: 'Notifications for stock recommendations and market updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Stock Reco',
      message.notification?.body ?? 'New update available',
      details,
      payload: message.data.toString(),
    );
  }
  
  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Local notification tapped: ${response.payload}');
    
    // Parse payload and navigate
    if (response.payload != null) {
      try {
        // Simple parsing - in production, use proper JSON parsing
        final data = <String, dynamic>{};
        if (response.payload!.contains('type')) {
          // Extract notification type and navigate accordingly
          _navigateToNotificationScreen(data);
        }
      } catch (e) {
        debugPrint('❌ Error parsing notification payload: $e');
      }
    }
    
    // Default navigation to notifications screen
    _navigateToNotificationScreen({});
  }
  
  // Handle app launch from terminated state
  static Future<void> _handleAppLaunchFromNotification() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    
    if (initialMessage != null) {
      debugPrint('🔔 App launched from notification: ${initialMessage.notification?.title}');
      
      // Wait for app to be ready, then navigate
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage.data);
      });
    }
  }
  
  // Handle notification tap and navigate
  static void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('🔔 Handling notification tap with data: $data');
    
    // Navigate based on notification type
    final notificationType = data['type'] ?? 'general';
    
    switch (notificationType) {
      case 'recommendation':
        _navigateToRecommendations();
        break;
      case 'newsletter':
        _navigateToDashboard();
        break;
      case 'performance':
        _navigateToPerformance();
        break;
      default:
        _navigateToNotificationScreen(data);
    }
  }
  
  // Navigation methods
  static void _navigateToNotificationScreen(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamed('/notifications', arguments: data);
    }
  }
  
  static void _navigateToRecommendations() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Navigate to recommendations tab
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      // You can add logic to switch to recommendations tab
    }
  }
  
  static void _navigateToDashboard() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }
  
  static void _navigateToPerformance() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Navigate to performance tab
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }
  
  // Send local notification (for testing)
  static Future<void> sendTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'stock_reco_channel',
      'Stock Recommendations',
      channelDescription: 'Test notification',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Test Notification',
      'This is a test notification from Stock Reco',
      details,
    );
  }
  
  // Get FCM token for backend integration
  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }
  
  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic $topic: $e');
    }
  }
  
  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic $topic: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background message received: ${message.notification?.title}');
  // Handle background message processing here
}
