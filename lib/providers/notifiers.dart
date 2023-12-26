import 'package:flutter/material.dart';
import 'package:planner_app/model/task.dart';
import 'package:planner_app/model/task_board.dart';

class BoardNotifier extends ChangeNotifier {
  bool _wereBoardsUpdated = false;
  bool _mustRecount = false;
  List<TaskBoard> boards = [];
  TaskBoard? currentBoard;

  void updateBoards() {
    _wereBoardsUpdated = true;
    notifyListeners();
  }

  bool get wereBoardsUpdated {
    return _wereBoardsUpdated;
  }

  TaskBoard? getBoard(int boardId) {
    return boards.firstWhere((element) => boardId == element.id);
  }

  void changesDone() {
    _wereBoardsUpdated = false;
  }

  get mustRecount => _mustRecount;

  void recount() {
    notifyListeners();
    _mustRecount = true;
  }

  void recounted() {
    _mustRecount = false;
  }
}

class TaskNotifier extends ChangeNotifier {
  bool _wereTasksUpdated = false;
  bool _wasATaskCreated = false;
  List<Task> tasks = [];
  Task? currentTask;
  DateTime? currentDate;

  void updatedTask() {
    _wereTasksUpdated = true;
    notifyListeners();
  }

  bool get wereTasksUpdated {
    return _wereTasksUpdated;
  }

  void createdTask() {
    _wasATaskCreated = true;
    notifyListeners();
  }

  void taskUpdatesSaved() {
    _wereTasksUpdated = false;
  }

  void taskCreationsSaved() {
    _wasATaskCreated = false;
  }

  bool get wasATaskCreated {
    return _wasATaskCreated;
  }

  void deleteTask(Task task) {
    tasks.remove(task);
    notifyListeners();
  }

  void clearTasks() {
    tasks.clear();
    notifyListeners();
  }
}
