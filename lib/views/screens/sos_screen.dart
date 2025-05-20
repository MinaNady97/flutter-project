import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/emergency_controller.dart';
import '../../models/emergency_alert.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmergencyController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade900,
              Colors.red.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildQuickActions(controller),
                        const SizedBox(height: 24),
                        _buildEmergencyContacts(),
                        const SizedBox(height: 24),
                        _buildLocationMap(controller),
                        const SizedBox(height: 24),
                        _buildRecentAlerts(controller),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'SOS Emergency',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quick access to emergency services',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(EmergencyController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Medical\nEmergency',
                Icons.medical_services,
                Colors.blue,
                () => _showEmergencyDialog(
                  Get.context!,
                  controller,
                  EmergencyType.medical,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Fire\nEmergency',
                Icons.local_fire_department,
                Colors.orange,
                () => _showEmergencyDialog(
                  Get.context!,
                  controller,
                  EmergencyType.fire,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Security\nAlert',
                Icons.security,
                Colors.purple,
                () => _showEmergencyDialog(
                  Get.context!,
                  controller,
                  EmergencyType.security,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Other\nEmergency',
                Icons.warning,
                Colors.red,
                () => _showEmergencyDialog(
                  Get.context!,
                  controller,
                  EmergencyType.other,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildContactItem(
                'Police',
                '911',
                Icons.local_police,
                Colors.blue,
                () => _launchEmergencyCall('911'),
              ),
              const Divider(color: Colors.white24),
              _buildContactItem(
                'Ambulance',
                '911',
                Icons.medical_services,
                Colors.red,
                () => _launchEmergencyCall('911'),
              ),
              const Divider(color: Colors.white24),
              _buildContactItem(
                'Fire Department',
                '911',
                Icons.local_fire_department,
                Colors.orange,
                () => _launchEmergencyCall('911'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    String name,
    String number,
    IconData icon,
    Color color,
    VoidCallback onCall,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        number,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.phone, color: Colors.white),
        onPressed: onCall,
      ),
    );
  }

  Widget _buildLocationMap(EmergencyController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (!controller.isLocationEnabled.value) {
            return const Center(
              child: Text(
                'Location services are disabled',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
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
                        child:  Icon(
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

  Future<void> _launchEmergencyCall(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch emergency call',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildRecentAlerts(EmergencyController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Alerts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final activeAlerts = controller.getActiveAlerts();
          if (activeAlerts.isEmpty) {
            return const Center(
              child: Text(
                'No active alerts',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeAlerts.length,
            itemBuilder: (context, index) {
              final alert = activeAlerts[index];
              return _buildAlertItem(alert, controller);
            },
          );
        }),
      ],
    );
  }

  Widget _buildAlertItem(EmergencyAlert alert, EmergencyController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              _getColorForEmergencyType(alert.type).withOpacity(0.2),
          child: Icon(
            _getIconForEmergencyType(alert.type),
            color: _getColorForEmergencyType(alert.type),
          ),
        ),
        title: Text(
          alert.message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${alert.location}\n${_formatDateTime(alert.timestamp)}',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          onPressed: () => controller.acknowledgeAlert(
            alert.id,
            'current_user_id',
          ),
        ),
      ),
    );
  }

  void _showEmergencyDialog(
    BuildContext context,
    EmergencyController controller,
    EmergencyType type,
  ) {
    final messageController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(_getEmergencyTypeName(type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                controller.sendEmergencyAlert(
                  type: type,
                  message: messageController.text,
                );
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getColorForEmergencyType(type),
            ),
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
}
