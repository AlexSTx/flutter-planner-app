import 'package:flutter/material.dart';
import 'package:planner_app/controller/task_controller.dart';
import 'package:planner_app/model/task.dart';
import 'package:planner_app/providers/notifiers.dart';
import 'package:planner_app/providers/session.dart';
import 'package:provider/provider.dart';

import '../../../components/menu_common_taskpage_options.dart';

import '../../../components/tasks_view.dart';

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
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
        _tasks = taskController.fetchUserTasks(session.getSessionUserId() ?? -1, completed: true);
      });
    }

    if (taskNotifier.wereTasksUpdated) {
      taskController.updateTasks(taskNotifier.tasks);
      taskNotifier.taskUpdatesSaved();
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Completed Tasks"), actions: [
        MenuAnchor(
          childFocusNode: _optionsfocusNode,
          menuChildren: [
            MenuIncompleteAll(taskNotifier: taskNotifier, taskController: taskController),
            MenuItemButton(
              child: const Text("Deletar todas"),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Excluir Tarefas Concluídas'),
                        content: const Text('Tem certeza? Essa ação é permanente.'),
                        actions: [
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text('Excluir', style: TextStyle(color: Colors.red.shade600)),
                            onPressed: () async {
                              var navigator = Navigator.of(context);
                              await taskController.deleteTasks(taskNotifier.tasks);
                              taskNotifier.clearTasks();
                              navigator.pop();
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
          builder: (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              focusNode: _optionsfocusNode,
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
            );
          },
        ),
      ]),
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

                  return TasksView(
                    tasks: data,
                    boards: const [],
                  );
                } else {
                  return const Text('Tem tarefa nenhuma não');
                }
              }),
        ),
      ),
    );
  }
}
