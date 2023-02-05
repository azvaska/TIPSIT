# am032_todo_list

**[221211]** L'app è completamente rifatta. Usiamo una `StatefulWidget` il cui stato è dato da
```dart
final TextEditingController _textFieldController = TextEditingController();
final List<Todo> _todos = <Todo>[];
```

## model

La classe 
```dart
class Todo {
  Todo({required this.name, required this.checked});
  final String name;
  bool checked;
}
```
definisce il *model* per gli *item*.

## dialog

Il metodo `showDialog<T>` permette, appunto di mostrare un *dialog*
```
barrierDismissible: false,
```
sta ad indicare che il *dialog* resta visibile anche se tocchiamo fuori da esso. La classe `AlertDialog` è la classe *basic* per i *dialog* in *Material Design*, invitiamo alla lettura delle API [qui](https://api.flutter.dev/flutter/material/AlertDialog-class.html). L'istruzione
```dart
Navigator.pop(context);
```
l'abbiamo vista all'opera col *router*.

## la lista

**NB** Questo è un esempio di come agire sullo stato di un *widget* con stato passando ai discendenti un metodo come argom,ento! Al posto del *builder* potremmo scrivere
```dart
ListView(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    children: _todos.map((Todo todo) {
        return TodoItem(
            todo: todo,
            onTodoChanged: _handleTodoChange,
            onTodoDelete: _handleTodoDelete,
        );
    }).toList(),
))
```

## l'item

Legare a *widget* di uno stesso tipo valori di `key` differenti è importante, qui scegliamo
```dart
: super(key: ObjectKey(todo));
```
Per passare le azioni al singolo elemento della lista creiaomo una `StateLessWidget` e costruiamo dentro un `ListTile`.