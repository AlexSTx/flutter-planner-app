import '../helper/database_helper.dart';
import '../model/task_board.dart';

class BoardController {
  DatabaseHelper connection = DatabaseHelper();

  Future<int> createTaskBoard(TaskBoard board) async {
    var db = await connection.db;
    int res = await db.insert('task_board', board.toMap());
    return res;
  }

  Future<int> deleteTaskBoard(TaskBoard board) async {
    var db = await connection.db;
    int res = await db.delete("task_board", where: "id = ?", whereArgs: [board.id]);
    return res;
  }

  Future<List<TaskBoard>> getAllTaskBoards() async {
    var db = await connection.db;
    var boards = <TaskBoard>[];

    String query = "SELECT * FROM task_board";

    var result = await db.rawQuery(query);

    for (var tuple in result) {
      boards.add(TaskBoard.fromMap(tuple));
    }

    return boards;
  }

  Future<bool> taskBoardExists(String? name) async {
    if (name == null) return false;

    var db = await connection.db;
    String query = "SELECT * FROM task_board WHERE name='$name'";
    var result = await db.rawQuery(query);

    return result.isNotEmpty;
  }
}
