import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/funcs/notification_utils.dart';
import '../../core/funcs/family_utils.dart';
import '../../core/constants/routes.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: AppRoute.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Family Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Family Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Obx(() =>
                        Text('Family ID: ${FamilyUtils.getCurrentFamilyId()}')),
                    Obx(() => Text(
                        'Family Name: ${FamilyUtils.getCurrentFamilyName()}')),
                    Obx(() => Text(
                        'Members: ${FamilyUtils.getCurrentFamilyMembers().length}')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notification Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(NotificationUtils.getNotificationStatus())),
                    const SizedBox(height: 8),
                    Obx(() {
                      final service =
                          NotificationUtils.getNotificationService();
                      if (service == null) {
                        return const Text('FCM Token: Service not available');
                      }
                      final token = service.fcmToken.value;
                      if (token.isEmpty) {
                        return const Text('FCM Token: Not available');
                      }
                      return Text('FCM Token: ${token.substring(0, 50)}...');
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notification Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Subscribe Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await NotificationUtils.subscribeToFamilyTopic();
                          Get.snackbar(
                            'Success',
                            'Subscribed to family notifications',
                            snackPosition: SnackPosition.TOP,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppRoute.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Subscribe to Family Notifications'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Unsubscribe Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await NotificationUtils.unsubscribeFromFamilyTopic();
                          Get.snackbar(
                            'Success',
                            'Unsubscribed from family notifications',
                            snackPosition: SnackPosition.TOP,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            const Text('Unsubscribe from Family Notifications'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Test Notification Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await NotificationUtils.sendTestNotification(
                            title: 'Test Notification',
                            body:
                                'This is a test notification from ${FamilyUtils.getCurrentFamilyName()}',
                            data: {
                              'screen': 'notification_settings',
                              'family_id': FamilyUtils.getCurrentFamilyId(),
                            },
                          );
                          Get.snackbar(
                            'Test Notification',
                            'Test notification sent to family topic',
                            snackPosition: SnackPosition.TOP,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Send Test Notification'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Family Members List
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Members',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Obx(() {
                          final members = FamilyUtils.getCurrentFamilyMembers();
                          if (members.isEmpty) {
                            return const Center(
                              child: Text('No family members found'),
                            );
                          }
                          return ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return ListTile(
                                title: Text(member['name'] ?? 'Unknown'),
                                subtitle: Text(member['email'] ?? 'No email'),
                                trailing: Text(member['phone'] ?? 'No phone'),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
