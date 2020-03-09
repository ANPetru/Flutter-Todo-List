import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './todo.dart';

class TodoDialog extends StatefulWidget {
  StreamController<Todo> todoStream;
  TodoDialog(StreamController<Todo> todoStream) {
    this.todoStream = todoStream;
  }
  @override
  _TodoDialogState createState() => _TodoDialogState(todoStream);
}

class _TodoDialogState extends State<TodoDialog> {
  TextEditingController _textFieldController = TextEditingController();
  String currentSelectedValue = Priority.medium.toShortString();
  bool _validate = false;
  StreamController<Todo> todoStream;

  _TodoDialogState(StreamController<Todo> todoStream) {
    this.todoStream = todoStream;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Todo'),
      content: Column(
        children: <Widget>[
          TextFormField(
            controller: _textFieldController,
            decoration: InputDecoration(
              labelText: 'Todo',
              errorText: _validate ? 'Please enter a todo' : null,
            ),
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: currentSelectedValue,
            decoration: InputDecoration(labelText: 'Priority'),
            items: <Priority>[Priority.low, Priority.medium, Priority.high]
                .map((Priority priority) {
              String p = priority.toShortString();
              return DropdownMenuItem<String>(
                value: p,
                child: Text(p),
              );
            }).toList(),
            onChanged: (String priority) {
              setState(() {
                currentSelectedValue = priority;
              });
            },
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              _validate = true;
              if (_textFieldController.text.isNotEmpty) {
                Todo todo = Todo(_textFieldController.text, 0);
                _validate = false;
                _textFieldController.text = "";
                Navigator.of(context).pop();
                todoStream.add(todo);
              }
            },
            child: Text('Add'))
      ],
    );
  }
}

enum Priority { low, medium, high }

extension on Priority {
  String toShortString() {
    var a = this.toString().split('.').last;
    return a;
  }
}
