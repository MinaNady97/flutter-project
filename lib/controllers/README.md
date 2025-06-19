# Controllers Documentation

## HomeController

The `HomeController` is responsible for managing family data and member information from the backend API.

### Features

- Fetches family data from the backend API
- Stores and manages the family ID, family name, and family members
- Provides reactive state management using GetX
- Handles loading states and error messages

### API Endpoint

- **Base URL**: `https://flutter-backend-dcqs.onrender.com`
- **Endpoint**: `/api/families/user/6853d924d7c3a3fb9db9bc0c/members`
- **Method**: GET

### Response Structure

```json
{
  "family_id": "683690d4d7c1d4392ad3b7e3",
  "family_name": "Test Family",
  "members": [
    {
      "email": "tz",
      "name": "Test User",
      "phone": "tz",
      "user_id": "6853d924d7c3a3fb9db9bc0c"
    }
  ],
  "success": true
}
```

### Usage

#### 1. Initialize the Controller

```dart
final HomeController homeController = Get.put(HomeController());
```

#### 2. Access Family Data

```dart
// Family ID
String familyId = homeController.getFamilyId();
String familyId = FamilyUtils.getCurrentFamilyId();

// Family Name
String familyName = homeController.getFamilyName();
String familyName = FamilyUtils.getCurrentFamilyName();

// Family Members
List<Map<String, dynamic>> members = homeController.getFamilyMembers();
List<Map<String, dynamic>> members = FamilyUtils.getCurrentFamilyMembers();

// Get specific member by user ID
Map<String, dynamic>? member = homeController.getMemberById("6853d924d7c3a3fb9db9bc0c");
Map<String, dynamic>? member = FamilyUtils.getFamilyMemberById("6853d924d7c3a3fb9db9bc0c");
```

#### 3. Reactive Access in UI

```dart
// Family ID
Obx(() => Text(homeController.familyId.value))

// Family Name
Obx(() => Text(homeController.familyName.value))

// Family Members
Obx(() => ListView.builder(
  itemCount: homeController.familyMembers.length,
  itemBuilder: (context, index) {
    final member = homeController.familyMembers[index];
    return ListTile(
      title: Text(member['name']),
      subtitle: Text(member['email']),
    );
  },
))
```

#### 4. Check Loading State

```dart
Obx(() {
  if (homeController.isLoading.value) {
    return CircularProgressIndicator();
  }
  return Text('Data loaded');
})
```

#### 5. Handle Errors

```dart
Obx(() {
  if (homeController.errorMessage.value.isNotEmpty) {
    return Text('Error: ${homeController.errorMessage.value}');
  }
  return Container();
})
```

#### 6. Refresh Data

```dart
// Refresh manually
await homeController.refreshUserData();

// Using utility class
await FamilyUtils.refreshFamilyData();
```

#### 7. Check Data Availability

```dart
// Check if family ID exists
bool hasId = FamilyUtils.hasFamilyId();

// Check if family name exists
bool hasName = FamilyUtils.hasFamilyName();

// Check if family members exist
bool hasMembers = FamilyUtils.hasFamilyMembers();
```

### Available Properties

- `familyId` (RxString): The family ID from the API response
- `familyName` (RxString): The family name from the API response
- `familyMembers` (RxList): The list of family members from the API response
- `isLoading` (RxBool): Loading state indicator
- `errorMessage` (RxString): Error message if API call fails

### Available Methods

- `fetchUserData()`: Fetches family data from the API
- `getFamilyId()`: Returns the current family ID
- `getFamilyName()`: Returns the current family name
- `getFamilyMembers()`: Returns the current family members list
- `getMemberById(String userId)`: Returns a specific member by user ID
- `refreshUserData()`: Refreshes the family data

### Integration with Other Controllers

The HomeController is automatically initialized when the HomePage is loaded and can be accessed from anywhere in the app using:

```dart
final HomeController homeController = Get.find<HomeController>();
```

### Constants

The base URL is stored in `lib/core/constants/routes.dart` as `AppRoute.baseUrl` for easy access throughout the project. 