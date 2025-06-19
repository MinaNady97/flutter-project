import 'package:device_calendar/device_calendar.dart' as tz;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hci_flutter/controllers/home_controller.dart';
import 'package:hci_flutter/core/constants/routes.dart';
import '../models/event.dart' as myevent;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_calendar/device_calendar.dart' as device_calendar;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarController extends GetxController {
  final RxList<myevent.Event> events = <myevent.Event>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<myevent.Event?> selectedEvent = Rx<myevent.Event?>(null);
  final RxBool isSyncing = false.obs;
  final homeController = Get.find<HomeController>();

  final device_calendar.DeviceCalendarPlugin _deviceCalendarPlugin =
      device_calendar.DeviceCalendarPlugin();

  List<device_calendar.Calendar> _calendars = [];

  final RxBool isAutoSyncEnabled = false.obs;
  SharedPreferences? prefs;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
    fetchFamilyEvents(homeController.userId.value);
    _retrieveCalendars();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    isAutoSyncEnabled.value = prefs?.getBool('autoSync') ?? false;
  }

  Future<void> fetchFamilyEvents(String userId) async {
    try {
      isSyncing.value = true;
      final response = await http.get(
        Uri.parse('${AppRoute.baseUrl}/api/events/user/$userId/family-events'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List eventsJson = data['events'];
          events.value =
              eventsJson.map((e) => myevent.Event.fromApiJson(e)).toList();
          if (isAutoSyncEnabled.value) {
            await syncAllEventsToPhoneCalendar();
          }
          print("Fetched ${events.length} events");
          print(data);
        }
      } else {
        print("Failed to fetch events: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching family events: $e');
      Get.snackbar('Error', 'Failed to fetch events');
    } finally {
      isSyncing.value = false;
    }
  }

  List<myevent.Event> getEventsForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    return events.where((event) {
      final eventDate = DateTime(
          event.startTime.year, event.startTime.month, event.startTime.day);
      return eventDate == dateOnly;
    }).toList();
  }

  Future<void> addEventFromForm(Map<String, dynamic> eventData) async {
    try {
      isSyncing.value = true;

      final sanitizedData = Map<String, dynamic>.from(eventData);
      sanitizedData.forEach((key, value) {
        if (value is RxString) {
          sanitizedData[key] = value.value;
        } else if (value is RxInt) {
          sanitizedData[key] = value.value;
        }
      });

      final response = await http.post(
        Uri.parse('${AppRoute.baseUrl}/api/events/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(sanitizedData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          fetchFamilyEvents(homeController.userId.value);
          final newEvent = myevent.Event.fromApiJson(data['event']);
          events.add(newEvent);
          Get.snackbar('Success', 'Event added successfully');
        }
      }
    } catch (e) {
      fetchFamilyEvents(homeController.userId.value);
      print('Error adding event: $e');
      Get.snackbar('Error', 'Failed to add event');
    } finally {
      fetchFamilyEvents(homeController.userId.value);
      isSyncing.value = false;
    }
  }

  Future<void> joinEvent(String eventId, String userId, String userName) async {
    try {
      isSyncing.value = true;
      final response = await http.post(
        Uri.parse('${AppRoute.baseUrl}/api/events/$eventId/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId,
          "name": userName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Get.snackbar('Success', 'You have joined the event');
          fetchFamilyEvents(userId);
        }
      }
    } catch (e) {
      print('Error joining event: $e');
      Get.snackbar('Error', 'Failed to join event');
    } finally {
      isSyncing.value = false;
    }
  }

  void markEventAsCompleted(String eventId) {
    final index = events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = events[index];
      events[index] = event.copyWith(isCompleted: true);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppRoute.baseUrl}/api/events/$eventId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        events.removeWhere((e) => e.id == eventId);
        update();
        Get.snackbar('Deleted', 'Event has been deleted.');
      } else {
        Get.snackbar('Error', 'Failed to delete event.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while deleting the event.');
    }
  }

  Future<void> _retrieveCalendars() async {
    try {
      // Request both read and write permissions
      var calendarStatus = await Permission.calendar.request();

      if (!calendarStatus.isGranted) {
        Get.snackbar(
          'Permission Required',
          'Calendar permission is required to sync events. Please enable it in settings.',
          duration: const Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings'),
          ),
        );
        return;
      }

      final result = await _deviceCalendarPlugin.retrieveCalendars();
      if (result.isSuccess && (result.data?.isNotEmpty ?? false)) {
        _calendars = result.data!
            .where((calendar) => calendar.isReadOnly == false)
            .toList();

        if (_calendars.isEmpty) {
          Get.snackbar('Error', 'No writable calendars found on device');
          return;
        }
      } else {
        Get.snackbar('Error', 'Failed to retrieve device calendars');
        return;
      }
    } catch (e) {
      print('Error retrieving calendars: $e');
      Get.snackbar('Error', 'Failed to access device calendars');
    }
  }

  Future<void> syncEventToPhoneCalendar(myevent.Event event) async {
    try {
      await _retrieveCalendars();

      if (_calendars.isEmpty)
        return; // Error already shown in _retrieveCalendars

      // If multiple calendars exist, let user choose
      String? calendarId;
      if (_calendars.length > 1) {
        await Get.dialog(
          AlertDialog(
            title: const Text('Select Calendar'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: _calendars
                  .map(
                    (calendar) => ListTile(
                      title: Text(calendar.name ?? 'Unknown Calendar'),
                      onTap: () {
                        calendarId = calendar.id;
                        Get.back();
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      } else {
        calendarId = _calendars.first.id;
      }

      if (calendarId == null) {
        Get.snackbar('Cancelled', 'Calendar selection cancelled');
        return;
      }

      final calendarEvent = device_calendar.Event(
        calendarId,
        title: event.title,
        description: event.description,
        location: event.location,
        start: tz.TZDateTime.from(event.startTime, tz.local),
        end: tz.TZDateTime.from(event.endTime, tz.local),
      );

      final createResult =
          await _deviceCalendarPlugin.createOrUpdateEvent(calendarEvent);

      if (createResult?.isSuccess == true &&
          (createResult?.data?.isNotEmpty ?? false)) {
        Get.snackbar(
          'Success',
          'Event "${event.title}" added to your calendar',
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar('Error', 'Failed to add event to calendar');
      }
    } catch (e) {
      print('Error syncing event to calendar: $e');
      Get.snackbar('Error', 'Failed to sync event with device calendar');
    }
  }

  Future<void> syncAllEventsToPhoneCalendar() async {
    try {
      await _retrieveCalendars();
      if (_calendars.isEmpty)
        return; // Error already shown in _retrieveCalendars

      // If multiple calendars exist, let user choose
      String? calendarId;
      if (_calendars.length > 1) {
        await Get.dialog(
          AlertDialog(
            title: const Text('Select Calendar'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: _calendars
                  .map(
                    (calendar) => ListTile(
                      title: Text(calendar.name ?? 'Unknown Calendar'),
                      onTap: () {
                        calendarId = calendar.id;
                        Get.back();
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      } else {
        calendarId = _calendars.first.id;
      }

      if (calendarId == null) {
        Get.snackbar('Cancelled', 'Calendar selection cancelled');
        return;
      }

      print('\n=== Starting Calendar Sync ===');
      print('Total events to sync: ${events.length}');
      print('Selected calendar ID: $calendarId');

      int successCount = 0;
      int failCount = 0;

      for (final event in events) {
        print('\nAttempting to sync event:');
        print('Title: ${event.title}');
        print('Start: ${event.startTime}');
        print('End: ${event.endTime}');
        print('Location: ${event.location}');

        try {
          final calendarEvent = device_calendar.Event(
            calendarId,
            title: event.title,
            description: event.description,
            location: event.location,
            start: tz.TZDateTime.from(event.startTime, tz.local),
            end: tz.TZDateTime.from(event.endTime, tz.local),
          );

          final createResult =
              await _deviceCalendarPlugin.createOrUpdateEvent(calendarEvent);

          if (createResult?.isSuccess == true &&
              (createResult?.data?.isNotEmpty ?? false)) {
            print('✓ Success: Event "${event.title}" synced successfully');
            print('Event ID: ${createResult?.data}');
            successCount++;
          } else {
            print('✗ Failed: Could not sync "${event.title}"');
            print(
                'Error details: ${createResult?.errors?.join(', ') ?? 'Unknown error'}');
            failCount++;
          }
        } catch (e) {
          print('✗ Exception while syncing "${event.title}": $e');
          failCount++;
        }
      }

      print('\n=== Sync Summary ===');
      print('Total events processed: ${events.length}');
      print('Successful syncs: $successCount');
      print('Failed syncs: $failCount');

      if (successCount > 0) {
        Get.snackbar(
          'Sync Complete',
          'Successfully synced $successCount events${failCount > 0 ? ', $failCount failed' : ''}',
          duration: const Duration(seconds: 4),
        );
      } else if (failCount > 0) {
        Get.snackbar('Sync Failed', 'Failed to sync any events to calendar');
      }
    } catch (e) {
      print('\n=== Sync Error ===');
      print('Error syncing all events to calendar: $e');
      Get.snackbar('Error', 'Failed to sync events with device calendar');
    }
  }
}
