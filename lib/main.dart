import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import './todo.dart';

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
  @override
  void initState() {
    super.initState();
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

  TextEditingController _textFieldController = TextEditingController();
  final scaffoldState = GlobalKey<ScaffoldState>();
  bool _validate = false;
  bool loaded = false;
  Set<String> todos = new Set<String>();
  Set<String> doneTodos = new Set<String>();

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
          return AlertDialog(
            title: Text('New Todo'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(
                  hintText: "Todo...",
                  errorText: _validate ? 'Please enter a todo' : null),
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    _validate = true;
                    if (_textFieldController.text.isNotEmpty) {
                      String todo = _textFieldController.text;
                      _validate = false;
                      _showToast('"' + todo + '" has been added as a Todo');
                      setState(() {
                        todos.add(todo);
                        insertTodo(Todo(todo, 0));
                      });
                      _textFieldController.text = "";
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Add'))
            ],
          );
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
