import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import './Priority.dart';
import './todo.dart';
import './TodoDialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Todo List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  bool loaded = false;
  Set<Todo> todos = new Set<Todo>();
  Set<Todo> doneTodos = new Set<Todo>();
  StreamController<Todo> todoStream = StreamController<Todo>();

  @override
  void initState() {
    super.initState();
    todoStream.stream.listen((todo) {
      _showToast('"' +
          todo.name +
          '" has been added as a Todo with ' +
          todo.priority +
          ' priority');
      setState(() {
        todos.add(todo);
        insertTodo(todo);
      });
    });
    openDB().then((_) {
      listTodos().then((allTodos) {
        allTodos.forEach((todo) {
          if (todo.done == 1) {
            doneTodos.add(todo);
          } else {
            todos.add(todo);
          }
        });

        setState(() {
          loaded = true;
        });
      });
    });
  }

  Widget _buildDoneList(BuildContext context) {
    if (!loaded) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[CircularProgressIndicator()]);
    }
    if (doneTodos.length == 0) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text("No todos done!")]);
    }
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: doneTodos.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(doneTodos.elementAt(index).name));
        });
  }

  Widget _buildList(BuildContext context) {
    if (!loaded) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[CircularProgressIndicator()]);
    }
    if (todos.length == 0) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text("No todos remaining!")]);
    }

    List<Todo> sortedTodos = todos.toList();
    sortedTodos.sort((a, b) {
      int p = Priority.PRIORITY_VALUE[a.priority]
          .compareTo(Priority.PRIORITY_VALUE[b.priority]);
      if (p != 0) return p;
      return a.name.compareTo(b.name);
    });

    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: sortedTodos.length,
        itemBuilder: (context, index) {
          final todo = sortedTodos.elementAt(index);
          return Card(
              child: Slidable(
            key: ValueKey(index),
            actionPane: SlidableDrawerActionPane(),
            actions: <Widget>[
              IconSlideAction(
                caption: "Remove",
                color: Colors.red,
                icon: Icons.remove_circle,
                onTap: () {
                  setState(() {
                    removeTodo(todo);
                    todos.remove(todo);
                  });
                },
              )
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: "Done",
                color: Colors.green,
                icon: Icons.done,
                onTap: () {
                  _showToast(
                      'Congratulation on finishing "' + todo.name + '" !');
                  setState(() {
                    doneTodos.add(todo);
                    insertTodo(Todo(todo.name, 1, todo.priority));
                    todos.remove(todo);
                  });
                },
              )
            ],
            child: ListTile(
              title: Text(todo.name),
              trailing: Tooltip(
                message: todo.priority,
                waitDuration: Duration(milliseconds: 1),
                child: Icon(
                  Icons.lens,
                  color: Priority.getColor(todo.priority),
                ),
              ),
            ),
          ));
        });
  }

  void _addTodo() {
    showDialog(
        context: context,
        builder: (context) {
          return TodoDialog(todoStream);
        });
  }

  void _showToast(message) {
    scaffoldState.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Text(
              'Todo',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _buildList(context),
          ),
          Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Done',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        doneTodos.clear();
                        clearTodos();
                        _showToast("Done todos cleared");
                      });
                    },
                  )
                ],
              )),
          Expanded(
            child: _buildDoneList(context),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
