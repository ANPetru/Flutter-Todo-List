import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './Priority.dart';
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
  String selectedPriority = Priority.MEDIUM;
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
            value: selectedPriority,
            decoration: InputDecoration(labelText: 'Priority'),
            items: <String>[Priority.LOW, Priority.MEDIUM, Priority.HIGH]
                .map((String priority) {
              return DropdownMenuItem<String>(
                value: priority,
                child: Text(priority),
              );
            }).toList(),
            onChanged: (String priority) {
              setState(() {
                selectedPriority = priority;
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
                Todo todo =
                    Todo(_textFieldController.text, 0, selectedPriority);
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
