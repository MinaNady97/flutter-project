import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import '../models/emergency_alert.dart';

class EmergencyController extends GetxController {
  final RxList<EmergencyAlert> activeAlerts = <EmergencyAlert>[].obs;
  final RxBool isSendingAlert = false.obs;
  final RxBool isLocationEnabled = false.obs;
  final RxString currentLocation = ''.obs;
  final RxDouble currentLatitude = 0.0.obs;
  final RxDouble currentLongitude = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      var status = await Permission.location.status;
      if (status.isDenied) {
        status = await Permission.location.request();
      }

      if (status.isGranted) {
        isLocationEnabled.value = true;
        // For demo purposes, we'll use a fixed location
        // In a real app, you would use a location package that works well with your setup
        currentLatitude.value = 37.7749; // Example: San Francisco
        currentLongitude.value = -122.4194;
        currentLocation.value = 'San Francisco, CA, USA';
      } else {
        isLocationEnabled.value = false;
      }
    } catch (e) {
      print('Error initializing location: $e');
      isLocationEnabled.value = false;
    }
  }

  Future<void> _updateCurrentLocation() async {
    try {
      // For demo purposes, we'll use a fixed location
      // In a real app, you would use a location package that works well with your setup
      currentLatitude.value = 37.7749; // Example: San Francisco
      currentLongitude.value = -122.4194;
      currentLocation.value = 'San Francisco, CA, USA';
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  Future<void> sendEmergencyAlert({
    required EmergencyType type,
    required String message,
    Map<String, dynamic>? additionalInfo,
  }) async {
    if (!isLocationEnabled.value) {
      Get.snackbar(
        'Error',
        'Location services are disabled. Please enable location services to send emergency alerts.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSendingAlert.value = true;

    try {
      await _updateCurrentLocation();

      final alert = EmergencyAlert(
        id: const Uuid().v4(),
        senderId: 'current_user_id', // TODO: Get actual user ID
        senderName: 'Current User', // TODO: Get actual user name
        type: type,
        message: message,
        timestamp: DateTime.now(),
        latitude: currentLatitude.value,
        longitude: currentLongitude.value,
        location: currentLocation.value,
        additionalInfo: additionalInfo ?? {},
      );

      // TODO: Implement actual notification sending logic
      // For now, just add to local list
      activeAlerts.add(alert);

      Get.snackbar(
        'Success',
        'Emergency alert sent successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send emergency alert: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingAlert.value = false;
    }
  }

  void acknowledgeAlert(String alertId, String userId) {
    final index = activeAlerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      final alert = activeAlerts[index];
      final updatedAcknowledgedBy = List<String>.from(alert.acknowledgedBy)
        ..add(userId);

      activeAlerts[index] = alert.copyWith(
        acknowledgedBy: updatedAcknowledgedBy,
        status: AlertStatus.acknowledged,
      );

      // TODO: Notify other family members about the acknowledgment
    }
  }

  void resolveAlert(String alertId) {
    final index = activeAlerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      final alert = activeAlerts[index];
      activeAlerts[index] = alert.copyWith(
        status: AlertStatus.resolved,
      );

      // TODO: Notify all family members about the resolution
    }
  }

  List<EmergencyAlert> getActiveAlerts() {
    return activeAlerts
        .where((alert) => alert.status == AlertStatus.active)
        .toList();
  }

  List<EmergencyAlert> getAcknowledgedAlerts() {
    return activeAlerts
        .where((alert) => alert.status == AlertStatus.acknowledged)
        .toList();
  }

  List<EmergencyAlert> getResolvedAlerts() {
    return activeAlerts
        .where((alert) => alert.status == AlertStatus.resolved)
        .toList();
  }
}
