import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model.dart';
import 'widgets.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoList(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'am032 todo list',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'am032 todo list'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textFieldController = TextEditingController();
  final List<Todo> _todos = <Todo>[];

  void _handleTodoChange(Todo todo) {
    setState(() {
      todo.checked = !todo.checked;
    });
  }

  Future<void> _displayDialog(TodoList todoList) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('add todo item'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'type here ...'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                todoList.addTodo(
                    Todo(name: _textFieldController.text, checked: false));
                _textFieldController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoList = Provider.of<TodoList>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: todoList.todos.length,
            itemBuilder: (context, index) {
              return TodoItem(
                todo: todoList.todos[index],
                onTodoChanged: _handleTodoChange,
                onTodoDelete: todoList.toggleTodo,
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(todoList),
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
