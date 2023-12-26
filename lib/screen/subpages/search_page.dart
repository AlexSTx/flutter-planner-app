import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner_app/components/tasks_view.dart';
import 'package:planner_app/controller/task_controller.dart';
import 'package:planner_app/model/task.dart';
import 'package:planner_app/providers/session.dart';

class Search extends StatefulWidget {
  const Search({super.key, required this.session});

  final Session session;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _textDateController = TextEditingController();
  late Future<List<Task>> _searchResult;
  String? stringDate;

  final taskController = TaskController();

  @override
  void initState() {
    _searchResult = taskController.fetchUserTasks(-1);
    _textDateController.addListener(() {
      stringDate = _textDateController.text.replaceAll('/', '-');
      setState(() {
        _searchResult =
            taskController.fetchUserTasks(widget.session.session!.id!, date: stringDate);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _textDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Column(
            children: [
              TextFormField(
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                    labelText: 'Pesquisa por Data',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month)),
                controller: _textDateController,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: DateTime(2999, 12, 31));

                  _textDateController.text =
                      DateFormat('yyyy/MM/dd').format(date ?? DateTime.now());
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira alguma data para pesquisar';
                  }
                  return null;
                },
              ),
              FutureBuilder(
                  future: _searchResult,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Text('Loading...');
                    } else if (snapshot.hasData) {
                      var data = snapshot.data;
                      return TasksView(tasks: data, boards: const []);
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      return const Text("Sem Dados");
                    }
                  }),
            ],
          )
        ],
      ),
    );
  }
}
