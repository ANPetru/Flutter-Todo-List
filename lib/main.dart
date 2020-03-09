import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
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
  Set<String> todos = new Set<String>();
  Set<String> doneTodos = new Set<String>();
  StreamController<Todo> todoStream = StreamController<Todo>();

  @override
  void initState() {
    super.initState();
    todoStream.stream.listen((todo) {
      _showToast('"' + todo.name + '" has been added as a Todo');
      setState(() {
        todos.add(todo.name);
        insertTodo(todo);
      });
    });
    openDB().then((_) {
      listTodos().then((allTodos) {
        allTodos.forEach((todo) {
          if (todo.done == 1) {
            doneTodos.add(todo.name);
          } else {
            todos.add(todo.name);
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
          return ListTile(title: Text(doneTodos.elementAt(index)));
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
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: todos.length,
        itemBuilder: (context, index) {
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
                    todos.remove(todos.elementAt(index));
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
                  String element = todos.elementAt(index);
                  _showToast('Congratulation on finishing "' + element + '" !');
                  setState(() {
                    doneTodos.add(element);
                    insertTodo(Todo(element, 1));
                    todos.remove(element);
                  });
                },
              )
            ],
            child: ListTile(
              title: Text(todos.elementAt(index)),
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
