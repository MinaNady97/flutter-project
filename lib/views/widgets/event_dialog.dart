import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../models/event.dart';
import '../../controllers/calendar_controller.dart';

class EventDialog extends StatefulWidget {
  final Event? event;
  final DateTime selectedDate;

  const EventDialog({
    super.key,
    this.event,
    required this.selectedDate,
  });

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _startTime;
  late DateTime _endTime;
  late EventType _eventType;
  late RecurrenceType _recurrenceType;
  final List<String> _selectedAttendees = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _locationController =
        TextEditingController(text: widget.event?.location ?? '');
    _startTime = widget.event?.startTime ?? widget.selectedDate;
    _endTime = widget.event?.endTime ??
        widget.selectedDate.add(const Duration(hours: 1));
    _eventType = widget.event?.type ?? EventType.other;
    _recurrenceType = widget.event?.recurrence ?? RecurrenceType.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.event == null ? 'Add Event' : 'Edit Event',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Time'),
                      subtitle: Text(
                        '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_startTime),
                        );
                        if (time != null) {
                          setState(() {
                            _startTime = DateTime(
                              _startTime.year,
                              _startTime.month,
                              _startTime.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Time'),
                      subtitle: Text(
                        '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_endTime),
                        );
                        if (time != null) {
                          setState(() {
                            _endTime = DateTime(
                              _endTime.year,
                              _endTime.month,
                              _endTime.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EventType>(
                value: _eventType,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                ),
                items: EventType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _eventType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurrenceType>(
                value: _recurrenceType,
                decoration: const InputDecoration(
                  labelText: 'Recurrence',
                  border: OutlineInputBorder(),
                ),
                items: RecurrenceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _recurrenceType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveEvent,
                    child: Text(widget.event == null ? 'Add' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = Get.find<CalendarController>();
      final event = Event(
        id: widget.event?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: _startTime,
        endTime: _endTime,
        type: _eventType,
        color: _getColorForEventType(_eventType),
        location: _locationController.text,
        attendees: _selectedAttendees,
        creatorId: 'current_user_id', // TODO: Get actual user ID
        recurrence: _recurrenceType,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        lastModified: DateTime.now(),
      );

      if (widget.event == null) {
        controller.addEvent(event);
      } else {
        controller.updateEvent(event);
      }

      Get.back();
    }
  }

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
}
