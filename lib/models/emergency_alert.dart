import 'package:flutter/material.dart';

enum EmergencyType { medical, fire, security, other }

enum AlertStatus { active, acknowledged, resolved }

class EmergencyAlert {
  final String id;
  final String senderId;
  final String senderName;
  final EmergencyType type;
  final String message;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String location;
  final AlertStatus status;
  final List<String> acknowledgedBy;
  final Map<String, dynamic> additionalInfo;

  EmergencyAlert({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.location,
    this.status = AlertStatus.active,
    this.acknowledgedBy = const [],
    this.additionalInfo = const {},
  });

  EmergencyAlert copyWith({
    String? id,
    String? senderId,
    String? senderName,
    EmergencyType? type,
    String? message,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? location,
    AlertStatus? status,
    List<String>? acknowledgedBy,
    Map<String, dynamic>? additionalInfo,
  }) {
    return EmergencyAlert(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      status: status ?? this.status,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'type': type.toString(),
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'status': status.toString(),
      'acknowledgedBy': acknowledgedBy,
      'additionalInfo': additionalInfo,
    };
  }

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) {
    return EmergencyAlert(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      type: EmergencyType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      location: json['location'],
      status: AlertStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      acknowledgedBy: List<String>.from(json['acknowledgedBy']),
      additionalInfo: json['additionalInfo'],
    );
  }
}
