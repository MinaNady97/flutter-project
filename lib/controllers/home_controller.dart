import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/constants/routes.dart';
import '../core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  final RxString userId =
      '6853d924d7c3a3fb9db9bc0c'.obs; // 6853d924d7c3a3fb9db9bc0c
  final RxString username = 'Asma'.obs; //Asma
  final RxString familyId = ''.obs;
  final RxString familyName = ''.obs;
  final RxList<Map<String, dynamic>> familyMembers =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  NotificationService? _notificationService;

  @override
  void onInit() {
    _loadUserPrefs();
    fetchUserData();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    // Try to get notification service, but don't fail if it's not available
    try {
      _notificationService = Get.find<NotificationService>();
    } catch (e) {
      print('NotificationService not available yet: $e');
    }
  }

  Future<void> _loadUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('user_id');
    final savedUsername = prefs.getString('username');
    if (savedUserId != null && savedUserId.isNotEmpty) {
      userId.value = savedUserId;
    }
    if (savedUsername != null && savedUsername.isNotEmpty) {
      username.value = savedUsername;
    }
  }

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('Fetching user data...');
      print('${AppRoute.baseUrl}/api/families/user/$userId/members');
      final response = await http.get(
        Uri.parse('${AppRoute.baseUrl}/api/families/user/$userId/members'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          familyId.value = data['family_id'] ?? '';
          familyName.value = data['family_name'] ?? '';
          familyMembers.value =
              List<Map<String, dynamic>>.from(data['members'] ?? []);

          print('Family data fetched successfully:');
          print('Family ID: ${familyId.value}');
          print('Family Name: ${familyName.value}');
          print('Members count: ${familyMembers.length}');

          // Subscribe to family topic for notifications
          _subscribeToFamilyNotifications();
        } else {
          errorMessage.value = 'API returned success: false';
          print('API returned success: false');
        }
      } else {
        errorMessage.value =
            'Failed to fetch user data. Status: ${response.statusCode}';
        print(
            'Error fetching user data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      errorMessage.value = 'Error connecting to server: $e';
      print('Exception occurred while fetching user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _subscribeToFamilyNotifications() async {
    try {
      if (familyId.value.isNotEmpty) {
        // Wait a bit for notification service to be ready
        await Future.delayed(const Duration(seconds: 2));

        // Try to get notification service if not already available
        if (_notificationService == null) {
          try {
            _notificationService = Get.find<NotificationService>();
          } catch (e) {
            print('NotificationService still not available: $e');
            return;
          }
        }

        // Subscribe to family topic
        await _notificationService!.subscribeToFamilyTopic();
        print(
            'Successfully subscribed to family notifications for family: ${familyId.value}');
      }
    } catch (e) {
      print('Error subscribing to family notifications: $e');
    }
  }

  // Method to get family ID from anywhere in the app
  String getFamilyId() {
    return familyId.value;
  }

  // Method to get family name from anywhere in the app
  String getFamilyName() {
    return familyName.value;
  }

  // Method to get family members from anywhere in the app
  List<Map<String, dynamic>> getFamilyMembers() {
    return familyMembers;
  }

  // Method to get a specific member by user ID
  Map<String, dynamic>? getMemberById(String userId) {
    try {
      return familyMembers.firstWhere((member) => member['user_id'] == userId);
    } catch (e) {
      return null;
    }
  }

  // Method to refresh user data
  Future<void> refreshUserData() async {
    await fetchUserData();
  }

  // Method to send test notification to family
  Future<void> sendTestNotification() async {
    try {
      if (_notificationService == null) {
        try {
          _notificationService = Get.find<NotificationService>();
        } catch (e) {
          print('NotificationService not available for test notification: $e');
          return;
        }
      }

      await _notificationService!.sendNotificationToFamily(
        title: 'Test Notification',
        body: 'This is a test notification from ${familyName.value}',
        data: {
          'screen': 'home',
          'family_id': familyId.value,
        },
      );
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }

  void setUserId(String newId) {
    userId.value = newId;
    _saveUserPrefs();
  }

  void setUsername(String newName) {
    username.value = newName;
    _saveUserPrefs();
  }

  Future<void> _saveUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId.value);
    await prefs.setString('username', username.value);
  }
}
