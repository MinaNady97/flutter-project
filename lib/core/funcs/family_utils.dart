import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class FamilyUtils {
  /// Get the current family ID from the HomeController
  static String getCurrentFamilyId() {
    final HomeController homeController = Get.find<HomeController>();
    return homeController.getFamilyId();
  }

  /// Get the current family name from the HomeController
  static String getCurrentFamilyName() {
    final HomeController homeController = Get.find<HomeController>();
    return homeController.getFamilyName();
  }

  /// Get the current family members from the HomeController
  static List<Map<String, dynamic>> getCurrentFamilyMembers() {
    final HomeController homeController = Get.find<HomeController>();
    return homeController.getFamilyMembers();
  }

  /// Get a specific family member by user ID
  static Map<String, dynamic>? getFamilyMemberById(String userId) {
    final HomeController homeController = Get.find<HomeController>();
    return homeController.getMemberById(userId);
  }

  /// Check if family ID is available
  static bool hasFamilyId() {
    final HomeController homeController = Get.find<HomeController>();
    return homeController.familyId.value.isNotEmpty;
  }

  /// Check if family name is available
  static bool hasFamilyName() {
    final HomeController homeController = Get.find<HomeController>();
    return homeController.familyName.value.isNotEmpty;
  }

  /// Check if family members are available
  static bool hasFamilyMembers() {
    final HomeController homeController = Get.find<HomeController>();
    return homeController.familyMembers.isNotEmpty;
  }

  /// Refresh the family data
  static Future<void> refreshFamilyData() async {
    final HomeController homeController = Get.find<HomeController>();
    await homeController.refreshUserData();
  }

  /// Get the HomeController instance
  static HomeController getHomeController() {
    return Get.find<HomeController>();
  }
}
