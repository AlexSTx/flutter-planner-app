import 'package:flutter/material.dart';
import 'package:planner_app/controller/task_controller.dart';
import 'package:planner_app/providers/notifiers.dart';

class MenuDeleteAll extends StatelessWidget {
  const MenuDeleteAll({
    super.key,
    required this.taskController,
    required this.taskNotifier,
  });

  final TaskController taskController;
  final TaskNotifier taskNotifier;

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
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
    );
  }
}

class MenuIncompleteAll extends StatelessWidget {
  const MenuIncompleteAll({
    super.key,
    required this.taskNotifier,
    required this.taskController,
  });

  final TaskNotifier taskNotifier;
  final TaskController taskController;

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      child: const Text('Marcar todas como incompletas'),
      onPressed: () async {
        taskNotifier.tasks.forEach((task) {
          task.isCompleted = false;
          task.modify();
        });
        await taskController.updateTasks(taskNotifier.tasks);
        taskNotifier.updatedTask();
      },
    );
  }
}
