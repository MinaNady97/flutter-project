import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hci_flutter/core/constants/routes.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/emergency_controller.dart';
import '../../models/emergency_alert.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../controllers/home_controller.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmergencyController());

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEmergencyTypes(controller),
                    const SizedBox(height: 24),
                    _buildActiveAlerts(controller),
                    const SizedBox(height: 24),
                    _buildLocationMap(controller),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70.0, right: 70.0),
          child: FloatingActionButton(
            heroTag: '_sendSosNotification',
            onPressed: () => _sendSosNotification(context),
            backgroundColor: Colors.black,
            child: const Icon(Icons.sos),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Emergency Alert',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quick access to emergency services and family notifications',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTypes(EmergencyController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Types',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildEmergencyTypeCard(
              EmergencyType.medical,
              'Medical Emergency',
              Icons.medical_services,
              Colors.blue,
              controller,
            ),
            _buildEmergencyTypeCard(
              EmergencyType.fire,
              'Fire Emergency',
              Icons.local_fire_department,
              Colors.orange,
              controller,
            ),
            _buildEmergencyTypeCard(
              EmergencyType.security,
              'Security Alert',
              Icons.security,
              Colors.purple,
              controller,
            ),
            _buildEmergencyTypeCard(
              EmergencyType.other,
              'Other Emergency',
              Icons.warning,
              Colors.red,
              controller,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyTypeCard(
    EmergencyType type,
    String title,
    IconData icon,
    Color color,
    EmergencyController controller,
  ) {
    return InkWell(
      onTap: () =>
          _showEmergencyDialog(Get.context!, controller, initialType: type),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAlerts(EmergencyController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Alerts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final activeAlerts = controller.getActiveAlerts();
          if (activeAlerts.isEmpty) {
            return const Center(child: Text('No active alerts'));
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeAlerts.length,
            itemBuilder: (context, index) {
              final alert = activeAlerts[index];
              return _buildAlertCard(alert, controller);
            },
          );
        }),
      ],
    );
  }

  Widget _buildAlertCard(EmergencyAlert alert, EmergencyController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForEmergencyType(alert.type),
                  color: _getColorForEmergencyType(alert.type),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.message,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${alert.location}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${_formatDateTime(alert.timestamp)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => controller.acknowledgeAlert(
                    alert.id,
                    'current_user_id',
                  ),
                  child: const Text('Acknowledge'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => controller.resolveAlert(alert.id),
                  child: const Text('Resolve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMap(EmergencyController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Location',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (!controller.isLocationEnabled.value) {
            return const Center(child: Text('Location services are disabled'));
          }
          return Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(
                    controller.currentLatitude.value,
                    controller.currentLongitude.value,
                  ),
                  zoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.hci_flutter',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          controller.currentLatitude.value,
                          controller.currentLongitude.value,
                        ),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showEmergencyDialog(
    BuildContext context,
    EmergencyController controller, {
    EmergencyType? initialType,
  }) {
    final messageController = TextEditingController();
    var selectedType = initialType ?? EmergencyType.other;

    Get.dialog(
      AlertDialog(
        title: const Text('Send Emergency Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<EmergencyType>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Emergency Type',
                border: OutlineInputBorder(),
              ),
              items: EmergencyType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getEmergencyTypeName(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedType = value;
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Emergency Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                controller.sendEmergencyAlert(
                  type: selectedType,
                  message: messageController.text,
                );
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForEmergencyType(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return Icons.medical_services;
      case EmergencyType.fire:
        return Icons.local_fire_department;
      case EmergencyType.security:
        return Icons.security;
      case EmergencyType.other:
        return Icons.warning;
    }
  }

  Color _getColorForEmergencyType(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return Colors.blue;
      case EmergencyType.fire:
        return Colors.orange;
      case EmergencyType.security:
        return Colors.purple;
      case EmergencyType.other:
        return Colors.red;
    }
  }

  String _getEmergencyTypeName(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return 'Medical Emergency';
      case EmergencyType.fire:
        return 'Fire Emergency';
      case EmergencyType.security:
        return 'Security Alert';
      case EmergencyType.other:
        return 'Other Emergency';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _sendSosNotification(BuildContext context) async {
    final homeController = Get.find<HomeController>();
    final emergencyController = Get.find<EmergencyController>();
    await emergencyController.updateCurrentLocation();

    final userId =
        homeController.userId; // Replace with actual user ID if available
    final familyId = homeController.getFamilyId();
    final lat = emergencyController.currentLatitude.value;
    final lng = emergencyController.currentLongitude.value;

    final payload = {
      "user_id": userId,
      "family_id": familyId,
      "location": {
        "type": "Point",
        "coordinates": [lng, lat], // [longitude, latitude]
      },
    };

    try {
      final response = await http.post(
        Uri.parse('${AppRoute.baseUrl}/api/emergency'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'SOS notification sent!');
      } else {
        Get.snackbar('Error', 'Failed to send SOS: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send SOS: $e');
    }
  }
}
