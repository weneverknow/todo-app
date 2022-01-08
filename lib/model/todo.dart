import 'package:local_database_example/extension/string_extension.dart';

import '../constant.dart';

class Todo {
  final int? id;
  final String? title;
  final String? description;
  final String? date;
  final String? time;
  final int? done;
  final String userId;

  Todo(
      {this.id,
      this.title,
      this.done = 0,
      this.date,
      this.time,
      this.description,
      required this.userId});

  Todo copyWith(
      {int? id,
      String? title,
      int? done,
      String? description,
      String? date,
      String? time}) {
    return Todo(
        userId: userId,
        id: id ?? this.id,
        title: title ?? this.title,
        done: done ?? this.done,
        description: description ?? this.description,
        date: date ?? this.date,
        time: time ?? this.time);
  }

  Map<String, dynamic> toMap(Todo todo) {
    var map = {
      COLUMN_TITLE: todo.title,
      COLUMN_DONE: todo.done,
      COLUMN_DATE: todo.date,
      COLUMN_DESC: todo.description,
      COLUMN_TIME: todo.time,
      COLUMN_USER: todo.userId
    };
    if (todo.id != null) {
      map[COLUMN_ID] = todo.id;
    }
    return map;
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
        userId: map[COLUMN_USER],
        id: map[COLUMN_ID],
        title: map[COLUMN_TITLE],
        done: map[COLUMN_DONE],
        description: map[COLUMN_DESC],
        date: map[COLUMN_DATE],
        time: map[COLUMN_TIME]);
  }

  static DateTime toDateTime(Todo todo) {
    return DateTime.parse(
        '${todo.date!} ${todo.time!.getHour()}:${todo.time!.getMinute()}:00');
  }
}
