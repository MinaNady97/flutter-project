import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/routes.dart';
import '../../controllers/calendar_controller.dart';
import '../../models/event.dart';
import '../widgets/event_dialog.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CalendarController());

    return Scaffold(
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Profile, greeting, notification
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
                        children: const [
                          Text(
                            'Good Morning,',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Farah',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.notifications_none,
                        color: Colors.white, size: 32),
                  ],
                ),
                const SizedBox(height: 24),
                // Tasks title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tasks',
                      style: TextStyle(
                        color: AppRoute.primaryColor,
                        fontSize: 32,
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
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Task checkboxes
                Obx(() {
                  final events = controller
                      .getEventsForDate(controller.selectedDate.value);
                  return Column(
                    children: events.map((event) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CheckboxListTile(
                          value: event.isCompleted,
                          onChanged: (value) {
                            if (value == true) {
                              controller.markEventAsCompleted(event.id);
                            }
                          },
                          title: Text(event.title),
                          subtitle: Text(
                            '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                Get.dialog(
                                  EventDialog(
                                    event: event,
                                    selectedDate: controller.selectedDate.value,
                                  ),
                                );
                              } else if (value == 'delete') {
                                controller.deleteEvent(event.id);
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 16),
                // Calendar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${_getMonthName(controller.selectedDate.value.month)}',
                                style: const TextStyle(
                                  color: AppRoute.secondaryColor,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${controller.selectedDate.value.year}',
                                style: const TextStyle(
                                  color: AppRoute.secondaryColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  final newDate = DateTime(
                                    controller.selectedDate.value.year,
                                    controller.selectedDate.value.month - 1,
                                    1,
                                  );
                                  controller.selectedDate.value = newDate;
                                },
                                icon: const Icon(Icons.chevron_left),
                                color: AppRoute.secondaryColor,
                              ),
                              IconButton(
                                onPressed: () {
                                  final newDate = DateTime(
                                    controller.selectedDate.value.year,
                                    controller.selectedDate.value.month + 1,
                                    1,
                                  );
                                  controller.selectedDate.value = newDate;
                                },
                                icon: const Icon(Icons.chevron_right),
                                color: AppRoute.secondaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _CalendarWidget(
                        selectedDate: controller.selectedDate.value,
                        onDateSelected: (date) {
                          controller.selectedDate.value = date;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

class _CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const _CalendarWidget({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CalendarController>();
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    return Table(
      border: TableBorder.symmetric(
        inside: BorderSide(color: Colors.grey.shade200),
      ),
      children: [
        const TableRow(
          children: [
            Center(
                child:
                    Text('Sun', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(
                child:
                    Text('Mon', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(
                child:
                    Text('Tue', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(
                child:
                    Text('Wed', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(
                child:
                    Text('Thu', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(
                child:
                    Text('Fri', style: TextStyle(fontWeight: FontWeight.bold))),
            Center(
                child:
                    Text('Sat', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        ...List.generate(6, (week) {
          return TableRow(
            children: List.generate(7, (day) {
              final date = week * 7 + day - firstWeekday + 1;
              final isToday = date == DateTime.now().day &&
                  selectedDate.month == DateTime.now().month &&
                  selectedDate.year == DateTime.now().year;
              final isSelected = date == selectedDate.day;

              if (date < 1 || date > daysInMonth) {
                return const SizedBox(height: 40);
              }

              final events = controller.getEventsForDate(
                DateTime(selectedDate.year, selectedDate.month, date),
              );

              return GestureDetector(
                onTap: () {
                  onDateSelected(
                      DateTime(selectedDate.year, selectedDate.month, date));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppRoute.secondaryColor
                              : isSelected
                                  ? AppRoute.primaryColor.withOpacity(0.1)
                                  : null,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '$date',
                          style: TextStyle(
                            color: isToday
                                ? Colors.white
                                : isSelected
                                    ? AppRoute.primaryColor
                                    : AppRoute.secondaryColor,
                            fontWeight: isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (events.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          height: 4,
                          width: 4,
                          decoration: BoxDecoration(
                            color: events.first.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}
