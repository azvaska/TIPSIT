import 'package:flutter/material.dart';

class WinLost {
  final Function restart;
  bool win = false;
  WinLost(this.restart, this.win);
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget resetButton = TextButton(
      child: Text("Restart"),
      onPressed: () {
        restart();
        Navigator.of(context).pop();
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Restart"),
      onPressed: () {
        restart();
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("You ${win ? 'Win' : 'Lost'}"),
      content: const Text("Do you want to restart ?"),
      actions: [resetButton, cancelButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
