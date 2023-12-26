import "dart:convert";

import 'package:planner_app/model/date_range.dart';

class Task {
  final int? id;
  final int userId;
  int boardId;
  String title;
  String note;
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  bool isCompleted;
  bool _wasModified = false;

  void modify() {
    _wasModified = true;
  }

  void changesSaved() {
    _wasModified = false;
  }

  get wasModified => _wasModified;

  get taskDateRange => DateRange(today: date, startDate: startTime, endDate: endTime);

  get sameDay {
    return startTime.year == endTime.year &&
        startTime.month == endTime.month &&
        startTime.day == endTime.day;
  }

  void updateFromDateRange(DateRange dr) {
    date = dr.today ?? date;
    startTime = dr.startDate ?? startTime;
    endTime = dr.endDate ?? endTime;
    modify();
  }

  Task(
      {this.id,
      required this.userId,
      required this.boardId,
      required this.title,
      required this.note,
      required this.date,
      required this.startTime,
      required this.endTime,
      required this.isCompleted});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "user_id": userId,
      "board_id": boardId,
      "title": title,
      "note": note,
      "date": date.toString(),
      "startTime": startTime.toString(),
      "endTime": endTime.toString(),
      "isCompleted": isCompleted ? 1 : 0,
    };
  }

  factory Task.clone(Task orig) {
    return Task(
      id: orig.id,
      userId: orig.userId,
      boardId: orig.boardId,
      title: orig.title,
      note: orig.note,
      date: orig.date,
      startTime: orig.startTime,
      endTime: orig.endTime,
      isCompleted: orig.isCompleted,
    );
  }

  void updateTaskFromClone(Task clone) {
    boardId = clone.boardId;
    title = clone.title;
    note = clone.note;
    date = clone.date;
    startTime = clone.startTime;
    endTime = clone.endTime;
    isCompleted = clone.isCompleted;

    modify();
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
        id: map["id"],
        userId: map["user_id"],
        boardId: map["board_id"],
        title: map["title"],
        note: map["note"],
        date: DateTime.parse(map["date"]),
        startTime: DateTime.parse(map["startTime"]),
        endTime: DateTime.parse(map["endTime"]),
        isCompleted: map["isCompleted"] == 1);
  }

  String toJson() => jsonEncode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
