import 'dart:convert';

class TaskBoard {
  int? id;
  String name;
  int color;
  bool _wasModified = false;

  void modify() {
    _wasModified = true;
  }

  void changesSaved() {
    _wasModified = false;
  }

  get wasModified => _wasModified;

  TaskBoard({this.id, required this.name, required this.color});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{"id": id, "name": name, "color": color};
  }

  factory TaskBoard.fromMap(Map<String, dynamic> map) {
    return TaskBoard(id: map["id"], name: map["name"], color: map["color"]);
  }

  String toJson() => jsonEncode(toMap());

  factory TaskBoard.fromJson(String source) =>
      TaskBoard.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
