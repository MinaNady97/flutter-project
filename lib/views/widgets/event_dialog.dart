import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hci_flutter/models/event.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/home_controller.dart';

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
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late String _eventType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _locationController =
        TextEditingController(text: widget.event?.location ?? '');
    
    _startDate = widget.event?.startTime ?? widget.selectedDate;
    _startTime = TimeOfDay.fromDateTime(widget.event?.startTime ?? 
        widget.selectedDate.add(const Duration(hours: 1)));
    
    _endDate = widget.event?.endTime ?? widget.selectedDate;
    _endTime = TimeOfDay.fromDateTime(widget.event?.endTime ?? 
        widget.selectedDate.add(const Duration(hours: 2)));
    
    _eventType = widget.event?.type.toString().split('.').last ?? 'general';
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
    final homeController = Get.find<HomeController>();

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
                    child: TextButton(
                      onPressed: () => _selectDate(context, isStartDate: true),
                      child: Text('Date: ${_formatDate(_startDate)}'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectTime(context, isStartTime: true),
                      child: Text('Time: ${_formatTime(_startTime)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDate(context, isStartDate: false),
                      child: Text('End Date: ${_formatDate(_endDate)}'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectTime(context, isStartTime: false),
                      child: Text('End Time: ${_formatTime(_endTime)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _eventType,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'general',
                  'birthday',
                  'appointment',
                  'meeting',
                  'reminder',
                  'other'
                ].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.capitalizeFirst!),
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
                    onPressed: () => _saveEvent(homeController),
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

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveEvent(HomeController homeController) async {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = Get.find<CalendarController>();

      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      if (endDateTime.isBefore(startDateTime)) {
        Get.snackbar('Error', 'End time cannot be before start time');
        return;
      }

      final eventData = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "location": _locationController.text,
        "start_time": startDateTime.toUtc().toIso8601String(),
        "end_time": endDateTime.toUtc().toIso8601String(),
        "type": _eventType,
        "priority": "normal",
        "family_id": homeController.familyId,
        "created_by": homeController.userId,
      };

      try {
        if (widget.event == null) {
          await controller.addEventFromForm(eventData);
        } else {
          // TODO: Implement update event
          Get.snackbar('Info', 'Update functionality not implemented yet');
        }
        Get.back();
      } catch (e) {
        Get.snackbar('Error', 'Failed to save event');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}