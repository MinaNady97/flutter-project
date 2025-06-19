import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/routes.dart';
import '../../controllers/calendar_controller.dart';
import '../../models/event.dart';
import '../widgets/event_dialog.dart';
import '../../controllers/home_controller.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CalendarController());
    final homeController = Get.find<HomeController>();

    return Scaffold(
      body: Obx(() {
        if (controller.isSyncing.value && controller.events.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Show loading indicator while refreshing
            controller.isSyncing.value = true;
            try {
              await controller.fetchFamilyEvents(homeController.userId.value);
            } finally {
              controller.isSyncing.value = false;
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Profile header
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(
                          'https://randomuser.me/api/portraits/women/44.jpg',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning,',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              homeController.username.value,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(() => IconButton(
                          icon: Icon(
                            controller.isAutoSyncEnabled.value
                                ? Icons.sync_disabled
                                : Icons.sync,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () async {
                            final newValue =
                                !controller.isAutoSyncEnabled.value;
                            controller.isAutoSyncEnabled.value = newValue;
                            await controller.prefs
                                ?.setBool('autoSync', newValue);

                            if (newValue) {
                              await controller.syncAllEventsToPhoneCalendar();
                              Get.snackbar('Auto Sync', 'Auto-sync is ON');
                            } else {
                              Get.snackbar('Auto Sync', 'Auto-sync is OFF');
                            }
                          })),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Calendar Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TableCalendar(
                      firstDay:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: controller.selectedDate.value,
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: const TextStyle(
                          color: AppRoute.secondaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon: const Icon(
                          Icons.chevron_left,
                          color: AppRoute.secondaryColor,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right,
                          color: AppRoute.secondaryColor,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppRoute.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: AppRoute.primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppRoute.primaryColor,
                            width: 1,
                          ),
                        ),
                        markerDecoration: BoxDecoration(
                          color: AppRoute.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        markerSize: 6,
                        markerMargin: const EdgeInsets.only(top: 2),
                      ),
                      eventLoader: (day) => controller.getEventsForDate(day),
                      selectedDayPredicate: (day) {
                        return isSameDay(controller.selectedDate.value, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        controller.selectedDate.value = selectedDay;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tasks Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Events',
                        style: TextStyle(
                          color: AppRoute.primaryColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Get.dialog(
                            EventDialog(
                              selectedDate: controller.selectedDate.value,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppRoute.primaryColor,
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Events List
                  Obx(() {
                    final dayEvents = controller.getEventsForDate(
                      controller.selectedDate.value,
                    );

                    if (dayEvents.isEmpty) {
                      return const Center(
                        child: Text(
                          'No events for this day',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return Column(
                      children: dayEvents.map((event) {
                        final isCurrentUserCreator =
                            event.creatorId == homeController.userId.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: event.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(
                              event.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: event.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - '
                                  '${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}\n'
                                  '${event.location}',
                                ),
                                if (event.participants.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Participants: ' +
                                        event.participants
                                            .map((p) => p.userName ?? 'Unknown')
                                            .join(', '),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                            trailing: isCurrentUserCreator
                                ? PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        Get.dialog(
                                          EventDialog(
                                            event: event,
                                            selectedDate: event.startTime,
                                          ),
                                        );
                                      } else if (value == 'delete') {
                                        await controller.deleteEvent(event.id);
                                      }
                                    },
                                  )
                                : null,
                            onTap: () {
                              _showEventDetails(context, event);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showEventDetails(BuildContext context, Event event) {
    final controller = Get.find<CalendarController>();
    final homeController = Get.find<HomeController>();
    final isCurrentUserCreator = event.creatorId == homeController.userId.value;
    final isCurrentUserParticipant =
        event.participants.any((p) => p.userId == homeController.userId.value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              '${_formatDate(event.startTime)} - ${_formatTime(event.endTime)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (event.location.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Location: ${event.location}'),
            ],
            if (event.participants.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Participants:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...event.participants
                  .map((p) => Text(p.userName ?? 'Unknown'))
                  .toList(),
            ],
            const SizedBox(height: 16),
            if (!isCurrentUserParticipant && !isCurrentUserCreator)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.joinEvent(event.id, homeController.userId.value,
                        homeController.username.value);
                  },
                  child: const Text('Join Event'),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}