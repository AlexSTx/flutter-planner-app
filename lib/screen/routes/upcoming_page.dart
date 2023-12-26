import 'package:flutter/material.dart';
import 'package:planner_app/controller/task_controller.dart';
import 'package:planner_app/model/date_range.dart';
import 'package:planner_app/model/task.dart';
import 'package:planner_app/providers/notifiers.dart';
import 'package:planner_app/providers/session.dart';
import 'package:provider/provider.dart';

import '../../../components/tasks_view.dart';

class UpcomingTasks extends StatefulWidget {
  const UpcomingTasks({super.key});

  @override
  State<UpcomingTasks> createState() => _UpcomingTasksState();
}

class _UpcomingTasksState extends State<UpcomingTasks> {
  late Future<List<Task>> _tasks;

  final _optionsfocusNode = FocusNode(debugLabel: "Options");

  TaskController taskController = TaskController();
  bool _initialized = false;

  @override
  void dispose() {
    _optionsfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var session = context.watch<Session>();
    var taskNotifier = context.watch<TaskNotifier>();

    if (_initialized == false || taskNotifier.wasATaskCreated) {
      setState(() {
        _initialized = true;
        _tasks = taskController.fetchUserTasks(
          session.getSessionUserId() ?? -1,
          dateRange: DateRange(
              startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 7))),
        );
      });
    }

    if (taskNotifier.wereTasksUpdated) {
      taskController.updateTasks(taskNotifier.tasks);
      taskNotifier.taskUpdatesSaved();
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Upcoming Tasks")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/task_form');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
              future: _tasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Text("Loading...");
                } else if (snapshot.hasData) {
                  var data = snapshot.data;
                  taskNotifier.tasks = data ?? [];
                  taskNotifier.taskCreationsSaved();

                  return TasksView(tasks: data, boards: const []);
                } else {
                  return const Text('Tem tarefa nenhuma não');
                }
              }),
        ),
      ),
    );
  }
}
