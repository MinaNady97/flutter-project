# Firebase Cloud Messaging Setup Guide

This guide explains how to send Firebase notifications directly from your Flutter app without a backend server.

## 🎯 Overview

You can now send push notifications directly from your Flutter app using Firebase Cloud Messaging (FCM) HTTP API. This eliminates the need for a backend server for basic notification functionality.

## 🔧 Setup Steps

### 1. Get Firebase Server Key

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `hciproject-68016`
3. **Go to Project Settings**: Click the gear icon next to "Project Overview"
4. **Navigate to Cloud Messaging tab**
5. **Copy the Server key**: This is a long string that starts with `AAAA...`

### 2. Update the Server Key

Open `lib/core/services/fcm_sender_service.dart` and replace the placeholder:

```dart
final String _serverKey = 'YOUR_FIREBASE_SERVER_KEY_HERE';
```

With your actual server key:

```dart
final String _serverKey = 'AAAA...your_actual_server_key_here...';
```

### 3. Security Considerations

⚠️ **Important**: The server key should be kept secure. In a production app, you should:

1. **Store it securely**: Use environment variables or secure storage
2. **Restrict API access**: Configure Firebase Console to restrict API usage
3. **Monitor usage**: Check Firebase Console for API usage statistics

## 🚀 How It Works

### Architecture

1. **FCMSenderService**: Handles HTTP requests to FCM API
2. **NotificationService**: Manages FCM token and topic subscriptions
3. **FCMUtils**: Provides easy-to-use utility methods
4. **Family-based Topics**: Each family gets a unique topic (`family_{familyId}`)

### Notification Flow

1. **App subscribes to family topic** when family data loads
2. **User sends notification** via the app
3. **FCM API receives request** with family topic
4. **All family members receive notification** who are subscribed to that topic

## 📱 Usage Examples

### Basic Usage

```dart
// Send simple notification to family
bool success = await FCMUtils.sendToFamily(
  title: 'Hello Family!',
  body: 'This is a test notification',
  data: {'screen': 'home'},
);
```

### Emergency Notifications

```dart
// Send emergency notification
bool success = await FCMUtils.sendEmergencyNotification(
  message: 'Need immediate assistance!',
  location: '123 Main St, City',
);
```

### Workout Notifications

```dart
// Send workout update
bool success = await FCMUtils.sendWorkoutNotification(
  message: 'Just completed 30 minutes of cardio!',
  workoutType: 'Cardio',
);
```

### Custom Notifications

```dart
// Send to specific topic
bool success = await FCMUtils.sendToTopic(
  topic: 'family_683690d4d7c1d4392ad3b7e3',
  title: 'Custom Title',
  body: 'Custom message',
  data: {'custom_field': 'custom_value'},
);
```

## 🧪 Testing

### 1. Test in Notification Settings Screen

1. **Open the app**
2. **Tap the blue notification button** on home screen
3. **Grant notification permissions** when prompted
4. **Use the test buttons** to send different types of notifications

### 2. Test with Multiple Devices

1. **Install the app on multiple devices**
2. **Log in with the same family account**
3. **Send a notification from one device**
4. **Verify all devices receive the notification**

### 3. Test Different Scenarios

- ✅ **Foreground notifications**: App is open
- ✅ **Background notifications**: App is minimized
- ✅ **Killed app notifications**: App is completely closed
- ✅ **Topic-based notifications**: Family-specific messages

## 📊 Notification Types

### 1. Emergency Notifications
- **Title**: 🚨 Emergency Alert
- **Priority**: High
- **Sound**: Default
- **Badge**: 1

### 2. Workout Notifications
- **Title**: 💪 Workout Update
- **Priority**: Normal
- **Sound**: Default
- **Badge**: 1

### 3. Reminder Notifications
- **Title**: Custom title
- **Priority**: Normal
- **Sound**: Default
- **Badge**: 1

### 4. Custom Notifications
- **Title**: Custom
- **Priority**: High/Normal
- **Sound**: Default
- **Badge**: 1

## 🔍 Debugging

### Check Console Logs

The app logs important information:

```
Sending notification to topic: family_683690d4d7c1d4392ad3b7e3
Payload: {notification: {title: Test, body: Message}, to: /topics/family_...}
Notification sent successfully!
Response: {message_id: 1234567890}
```

### Common Issues

1. **"Invalid Server Key"**
   - Check if server key is correct
   - Ensure no extra spaces or characters

2. **"Topic not found"**
   - Verify family ID is loaded
   - Check if app is subscribed to topic

3. **"Permission denied"**
   - Check Firebase Console settings
   - Verify API is enabled

4. **"Network error"**
   - Check internet connection
   - Verify FCM API endpoint is accessible

## 📈 Performance Considerations

### Rate Limits

- **FCM API**: 1000 requests per second per project
- **Topic messages**: 1 message per second per topic
- **Device messages**: 1000 messages per second per project

### Best Practices

1. **Batch notifications**: Send multiple messages in one request when possible
2. **Use topics**: More efficient than individual device tokens
3. **Monitor usage**: Check Firebase Console for API usage
4. **Handle errors**: Implement proper error handling and retry logic

## 🔐 Security Best Practices

1. **Server Key Protection**
   - Don't commit server key to version control
   - Use environment variables in production
   - Rotate keys regularly

2. **Topic Security**
   - Validate family membership before subscribing
   - Use unique topic names
   - Monitor topic subscriptions

3. **Data Validation**
   - Validate notification content
   - Sanitize user input
   - Limit notification size

## 🚀 Production Deployment

### 1. Environment Variables

```dart
// Use environment variables for server key
final String _serverKey = const String.fromEnvironment('FCM_SERVER_KEY');
```

### 2. Error Handling

```dart
try {
  bool success = await FCMUtils.sendToFamily(...);
  if (!success) {
    // Handle failure
  }
} catch (e) {
  // Handle exception
}
```

### 3. Monitoring

- Monitor FCM API usage in Firebase Console
- Track notification delivery rates
- Monitor app performance impact

## 📚 Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FCM HTTP API Reference](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages)
- [Flutter Firebase Messaging](https://pub.dev/packages/firebase_messaging)

## 🎉 Success!

You now have a complete Firebase notification system that works without a backend! Your app can:

- ✅ Send notifications to family members
- ✅ Handle different notification types
- ✅ Work in foreground, background, and killed states
- ✅ Use family-based topics for targeted messaging
- ✅ Provide real-time feedback on notification status

The system is ready for testing and production use! 