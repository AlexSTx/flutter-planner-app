import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner_app/components/my_date_range_picker.dart';
import 'package:planner_app/controller/board_controller.dart';
import 'package:planner_app/controller/task_controller.dart';
import 'package:planner_app/model/date_range.dart';
import 'package:planner_app/model/task.dart';
import 'package:planner_app/model/task_board.dart';
import 'package:planner_app/providers/notifiers.dart';
import 'package:provider/provider.dart';
import '../../misc/color_map.dart';

class TaskDetails extends StatefulWidget {
  const TaskDetails({
    super.key,
  });

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final _taskEditingFormKey = GlobalKey<FormState>();
  final taskController = TaskController();
  final boardController = BoardController();

  late Task tempTask;
  late TextEditingController titleController;
  late TextEditingController noteController;

  var _initialized = false;

  late Future<List<TaskBoard>> _taskBoards;

  @override
  void initState() {
    titleController = TextEditingController();
    noteController = TextEditingController();
    _taskBoards = boardController.getAllTaskBoards();
    super.initState();
  }

  Future<void> _titleSubmit(TaskNotifier notifier) async {
    if (titleController.text.isNotEmpty) {
      tempTask.title = titleController.text;
      notifier.currentTask!.updateTaskFromClone(tempTask);
      notifier.updatedTask();
    }
  }

  Future<void> _noteSubmit(TaskNotifier notifier) async {
    if (noteController.text.isNotEmpty) {
      tempTask.note = noteController.text;
      notifier.currentTask!.updateTaskFromClone(tempTask);
      notifier.updatedTask();
    }
  }

  @override
  Widget build(BuildContext context) {
    var taskNotifier = context.watch<TaskNotifier>();
    var boardNotifier = context.watch<BoardNotifier>();

    if (taskNotifier.currentTask == null) {
      return const Placeholder();
    }

    if (_initialized == false) {
      tempTask = Task.clone(taskNotifier.currentTask!);
      _initialized = true;
    }

    if (taskNotifier.wereTasksUpdated) {
      taskNotifier.currentTask!.updateTaskFromClone(tempTask);
    }

    titleController.text = tempTask.title;
    noteController.text = tempTask.note;

    DateRange dr = tempTask.taskDateRange;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Checkbox(
                    value: tempTask.isCompleted,
                    onChanged: (value) {
                      tempTask.isCompleted = value!;
                      taskNotifier.currentTask!.updateTaskFromClone(tempTask);
                      taskNotifier.updatedTask();
                    }),
                GestureDetector(
                  onTap: () async {
                    await showModalBottomSheet(
                        context: context,
                        enableDrag: true,
                        useSafeArea: true,
                        showDragHandle: true,
                        builder: (BuildContext context) {
                          return TaskDateTime(tempTask: tempTask);
                        });
                  },
                  child: Text(
                    "${DateFormat("MMMd").format(tempTask.startTime)}, ${dr.startTime} - ${tempTask.sameDay ? "" : DateFormat("MMMd").format(tempTask.endTime)} ${dr.endTime}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Excluir Tarefa'),
                              content: const Text('Tem certeza? Essa ação é permanente.'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child:
                                      Text('Excluir', style: TextStyle(color: Colors.red.shade600)),
                                  onPressed: () {
                                    taskController.deleteTask(taskNotifier.currentTask!);
                                    taskNotifier.deleteTask(taskNotifier.currentTask!);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    boardNotifier.recount();
                                  },
                                ),
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.delete_outline))
              ],
            ),
            Form(
                key: _taskEditingFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: titleController,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) async {
                        await _titleSubmit(taskNotifier);
                      },
                      onTapOutside: (value) async {
                        await _titleSubmit(taskNotifier);
                      },
                      decoration: const InputDecoration(border: InputBorder.none),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'O campo título não pode estar vazio';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                        controller: noteController,
                        textInputAction: TextInputAction.newline,
                        onFieldSubmitted: (value) async {
                          await _noteSubmit(taskNotifier);
                        },
                        onTapOutside: (value) async {
                          await _noteSubmit(taskNotifier);
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'O campo nota não pode estar vazio';
                          }
                          return null;
                        },
                        minLines: 5,
                        maxLines: 128),
                  ],
                )),
            const SizedBox(
              height: 32,
            ),
            FutureBuilder(
                future: _taskBoards,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Text('Loading...');
                  } else if (snapshot.hasData) {
                    var data = snapshot.data!;
                    boardNotifier.boards = data;
                    boardNotifier.changesDone();

                    var currBoard = boardNotifier.getBoard(tempTask.boardId);

                    return Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    title: const Text("Mover Tarefa"),
                                    children: [
                                      BoardPicker(
                                        tempTask: tempTask,
                                        boardNotifier: boardNotifier,
                                        taskNotifier: taskNotifier,
                                      ),
                                    ],
                                  );
                                });
                          },
                          icon: const Icon(Icons.drive_file_move),
                        ),
                        const Spacer(),
                        Text(currBoard?.name ?? 'Board Desconhecida'),
                        const SizedBox(width: 8),
                        Icon(Icons.circle, color: BOARD_COLORS[currBoard?.color ?? 0]['cor']),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return const Text("Sem Dados");
                })
          ],
        ),
      ),
    );
  }
}

class TaskDateTime extends StatefulWidget {
  TaskDateTime({super.key, required this.tempTask});

  final taskController = TaskController();
  final Task tempTask;

  @override
  State<TaskDateTime> createState() => _TaskDateTimeState();
}

class _TaskDateTimeState extends State<TaskDateTime> {
  final _taskDateTimeFormState = GlobalKey<FormState>();

  late DateRange dateRange;

  @override
  void initState() {
    dateRange = widget.tempTask.taskDateRange;
    super.initState();
  }

  void _madeChanges(TaskNotifier notifier) {
    notifier.updatedTask();
    widget.tempTask.modify();
  }

  @override
  Widget build(BuildContext context) {
    var taskNotifier = context.watch<TaskNotifier>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _taskDateTimeFormState,
        child: Column(
          children: [
            MyDateRangePicker(dateRange: dateRange),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: () {
                  var form = _taskDateTimeFormState.currentState;

                  if (form!.validate()) {
                    form.save();
                    widget.tempTask.updateFromDateRange(dateRange);
                    _madeChanges(taskNotifier);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}

class BoardPicker extends StatelessWidget {
  BoardPicker(
      {super.key, required this.tempTask, required this.boardNotifier, required this.taskNotifier});

  final Task tempTask;
  final BoardNotifier boardNotifier;
  final TaskNotifier taskNotifier;
  final TaskController taskController = TaskController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField(
          value: boardNotifier.currentBoard?.id,
          decoration: const InputDecoration(labelText: 'Board', border: OutlineInputBorder()),
          validator: (int? value) {
            if (value == null) return 'O campo board não pode estar vazio';
            return null;
          },
          items: [
            for (var dmi in boardNotifier.boards.map<DropdownMenuItem<int>>((tb) {
              return DropdownMenuItem(
                  value: tb.id,
                  child: Row(children: [
                    Icon(Icons.circle, color: BOARD_COLORS[tb.color]['cor']),
                    const SizedBox(width: 12),
                    Text(tb.name),
                  ]));
            }).toList())
              dmi,
          ],
          onChanged: (value) async {
            if (value as int != taskNotifier.currentTask!.boardId) {
              tempTask.boardId = value;
              taskNotifier.currentTask!.updateTaskFromClone(tempTask);
              await taskController.updateTask(tempTask);
              taskNotifier.deleteTask(taskNotifier.currentTask!);
              boardNotifier.recount();
            }
          }),
    );
  }
}
