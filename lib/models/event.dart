import 'package:flutter/material.dart';

enum EventType { birthday, appointment, meeting, reminder, other }

enum RecurrenceType { none, daily, weekly, monthly, yearly }

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final EventType type;
  final Color color;
  final String location;
  final List<String> attendees;
  final String creatorId;
  final RecurrenceType recurrence;
  final bool isCompleted;
  final bool isCancelled;
  final List<String> attachments;
  final Map<String, dynamic> additionalDetails;
  final DateTime createdAt;
  final DateTime? lastModified;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.color,
    required this.location,
    required this.attendees,
    required this.creatorId,
    this.recurrence = RecurrenceType.none,
    this.isCompleted = false,
    this.isCancelled = false,
    this.attachments = const [],
    this.additionalDetails = const {},
    required this.createdAt,
    this.lastModified,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    EventType? type,
    Color? color,
    String? location,
    List<String>? attendees,
    String? creatorId,
    RecurrenceType? recurrence,
    bool? isCompleted,
    bool? isCancelled,
    List<String>? attachments,
    Map<String, dynamic>? additionalDetails,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      color: color ?? this.color,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      creatorId: creatorId ?? this.creatorId,
      recurrence: recurrence ?? this.recurrence,
      isCompleted: isCompleted ?? this.isCompleted,
      isCancelled: isCancelled ?? this.isCancelled,
      attachments: attachments ?? this.attachments,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type.toString(),
      'color': color.value,
      'location': location,
      'attendees': attendees,
      'creatorId': creatorId,
      'recurrence': recurrence.toString(),
      'isCompleted': isCompleted,
      'isCancelled': isCancelled,
      'attachments': attachments,
      'additionalDetails': additionalDetails,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      type: EventType.values.firstWhere((e) => e.toString() == json['type']),
      color: Color(json['color']),
      location: json['location'],
      attendees: List<String>.from(json['attendees']),
      creatorId: json['creatorId'],
      recurrence: RecurrenceType.values.firstWhere(
        (e) => e.toString() == json['recurrence'],
      ),
      isCompleted: json['isCompleted'],
      isCancelled: json['isCancelled'],
      attachments: List<String>.from(json['attachments']),
      additionalDetails: json['additionalDetails'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModified:
          json['lastModified'] != null
              ? DateTime.parse(json['lastModified'])
              : null,
    );
  }
}
