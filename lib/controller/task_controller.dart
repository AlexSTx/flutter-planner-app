import 'package:planner_app/model/date_range.dart';

import '../helper/database_helper.dart';

import '../model/task.dart';

class TaskController {
  DatabaseHelper connection = DatabaseHelper();

  Future<int> createTask(Task task) async {
    var db = await connection.db;
    int res = await db.insert('task', task.toMap());
    return res;
  }

  Future<int> deleteTask(Task task) async {
    var db = await connection.db;
    int res = await db.delete("task", where: "id = ?", whereArgs: [task.id]);
    return res;
  }

  Future<int> deleteTasks(List<Task> tasks) async {
    var db = await connection.db;
    var ids = tasks.map<int>((task) => task.id!).toList();
    int res = await db.delete("task",
        where: 'id IN (${List.filled(ids.length, '?').join(',')})', whereArgs: ids);
    return res;
  }

  Future<List<Task>> fetchUserTasks(int userId,
      {int? boardId, bool? completed, DateRange? dateRange, String? date}) async {
    var db = await connection.db;

    String query = """SELECT * FROM task 
          WHERE user_id = '$userId' 
          ${boardId != null ? "and board_id = '$boardId'" : ""} 
          ${completed != null ? "and isCompleted = ${completed ? 1 : 0}" : ""}
          ${dateRange != null ? "and startTime BETWEEN '${dateRange.hStartDate}' AND '${dateRange.hEndDate}'" : ""}
          ${date != null ? "and startTime >= '$date' and startTime < date('$date', '+1 day')" : ""}
          ORDER BY startTime
        ;""";

    var res = await db.rawQuery(query);
    return res.map<Task>((touple) => Task.fromMap(touple)).toList();
  }

  Future<Map<int, int>> countTasks(int userId, {int? boardId}) async {
    var db = await connection.db;

    String query =
        'SELECT board_id, count(*) as qtd FROM task WHERE user_id = $userId ${boardId != null ? "AND board_id = $boardId" : ""} GROUP BY board_id';

    var res = await db.rawQuery(query);
    var map = <int, int>{};

    for (var t in res) {
      map[t['board_id'] as int] = t['qtd'] as int;
    }
    return map;
  }

  Future<Map<String, List<int>>> getColorsByDate(int userId, DateRange dateRange) async {
    var db = await connection.db;

    String query =
        """SELECT startTime, color FROM task left join task_board on task.board_id = task_board.id where task.user_id = $userId and startTime BETWEEN '${dateRange.hStartDate}' AND '${dateRange.hEndDate}'
        group by startTime, color""";

    var res = await db.rawQuery(query);

    Map<String, List<int>> map = {};
    String sDate;

    for (var t in res) {
      sDate = (t['startTime'] as String).substring(0, 10);
      if (map.containsKey(sDate)) {
        map[sDate]!.add(t['color'] as int);
      } else {
        map[sDate] = [t['color'] as int];
      }
    }

    return map;
  }

  Future<int> updateTask(Task task) async {
    var db = await connection.db;
    int res = await db.update('task', task.toMap(), where: "id = '${task.id}'");
    task.changesSaved();
    return res;
  }

  Future<void> updateTasks(List<Task>? tasks) async {
    if (tasks == null) return;

    var db = await connection.db;
    for (var task in tasks) {
      if (task.wasModified) {
        await db.update('task', task.toMap(), where: "id = '${task.id}'");
        task.changesSaved();
      }
    }
  }
}
