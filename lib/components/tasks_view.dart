import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner_app/components/task_details.dart';
import 'package:planner_app/controller/task_controller.dart';
import 'package:planner_app/model/date_range.dart';
import 'package:planner_app/model/task.dart';
import 'package:planner_app/model/task_board.dart';
import 'package:planner_app/providers/notifiers.dart';
import 'package:provider/provider.dart';
import '../../misc/color_map.dart';

class TasksView extends StatelessWidget {
  const TasksView({
    super.key,
    required this.tasks,
    required this.boards,
  });

  final List<Task>? tasks;
  final List<TaskBoard> boards;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var task in tasks!)
          TaskCard(
              task: task,
              color: boards.isNotEmpty
                  ? BOARD_COLORS[boards.firstWhere((b) => task.boardId == b.id).color]['cor']
                  : null),
      ],
    );
  }
}

class TaskCard extends StatefulWidget {
  TaskCard({super.key, required this.task, required this.color});
  final Task task;
  final taskController = TaskController();

  final Color? color;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    DateRange dr = widget.task.taskDateRange;

    var taskNotifier = context.watch<TaskNotifier>();

    return Container(
      decoration: widget.color != null
          ? BoxDecoration(
              border: Border(
              left: BorderSide(color: widget.color!, width: 6),
            ))
          : null,
      child: CheckboxListTile(
        // tileColor: widget.color,
        contentPadding: EdgeInsets.zero,
        value: widget.task.isCompleted,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (value) async {
          widget.task.isCompleted = value!;
          setState(() {});
          await widget.taskController.updateTask(widget.task);
        },
        title: Text(widget.task.title),
        subtitle: Text(
            "${DateFormat("MMMd").format(widget.task.startTime)}, ${dr.startTime} - ${widget.task.sameDay ? "" : DateFormat("MMMd").format(widget.task.endTime)} ${dr.endTime}"),
        secondary: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () async {
            taskNotifier.currentTask = widget.task;
            await showModalBottomSheet(
                context: context,
                enableDrag: true,
                useSafeArea: true,
                showDragHandle: true,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: const TaskDetails(),
                  );
                });
          },
        ),
      ),
    );
  }
}
