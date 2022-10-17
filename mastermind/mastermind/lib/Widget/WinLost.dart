import 'package:flutter/material.dart';

class WinLost extends StatelessWidget {
  final Function restart;
  const WinLost(this.restart, bool win, {super.key});
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget resetButton = TextButton(
      child: Text("Restart"),
      onPressed: () {
        restart();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text(
          "Would you like to continue learning how to use Flutter alerts?"),
      actions: [
        resetButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text('sus');
  }
}
