import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner_app/components/tasks_view.dart';
import 'package:planner_app/controller/task_controller.dart';
import 'package:planner_app/model/date_range.dart';
import 'package:planner_app/model/task.dart';
import 'package:planner_app/providers/notifiers.dart';
import 'package:planner_app/providers/session.dart';
import 'package:provider/provider.dart';
import '../../misc/color_map.dart';

class CalendarPage extends StatefulWidget {
  final Session session;
  const CalendarPage({super.key, required this.session});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final taskController = TaskController();

  late Future<List<Task>> _tasks;
  late Future<Map<String, List<int>>> _monthlyColors;

  late DateTime today;
  late DateTime currRefDate;
  late DateTime? currentDate;

  @override
  void initState() {
    today = DateTime.now();
    currRefDate = DateTime.now();
    currentDate = DateTime.now();
    _tasks = taskController.fetchUserTasks(widget.session.getSessionUserId()!,
        dateRange: getDateRange());
    _monthlyColors =
        taskController.getColorsByDate(widget.session.getSessionUserId()!, getDateRange());
    super.initState();
  }

  void initialFetch() {
    _monthlyColors =
        taskController.getColorsByDate(widget.session.getSessionUserId()!, getDateRange());
    _tasks = taskController.fetchUserTasks(widget.session.getSessionUserId()!,
        dateRange: getDateRange());
  }

  void fetchMonthlyColors() {
    setState(() {
      _monthlyColors =
          taskController.getColorsByDate(widget.session.getSessionUserId()!, getDateRange());
    });
  }

  void fetchDailyTasks(DateTime? date) {
    if (date == null) return;
    setState(() {
      currentDate = date;
      _tasks = taskController.fetchUserTasks(widget.session.getSessionUserId()!,
          date: DateFormat('yyyy-MM-dd').format(date).toString());
    });
  }

  int getFirstDayPosition() {
    DateTime firstDay = DateTime(currRefDate.year, currRefDate.month, 1);
    return (firstDay.weekday == 7) ? 0 : firstDay.weekday;
  }

  DateRange getDateRange() {
    DateTime firstDay = currRefDate.copyWith(day: 1).add(Duration(days: 0 - getFirstDayPosition()));
    DateTime lastDay = currRefDate.copyWith(day: 1).add(Duration(days: 39 - getFirstDayPosition()));
    return DateRange(startDate: firstDay, endDate: lastDay);
  }

  DateTime _nextRefMonth() {
    int newMonth = currRefDate.month % 12 + 1;
    int newYear = currRefDate.year;

    if (newMonth < currRefDate.month) newYear += 1;

    return currRefDate.copyWith(year: newYear, month: newMonth);
  }

  DateTime _prevRefMonth() {
    int newMonth = currRefDate.month - 1;
    int newYear = currRefDate.year;
    if (newMonth == 0) {
      newMonth = 12;
      newYear -= 1;
    }
    return currRefDate.copyWith(year: newYear, month: newMonth);
  }

  TextStyle _getCalendarTextColor(bool isThisMonth, bool isToday, bool isCurrentDay) {
    TextStyle style = isCurrentDay
        ? const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)
        : const TextStyle();
    if (isToday) return style.copyWith(color: Colors.red, fontWeight: FontWeight.bold);
    if (isThisMonth) return style.copyWith(color: Colors.black);
    return style.copyWith(color: const Color.fromARGB(255, 150, 150, 150));
  }

  Widget getCalendarDay(
      DateTime refDate, int numero, List<Task> tasks, Map<String, List<int>>? colors,
      {TaskNotifier? taskNotifier}) {
    DateTime day;
    int firstDayPosition = getFirstDayPosition();
    int diff = numero - firstDayPosition;

    if (numero == firstDayPosition) {
      day = refDate.copyWith(day: 1);
    } else {
      day = refDate.copyWith(day: 1).add(Duration(days: diff));
    }

    bool isThisMonth = day.month == refDate.month;
    bool isToday = day
                .copyWith(hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0)
                .difference(
                    today.copyWith(hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0))
                .inDays ==
            0
        ? true
        : false;

    return GestureDetector(
      onTap: () {
        if (day != currentDate) fetchDailyTasks(day);
        taskNotifier?.currentDate = day;
      },
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black38, width: 0.5)),
        child: Center(
          child: Column(
            children: [
              Text(
                '${day.day}',
                style: _getCalendarTextColor(isThisMonth, isToday, day == currentDate),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (colors != null)
                    for (var tIndicator
                        in colors[DateFormat('yyyy-MM-dd').format(day)]?.take(4).map<Icon>((c) {
                              return Icon(
                                Icons.circle,
                                color: BOARD_COLORS[c]['cor'],
                                size: 10,
                              );
                            }).toList() ??
                            [])
                      tIndicator,
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
              // onPressed: () => fetchMonthlyTasks(_prevRefMonth()),
              onPressed: () {
                currRefDate = _prevRefMonth();
                fetchMonthlyColors();
              },
              icon: const Icon(Icons.arrow_back_rounded)),
          IconButton(
              // onPressed: () => fetchMonthlyTasks(_nextRefMonth()),
              onPressed: () {
                currRefDate = _nextRefMonth();
                fetchMonthlyColors();
              },
              icon: const Icon(Icons.arrow_forward_rounded)),
          IconButton(
            // onPressed: () => fetchMonthlyTasks(today),
            onPressed: () {
              currRefDate = today;
              fetchMonthlyColors();
            },
            icon: const Icon(Icons.today),
          )
        ],
      ),
    );
  }

  Widget _calendar({List<Task>? tasks, Map<String, List<int>>? colors, TaskNotifier? notifier}) {
    return Column(
      children: [
        Text(
          DateFormat('MMMM, yyyy').format(currRefDate),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('D'),
            Text('S'),
            Text('T'),
            Text('Q'),
            Text('Q'),
            Text('S'),
            Text('S'),
          ],
        ),
        SizedBox(
          height: 400,
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: .8,
            crossAxisCount: 7,
            children: [
              for (var i = 0; i < 42; i++)
                getCalendarDay(currRefDate, i, tasks ?? [], colors, taskNotifier: notifier),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var taskNotifier = context.watch<TaskNotifier>();
    var boardNotifier = context.watch<BoardNotifier>();

    if (taskNotifier.wasATaskCreated) {
      fetchDailyTasks(currentDate);
    }

    if (boardNotifier.mustRecount) {
      fetchMonthlyColors();
      boardNotifier.recounted();
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: FutureBuilder(
            future: _monthlyColors,
            builder: (context, snapColors) {
              if (snapColors.connectionState != ConnectionState.done) {
                return Column(children: [_calendar(notifier: taskNotifier), _optionRow()]);
              } else if (snapColors.hasError) {
                return Text(snapColors.error.toString());
              }
              var monthlyColors = snapColors.data;
              return FutureBuilder(
                  future: _tasks,
                  builder: (context, snapTasks) {
                    if (snapTasks.connectionState != ConnectionState.done) {
                      return Column(children: [
                        _calendar(colors: monthlyColors, notifier: taskNotifier),
                        _optionRow()
                      ]);
                    } else if (snapTasks.hasError) {
                      return Text(snapTasks.error.toString());
                    } else {
                      var tasks = snapTasks.data;
                      return Column(
                        children: [
                          _calendar(tasks: tasks, colors: monthlyColors, notifier: taskNotifier),
                          _optionRow(),
                          TasksView(tasks: tasks, boards: boardNotifier.boards),
                          const SizedBox(height: 96),
                        ],
                      );
                    }
                  });
            }),
      ),
    );
  }
}
