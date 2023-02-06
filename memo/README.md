# am069_todo_list
Questo progetto e' un upgrade con la centralizzatone dello stato di [questa](https://gitlab.com/divino.marchese/flutter/-/tree/master/am032_todo_list) app <br>

## model

La classe 
```dart
class Todo {
  Todo({required this.name, required this.checked, required this.color});
  final String name;
  bool checked;
  Color color;
}
```
definisce il *model* per gli *item*.

## la Classe che tiene lo stato
```dart
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

```
# Color picker  
Inoltre e' stata aggiunta la possibilita di impostare un colore della memo
```dart
ColorPicker(
                pickerColor: currentColor, //default color
                onColorChanged: (Color color) {
                  //on color picked
                  currentColor = color;
                },
              )
```
# References

[Provider](https://pub.dev/packages/provider)
[flutter_colorpicker](https://pub.dev/packages/flutter_colorpicker)