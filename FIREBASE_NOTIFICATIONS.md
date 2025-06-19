# Firebase Notifications Setup

This document explains how Firebase notifications are implemented in the HCI Flutter app using family ID as topics.

## Overview

The app uses Firebase Cloud Messaging (FCM) to send push notifications to family members. Each family is assigned a unique topic based on their family ID, allowing all family members to receive notifications sent to that topic.

## Architecture

### Components

1. **NotificationService** (`lib/core/services/notification_service.dart`)
   - Handles Firebase messaging initialization
   - Manages topic subscriptions
   - Processes incoming notifications
   - Handles foreground and background messages

2. **HomeController** (`lib/controllers/home_controller.dart`)
   - Integrates with NotificationService
   - Automatically subscribes to family topic when family data is loaded
   - Provides methods to send test notifications

3. **NotificationUtils** (`lib/core/funcs/notification_utils.dart`)
   - Utility class for easy access to notification functionality
   - Provides helper methods for common notification operations

4. **NotificationSettingsScreen** (`lib/views/screens/notification_settings_screen.dart`)
   - UI for managing notification settings
   - Shows notification status and family information
   - Provides buttons to test notifications

## Setup

### 1. Firebase Configuration

The project is already configured with Firebase. The configuration files are:
- `firebase.json` - Firebase project configuration
- `lib/firebase_options.dart` - Firebase options for different platforms
- `android/app/google-services.json` - Android-specific configuration

### 2. Dependencies

The following dependencies are required:
```yaml
dependencies:
  firebase_core: ^3.14.0
  firebase_messaging: ^15.1.3
```

### 3. Initialization

Firebase is initialized in `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notification service
  Get.put(NotificationService());
  
  runApp(const MainApp());
}
```

## How It Works

### 1. Topic Subscription

When the app loads and family data is fetched:
1. The `HomeController` fetches family data from the API
2. Once the family ID is available, it calls `_subscribeToFamilyNotifications()`
3. The `NotificationService` subscribes to the topic `family_{familyId}`
4. All family members with the same family ID will receive notifications sent to this topic

### 2. Notification Handling

#### Foreground Messages
- When the app is open, notifications are handled by `_handleForegroundMessage()`
- Shows a snackbar with the notification content
- Can trigger navigation based on notification data

#### Background Messages
- When the app is closed, notifications are handled by `_firebaseMessagingBackgroundHandler()`
- Logs the message data for debugging

#### App Opened from Notification
- When user taps a notification, `_handleMessageOpenedApp()` is called
- Can navigate to specific screens based on notification data

### 3. Topic Format

Topics follow the format: `family_{familyId}`

Example:
- Family ID: `683690d4d7c1d4392ad3b7e3`
- Topic: `family_683690d4d7c1d4392ad3b7e3`

## Usage

### Sending Notifications

To send a notification to a family, you need to send it to the family topic from your backend:

```json
{
  "to": "/topics/family_683690d4d7c1d4392ad3b7e3",
  "notification": {
    "title": "Family Alert",
    "body": "Someone in your family needs attention"
  },
  "data": {
    "screen": "emergency",
    "family_id": "683690d4d7c1d4392ad3b7e3"
  }
}
```

### Testing Notifications

You can test notifications using the Notification Settings screen:
1. Navigate to the notification settings (blue notification button on home screen)
2. Click "Send Test Notification" to send a test notification to your family topic

### Programmatic Usage

```dart
// Subscribe to family topic
await NotificationUtils.subscribeToFamilyTopic();

// Unsubscribe from family topic
await NotificationUtils.unsubscribeFromFamilyTopic();

// Send test notification
await NotificationUtils.sendTestNotification(
  title: 'Test Title',
  body: 'Test Body',
  data: {'screen': 'home'},
);

// Check notification status
String status = NotificationUtils.getNotificationStatus();
```

## Notification Data Structure

### Standard Notification Payload
```json
{
  "notification": {
    "title": "Notification Title",
    "body": "Notification Body"
  },
  "data": {
    "screen": "target_screen",
    "family_id": "family_id",
    "user_id": "user_id",
    "action": "action_type"
  }
}
```

### Supported Screen Values
- `"emergency"` - Navigate to emergency screen
- `"calendar"` - Navigate to calendar screen
- `"workout"` - Navigate to workout screen
- `"home"` - Navigate to home screen

## Permissions

The app requests the following notification permissions:
- Alert notifications
- Badge notifications
- Sound notifications

## Platform-Specific Setup

### Android
- Uses `google-services.json` for configuration
- Requires internet permission
- Handles background messages automatically

### iOS
- Uses `GoogleService-Info.plist` for configuration
- Requires additional setup in Xcode for background notifications
- May require additional permissions in Info.plist

## Troubleshooting

### Common Issues

1. **Notifications not received**
   - Check if user granted notification permissions
   - Verify FCM token is generated
   - Ensure subscription to family topic is successful

2. **Topic subscription fails**
   - Check if family ID is available
   - Verify internet connection
   - Check Firebase console for any errors

3. **Background notifications not working**
   - Ensure proper Firebase configuration
   - Check platform-specific setup
   - Verify notification payload format

### Debug Information

The app logs important information to help with debugging:
- FCM token generation
- Topic subscription status
- Notification reception
- Error messages

Check the console output for these logs when testing notifications.

## Security Considerations

1. **Topic Security**: Only family members should be able to subscribe to their family topic
2. **Data Validation**: Validate notification data before processing
3. **User Consent**: Always request user permission before enabling notifications
4. **Token Management**: Handle FCM token refresh properly

## Future Enhancements

1. **Local Notifications**: Add flutter_local_notifications for better local notification handling
2. **Notification Categories**: Support different types of notifications (emergency, reminder, etc.)
3. **Notification History**: Store and display notification history
4. **Custom Sounds**: Support custom notification sounds
5. **Rich Notifications**: Support images and actions in notifications 