import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/ovals_painter.dart';
import '../widgets/notification_card.dart';
import '../view_models/notification_view_model.dart';
import 'package:intl/intl.dart';

class NotificacionPage extends StatelessWidget {
  const NotificacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotificacionViewModel>(
      create: (context) => NotificacionViewModel(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: OvalsPainter())),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    const Center(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<NotificacionViewModel>(
                      builder: (context, viewModel, child) {
                        return Transform.scale(
                          scale: 0.95,
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 120),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TableCalendar<Map<String, dynamic>>(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: viewModel.selectedDay ,
                              calendarFormat: CalendarFormat.month,
                              eventLoader: (day) {
                                return viewModel.events[DateTime.utc(day.year, day.month, day.day)] ?? [];
                              },
                              selectedDayPredicate: (day) => isSameDay(viewModel.selectedDay, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                viewModel.setSelectedDay(selectedDay);
                              },
                              daysOfWeekHeight: 15,
                              rowHeight: 50,
                              headerStyle: const HeaderStyle(
                                titleCentered: true,
                                formatButtonVisible: false,
                                leftChevronVisible: true,
                                rightChevronVisible: true,
                                titleTextFormatter: _customTitle,
                              ),
                              calendarStyle: const CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(
                                    BorderSide(color: Color(0xFFEB1555)),
                                  ),
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(
                                    BorderSide(
                                      color: Color(0xFF0D1021),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                selectedTextStyle: TextStyle(
                                  color: Colors.black,
                                ),
                                todayTextStyle: TextStyle(
                                  color: Colors.black
                                ),
                              ),
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, date, events) {
                                  if (events.isEmpty) return const SizedBox();
                                  final colors = [
                                    Color(0xFFEB1555),
                                    Color(0xFF3A225E),
                                    Color(0xFF0D1021),
                                  ];
                                  return Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          events.length > 3 ? 3 : events.length,
                                          (index) => Container(
                                            width: 6,
                                            height: 6,
                                            margin: const EdgeInsets.symmetric(horizontal: 1),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: colors[index % colors.length],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Consumer<NotificacionViewModel>(
                      builder: (context, viewModel, child) {
                        final eventsForSelectedDay = viewModel.events[viewModel.selectedDay] ?? [];
                        final isToday = isSameDay(viewModel.selectedDay, DateTime.now());
                        final dayLabel = isToday
                            ? 'Today'
                            : DateFormat('EEEE, MMMM d').format(viewModel.selectedDay);
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (eventsForSelectedDay.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        dayLabel,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF0D1021),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFEB1555),
                                        ),
                                        child: Text(
                                          eventsForSelectedDay.length.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              Expanded(
                                child: ListView.builder(
                                  itemCount: eventsForSelectedDay.length,
                                  itemBuilder: (context, index) {
                                    final event = eventsForSelectedDay[index];
                                    return NotificationCard(
                                      title: event['name'],
                                      time: DateFormat.jm().format(DateTime.parse(event['start_time'])),
                                      location: event['description']?? 'No description available',
                                      imageUrl: event['image_url'],
                                      id: event['event_id'],
                                      
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _customTitle(DateTime date, dynamic locale) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
