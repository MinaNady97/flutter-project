import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/event.dart';
import 'package:uuid/uuid.dart';

class CalendarController extends GetxController {
  final RxList<Event> events = <Event>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<Event?> selectedEvent = Rx<Event?>(null);
  final RxBool isSyncing = false.obs;

  // Add a new event
  void addEvent(Event event) {
    events.add(event);
    _scheduleNotifications(event);
    _syncWithPersonalCalendar(event);
  }

  // Update an existing event
  void updateEvent(Event event) {
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      _scheduleNotifications(event);
      _syncWithPersonalCalendar(event);
      _notifyAttendees(event);
    }
  }

  // Delete an event
  void deleteEvent(String eventId) {
    final event = events.firstWhere((e) => e.id == eventId);
    events.removeWhere((e) => e.id == eventId);
    _notifyAttendees(event, isDeletion: true);
  }

  // Mark event as completed
  void markEventAsCompleted(String eventId) {
    final index = events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = events[index];
      events[index] = event.copyWith(
        isCompleted: true,
        lastModified: DateTime.now(),
      );
      _notifyAttendees(event, isCompletion: true);
    }
  }

  // Mark event as cancelled
  void markEventAsCancelled(String eventId) {
    final index = events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = events[index];
      events[index] = event.copyWith(
        isCancelled: true,
        lastModified: DateTime.now(),
      );
      _notifyAttendees(event, isCancellation: true);
    }
  }

  // Get events for a specific date
  List<Event> getEventsForDate(DateTime date) {
    return events.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList();
  }

  // Get upcoming events
  List<Event> getUpcomingEvents() {
    final now = DateTime.now();
    return events.where((event) => event.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Schedule notifications for an event
  void _scheduleNotifications(Event event) {
    // TODO: Implement notification scheduling
    // This would integrate with a notification service
  }

  // Sync with personal calendar
  void _syncWithPersonalCalendar(Event event) {
    // TODO: Implement calendar sync
    // This would integrate with device calendar
  }

  // Notify attendees about event changes
  void _notifyAttendees(
    Event event, {
    bool isDeletion = false,
    bool isCompletion = false,
    bool isCancellation = false,
  }) {
    // TODO: Implement attendee notifications
    // This would integrate with a messaging service
  }

  // Create a new event with default values
  Event createNewEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required EventType type,
    required String location,
    required List<String> attendees,
    required String creatorId,
    RecurrenceType recurrence = RecurrenceType.none,
  }) {
    return Event(
      id: const Uuid().v4(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      type: type,
      color: _getColorForEventType(type),
      location: location,
      attendees: attendees,
      creatorId: creatorId,
      recurrence: recurrence,
      createdAt: DateTime.now(),
    );
  }

  // Get color based on event type
  Color _getColorForEventType(EventType type) {
    switch (type) {
      case EventType.birthday:
        return Colors.pink;
      case EventType.appointment:
        return Colors.blue;
      case EventType.meeting:
        return Colors.green;
      case EventType.reminder:
        return Colors.orange;
      case EventType.other:
        return Colors.purple;
    }
  }

  // Check for event conflicts
  bool hasEventConflict(
    DateTime startTime,
    DateTime endTime, {
    String? excludeEventId,
  }) {
    return events.any((event) {
      if (excludeEventId != null && event.id == excludeEventId) return false;
      return (startTime.isBefore(event.endTime) &&
          endTime.isAfter(event.startTime));
    });
  }

  // Get events for a date range
  List<Event> getEventsForDateRange(DateTime start, DateTime end) {
    return events.where((event) {
      return event.startTime.isAfter(start) && event.endTime.isBefore(end);
    }).toList();
  }
}
