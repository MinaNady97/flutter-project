import 'package:get/get.dart';
import '../services/notification_service.dart';

class NotificationUtils {
  /// Get the notification service instance
  static NotificationService? getNotificationService() {
    try {
      return Get.find<NotificationService>();
    } catch (e) {
      print('NotificationService not found: $e');
      return null;
    }
  }

  /// Get the current FCM token
  static String getFcmToken() {
    final NotificationService? service = getNotificationService();
    return service?.fcmToken.value ?? '';
  }

  /// Check if user is subscribed to family notifications
  static bool isSubscribedToFamily() {
    final NotificationService? service = getNotificationService();
    return service?.isSubscribed.value ?? false;
  }

  /// Subscribe to family topic
  static Future<void> subscribeToFamilyTopic() async {
    final NotificationService? service = getNotificationService();
    if (service != null) {
      await service.subscribeToFamilyTopic();
    } else {
      print('Cannot subscribe: NotificationService not available');
    }
  }

  /// Unsubscribe from family topic
  static Future<void> unsubscribeFromFamilyTopic() async {
    final NotificationService? service = getNotificationService();
    if (service != null) {
      await service.unsubscribeFromFamilyTopic();
    } else {
      print('Cannot unsubscribe: NotificationService not available');
    }
  }

  /// Send a test notification to family
  static Future<void> sendTestNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final NotificationService? service = getNotificationService();
    if (service != null) {
      await service.sendNotificationToFamily(
        title: title,
        body: body,
        data: data,
      );
    } else {
      print('Cannot send notification: NotificationService not available');
    }
  }

  /// Check if notifications are enabled
  static bool areNotificationsEnabled() {
    final NotificationService? service = getNotificationService();
    return service?.fcmToken.value.isNotEmpty ?? false;
  }

  /// Get notification status as a string
  static String getNotificationStatus() {
    final NotificationService? service = getNotificationService();
    if (service == null) {
      return 'Notification service not available';
    }

    if (service.fcmToken.value.isEmpty) {
      return 'Notifications not enabled';
    } else if (service.isSubscribed.value) {
      return 'Subscribed to family notifications';
    } else {
      return 'Not subscribed to family notifications';
    }
  }
}
