import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  HomeController? _homeController;

  final RxString fcmToken = ''.obs;
  final RxBool isSubscribed = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  @override
  void onReady() {
    super.onReady();
    // Try to get HomeController when service is ready
    try {
      _homeController = Get.find<HomeController>();
    } catch (e) {
      print('HomeController not available yet in NotificationService: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      // Request permission for notifications
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission for notifications');

        // Get FCM token
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          fcmToken.value = token;
          print('FCM Token: $token');
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          fcmToken.value = newToken;
          print('FCM Token refreshed: $newToken');
          _subscribeToFamilyTopic();
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

        // Handle when app is opened from notification
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        // Subscribe to family topic when family ID is available
        _subscribeToFamilyTopic();
      } else {
        print('User declined or has not accepted permission for notifications');
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _subscribeToFamilyTopic() async {
    try {
      // Try to get HomeController if not available
      if (_homeController == null) {
        try {
          _homeController = Get.find<HomeController>();
        } catch (e) {
          print('HomeController not available for topic subscription: $e');
          return;
        }
      }

      String familyId = _homeController!.getFamilyId();
      if (familyId.isNotEmpty && !isSubscribed.value) {
        await _firebaseMessaging.subscribeToTopic('family_$familyId');
        isSubscribed.value = true;
        print('Subscribed to topic: family_$familyId');
      }
    } catch (e) {
      print('Error subscribing to family topic: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');

      // Show local notification
      _showLocalNotification(message);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    print('Message data: ${message.data}');

    // Handle navigation based on message data
    _handleNotificationNavigation(message.data);
  }

  void _showLocalNotification(RemoteMessage message) {
    // You can use flutter_local_notifications package for better local notifications
    // For now, we'll just show a snackbar
    Get.snackbar(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Handle navigation based on notification data
    if (data['screen'] != null) {
      switch (data['screen']) {
        case 'emergency':
          Get.toNamed('/emergency');
          break;
        case 'calendar':
          Get.toNamed('/calendar');
          break;
        case 'workout':
          Get.toNamed('/workout');
          break;
        default:
          break;
      }
    }
  }

  // Method to manually subscribe to family topic
  Future<void> subscribeToFamilyTopic() async {
    await _subscribeToFamilyTopic();
  }

  // Method to unsubscribe from family topic
  Future<void> unsubscribeFromFamilyTopic() async {
    try {
      // Try to get HomeController if not available
      if (_homeController == null) {
        try {
          _homeController = Get.find<HomeController>();
        } catch (e) {
          print('HomeController not available for unsubscription: $e');
          return;
        }
      }

      String familyId = _homeController!.getFamilyId();
      if (familyId.isNotEmpty) {
        await _firebaseMessaging.unsubscribeFromTopic('family_$familyId');
        isSubscribed.value = false;
        print('Unsubscribed from topic: family_$familyId');
      }
    } catch (e) {
      print('Error unsubscribing from family topic: $e');
    }
  }

  // Method to send notification to family (for testing)
  Future<void> sendNotificationToFamily({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This would typically be done from your backend
    // For now, we'll just print the information

    // Try to get HomeController if not available
    if (_homeController == null) {
      try {
        _homeController = Get.find<HomeController>();
      } catch (e) {
        print('HomeController not available for sending notification: $e');
        return;
      }
    }

    String familyId = _homeController!.getFamilyId();
    print('Would send notification to family_$familyId:');
    print('Title: $title');
    print('Body: $body');
    print('Data: $data');
  }
}

// This needs to be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
}
 