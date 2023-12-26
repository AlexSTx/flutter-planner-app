import '../helper/database_helper.dart';

import '../model/user.dart';

class UserController {
  DatabaseHelper connection = DatabaseHelper();

  Future<int> createUser(User user) async {
    var db = await connection.db;
    int res = await db.insert('user', user.toMap());
    return res;
  }

  Future<int> deleteUser(User user) async {
    var db = await connection.db;
    int res = await db.delete("user", where: "id = ?", whereArgs: [user.id]);
    return res;
  }

  Future<User?> getLogin(String email, String password) async {
    var db = await connection.db;
    String query = """SELECT * FROM user WHERE email='$email' AND password='$password'""";

    var result = await db.rawQuery(query);

    if (result.isEmpty) return null;

    return User.fromMap(result.first);
  }

  Future<bool> userExists(String email) async {
    var db = await connection.db;
    String query = "SELECT * FROM user WHERE email='$email'";
    var result = await db.rawQuery(query);
    return (result.isNotEmpty);
  }
}
