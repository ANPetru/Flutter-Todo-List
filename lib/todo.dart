import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> database;

Future<void> openDB() async {
  database = openDatabase(join(await getDatabasesPath(), 'todo.db'),
      onCreate: (db, version) {
    return db.execute(
        'CREATE TABLE todo(name TEXT PRIMARY KEY, done INTEGER, priority TEXT)');
  }, version: 1);
}

Future<void> insertTodo(Todo todo) async {
  final Database db = await database;

  await db.insert('todo', todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<void> removeTodo(Todo todo) async {
  final Database db = await database;

  await db.delete('todo', where: "name = ?", whereArgs: [todo.name]);
}

Future<void> clearTodos() async {
  final Database db = await database;

  await db.delete('todo', where: "done = 1");
}

Future<List<Todo>> listTodos() async {
  final Database db = await database;

  final List<Map<String, dynamic>> maps = await db.query('todo');
  return List.generate(maps.length, (i) {
    return Todo(maps[i]['name'], maps[i]['done'], maps[i]['priority']);
  });
}

class Todo {
  String name;
  int done;
  String priority;

  Todo(String name, int done, String priority) {
    this.name = name;
    this.done = done;
    this.priority = priority;
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'done': done, 'priority': priority};
  }
}
