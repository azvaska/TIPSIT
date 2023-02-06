import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Todo {
  Todo({required this.name, required this.checked, required this.color});
  final String name;
  bool checked;
  Color color;
}

class TodoList with ChangeNotifier {
  final List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  void addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void handleTodoChange(Todo todo, {Color? color}) {
    if (color != null) {
      todo.color = color;
    } else {
      todo.checked = !todo.checked;
    }
    notifyListeners();
  }

  void toggleTodo(Todo todo) {
    final index = _todos.indexOf(todo);
    _todos.removeAt(index);
    notifyListeners();
  }
}
