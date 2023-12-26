import 'package:flutter/material.dart';
import 'package:planner_app/model/task_board.dart';
import 'package:planner_app/providers/session.dart';

import 'package:planner_app/controller/task_controller.dart';
import 'package:planner_app/providers/notifiers.dart';
import 'package:provider/provider.dart';
import '../../controller/board_controller.dart';

import '../../misc/color_map.dart';

class Dashboard extends StatefulWidget {
  final Session session;
  const Dashboard({super.key, required this.session});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final boardController = BoardController();
  final taskController = TaskController();

  late List<TaskBoard> _taskBoards = [];
  late Map<int, int> _taskAmounts = {};

  Future<void> fetchBoardsData() async {
    _taskBoards = await boardController.getAllTaskBoards();
    _taskAmounts = await taskController.countTasks(widget.session.getSessionUserId()!);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardNotifier>(builder: (context, boardNotifier, child) {
      return FutureBuilder(
          future: fetchBoardsData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Text("Loading...");
            } else if (snapshot.hasError) {
              return const Text("Não foi possível recuperar os Task Boards");
            }
            boardNotifier.boards = _taskBoards;
            return ListView(children: [
              for (var bc in _taskBoards.map<BoardCard>((tb) {
                return BoardCard(
                  tb: tb,
                  tasksAmount: (_taskAmounts[tb.id!] ?? 0).toString(),
                );
              }))
                bc,
            ]);
          });
    });
  }
}

class BoardCard extends StatelessWidget {
  BoardCard({super.key, required this.tb, required this.tasksAmount});

  final TaskBoard tb;
  final TaskController taskController = TaskController();
  final String? tasksAmount;

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardNotifier>(builder: (context, boardNotifier, child) {
      return ListTile(
        leading: Icon(Icons.circle, color: BOARD_COLORS[tb.color]['cor']),
        title: Text(tb.name),
        subtitle: Text('$tasksAmount tarefas'),
        trailing: IconButton(
            onPressed: () {
              boardNotifier.currentBoard = tb;
              Navigator.pushNamed(context, '/board');
            },
            icon: const Icon(Icons.arrow_outward)),
      );
    });
  }
}
