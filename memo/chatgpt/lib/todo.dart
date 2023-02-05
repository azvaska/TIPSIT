import 'package:flutter/foundation.dart';

class Todo {
  final String title;
  bool isDone;

  Todo({required this.title, this.isDone = false});
}

class TodoList with ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  void addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void toggleTodo(Todo todo) {
    final index = _todos.indexOf(todo);
    _todos[index].isDone = !_todos[index].isDone;
    notifyListeners();
  }
}
