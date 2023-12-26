import 'package:flutter/material.dart';

import 'package:planner_app/controller/board_controller.dart';

import 'package:planner_app/model/task_board.dart';
import 'package:planner_app/providers/notifiers.dart';
import 'package:provider/provider.dart';
import '../../misc/color_map.dart';

class TaskBoardForm extends StatefulWidget {
  const TaskBoardForm({super.key});

  @override
  State<TaskBoardForm> createState() => _TaskBoardFormState();
}

class _TaskBoardFormState extends State<TaskBoardForm> {
  final boardController = BoardController();
  final _taskBoardFormKey = GlobalKey<FormState>();
  String? _name;
  int? _color = 0;

  List<DropdownMenuItem<int>> getMenuItems() {
    var list = <DropdownMenuItem<int>>[];

    for (int i = 0; i < BOARD_COLORS.length; i++) {
      list.add(DropdownMenuItem<int>(
        value: i,
        child: Row(
          children: [
            Icon(Icons.circle, color: BOARD_COLORS[i]['cor']),
            const SizedBox(width: 12),
            Text(BOARD_COLORS[i]['nome'])
          ],
        ),
      ));
    }

    return list;
  }

  void _submit(context) async {
    final form = _taskBoardFormKey.currentState;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (form!.validate()) {
      form.save();

      try {
        if (await boardController.taskBoardExists(_name)) {
          messenger.showSnackBar(
              const SnackBar(content: Text("Já existe um Task Board com esse nome!")));
          return;
        }

        var tb = TaskBoard(name: _name!, color: _color!);
        await boardController.createTaskBoard(tb);
        navigator.pop();

        return;
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var boardNotifier = context.watch<BoardNotifier>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Criar Task Board"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _taskBoardFormKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (value) => _name = value,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'O campo de nome não pode estar vazio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                value: 0,
                items: getMenuItems(),
                onChanged: (value) => setState(() {
                  _color = value;
                }),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () {
                    _submit(context);
                    boardNotifier.updateBoards();
                  },
                  child: const Text('Salvar Task Board'))
            ],
          ),
        ),
      ),
    );
  }
}
