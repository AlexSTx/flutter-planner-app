import 'package:flutter/material.dart';
import 'package:planner_app/model/date_range.dart';
import 'package:planner_app/providers/notifiers.dart';
import 'package:planner_app/providers/session.dart';
import 'package:planner_app/controller/board_controller.dart';
import 'package:planner_app/controller/task_controller.dart';
import 'package:planner_app/model/task.dart';
import 'package:planner_app/model/task_board.dart';
import 'package:provider/provider.dart';
import '../../components/my_date_range_picker.dart';
import '../../misc/color_map.dart';

class TaskForm extends StatefulWidget {
  const TaskForm({super.key});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _taskFormKey = GlobalKey<FormState>();
  final boardController = BoardController();
  final taskController = TaskController();

  late Future<List<TaskBoard>> _taskBoards;

  bool _initialized = false;

  @override
  void initState() {
    _taskBoards = boardController.getAllTaskBoards();
    super.initState();
  }

  String? _title, _note;
  bool _isCompleted = false;
  int? _boardId;
  DateRange dateRange = DateRange();

  Future<void> _submit(Session session) async {
    final form = _taskFormKey.currentState;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (form!.validate()) {
      form.save();

      try {
        var newTask = Task(
            userId: session.getSessionUserId() ?? -1,
            boardId: _boardId!,
            title: _title!,
            note: _note!,
            startTime: dateRange.startDate!,
            endTime: dateRange.endDate!,
            date: DateTime.now(),
            isCompleted: _isCompleted);

        await taskController.createTask(newTask);
        messenger.showSnackBar(const SnackBar(content: Text("Tarefa criada com sucesso")));

        navigator.pop();
      } catch (e) {
        messenger.showSnackBar(const SnackBar(content: Text("Não foi possível criar a tarefa")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var boardNotifier = context.watch<BoardNotifier>();
    var taskNotifier = context.watch<TaskNotifier>();

    if (_initialized == false) {
      _boardId = boardNotifier.currentBoard?.id;
      dateRange.startDate = taskNotifier.currentDate;
      dateRange.endDate = taskNotifier.currentDate;
      _initialized = true;
    }

    return Consumer<Session>(builder: (context, session, child) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Task')),
        body: SafeArea(
          child: SingleChildScrollView(
            child: FutureBuilder(
                future: _taskBoards,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Text("Loading...");
                  } else if (snapshot.hasData) {
                    var data = snapshot.data;
                    return Form(
                      key: _taskFormKey,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              onSaved: (value) => _title = value,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                  labelText: 'Título', border: OutlineInputBorder()),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'O campo título não pode estar vazio';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                                onSaved: (value) => _note = value,
                                textInputAction: TextInputAction.newline,
                                decoration: const InputDecoration(
                                    labelText: 'Nota',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.sticky_note_2_outlined)),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'O campo nota não pode estar vazio';
                                  }
                                  return null;
                                },
                                minLines: 1,
                                maxLines: 128),
                            const SizedBox(height: 24),
                            MyDateRangePicker(dateRange: dateRange),
                            const SizedBox(height: 24),
                            DropdownButtonFormField(
                                value: boardNotifier.currentBoard?.id,
                                decoration: const InputDecoration(
                                    labelText: 'Board', border: OutlineInputBorder()),
                                validator: (int? value) {
                                  if (value == null) return 'O campo board não pode estar vazio';
                                  return null;
                                },
                                items: [
                                  for (var dmi in data!.map<DropdownMenuItem<int>>((tb) {
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
                                onChanged: (value) => _boardId = value),
                            const SizedBox(height: 24),
                            CheckboxListTile(
                                value: _isCompleted,
                                title: const Text('Completo'),
                                contentPadding: const EdgeInsets.all(0),
                                controlAffinity: ListTileControlAffinity.leading,
                                onChanged: (value) {
                                  setState(() {
                                    _isCompleted = value!;
                                  });
                                }),
                            ElevatedButton(
                                onPressed: () {
                                  _submit(session);
                                  taskNotifier.createdTask();
                                  boardNotifier.recount();
                                },
                                child: const Text('Salvar Tarefa'))
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return const Text("Tem nada aqui não");
                }),
          ),
        ),
      );
    });
  }
}
