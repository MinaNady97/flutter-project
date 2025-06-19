import 'package:get/get.dart';
import 'package:hci_flutter/core/services/notification_service.dart';

class FCMUtils {
  /// Get the FCM sender service instance

  Future<void> sendToFamily(
      {required String title,
      required String body,
      Map<String, dynamic>? data}) async {
    await Get.find<NotificationService>().sendNotificationToFamily(
      title: title,
      body: body,
      data: data,
    );
  }

  /// Send emergency notification to family
  Future<bool> sendEmergencyNotification({
    required String message,
    String? location,
  }) async {
    await sendToFamily(
      title: '🚨 Emergency Alert',
      body: message,
      data: {
        'type': 'emergency',
        'location': location,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    return true;
  }

  /// Send reminder notification to family
  Future<bool> sendReminderNotification({
    required String title,
    required String message,
    String? action,
  }) async {
    await sendToFamily(
      title: title,
      body: message,
      data: {
        'type': 'reminder',
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    return true;
  }

  /// Send workout notification to family
  Future<bool> sendWorkoutNotification({
    required String message,
    String? workoutType,
  }) async {
    await sendToFamily(
      title: '💪 Workout Update',
      body: message,
      data: {
        'type': 'workout',
        'workout_type': workoutType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    return true;
  }
}
