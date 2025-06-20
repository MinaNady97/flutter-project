import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:hci_flutter/controllers/home_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import '../models/emergency_alert.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../core/constants/routes.dart';
import 'dart:convert';

class EmergencyController extends GetxController {
  final RxList<EmergencyAlert> activeAlerts = <EmergencyAlert>[].obs;
  final RxBool isSendingAlert = false.obs;
  final RxBool isLocationEnabled = false.obs;
  final RxString currentLocation = ''.obs;
  final RxDouble currentLatitude = 0.0.obs;
  final RxDouble currentLongitude = 0.0.obs;
  // Add inside your EmergencyController class
  var isSendingSos = false.obs;

  final mapController = MapController(); // ADD THIS

  // Add for family alerts
  final RxList<EmergencyAlert> familyAlerts = <EmergencyAlert>[].obs;
  final Rx<LatLng?> selectedAlertLocation = Rx<LatLng?>(null);

  final homeController = Get.find<HomeController>();

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

  Future<void> updateCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLocationEnabled.value = false;
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        isLocationEnabled.value = false;
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;
      currentLocation.value = '${position.latitude}, ${position.longitude}';
      isLocationEnabled.value = true;

      // Move map to current location
      mapController.move(
        LatLng(currentLatitude.value, currentLongitude.value),
        13.0, // desired zoom level
      );
    } catch (e) {
      print('Error getting real location: $e');
      isLocationEnabled.value = false;
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
      await updateCurrentLocation();

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
      fetchFamilyAlerts(homeController.familyId.value);

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

  // Fetch family alerts from API
  Future<void> fetchFamilyAlerts(String familyId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppRoute.baseUrl}/api/emergency/family/$familyId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        print("alerts: ${response.body}");
        final List<dynamic> alertsJson = body['alerts'] ?? [];
        familyAlerts.value = alertsJson.map((json) {
          final coords = json['location']['coordinates'] as List<dynamic>;
          return EmergencyAlert(
            id: json['_id']['\$oid'] ?? '',
            senderId: json['user_id']['\$oid'] ?? '',
            senderName: '', // Not provided
            type:
                EmergencyType.other, // You may want to parse this if available
            message: json['message'] ?? '',
            timestamp: DateTime.parse(json['timestamp']['\$date']),
            latitude: coords[1] ?? 0.0,
            longitude: coords[0] ?? 0.0,
            location: '', // Not provided
            additionalInfo: {},
            status: _parseStatus(json['status']),
            acknowledgedBy: [],
          );
        }).toList();
      } else {
        Get.snackbar('Error', 'Failed to fetch family alerts');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch family alerts: $e');
    }
  }

  // Helper to parse status
  AlertStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return AlertStatus.active;
      case 'acknowledged':
        return AlertStatus.acknowledged;
      case 'resolved':
        return AlertStatus.resolved;
      default:
        return AlertStatus.active;
    }
  }

  // Resolve alert via API
  Future<void> resolveAlertApi(String alertId) async {
    try {
      final response = await http.put(
        Uri.parse('${AppRoute.baseUrl}/api/emergency/resolve/$alertId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Alert resolved');
        // Optionally refresh alerts
      } else {
        Get.snackbar('Error', 'Failed to resolve alert');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to resolve alert: $e');
    }
  }

  // Center map on alert location
  void centerMapOnAlert(double lat, double lng) {
    mapController.move(LatLng(lat, lng), 15.0);
    selectedAlertLocation.value = LatLng(lat, lng);
  }

  // Center map on user location
  void centerMapOnUser() {
    mapController.move(
        LatLng(currentLatitude.value, currentLongitude.value), 13.0);
    selectedAlertLocation.value = null;
  }
}
