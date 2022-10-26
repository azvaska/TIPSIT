import 'package:flutter/material.dart';

import 'Circle.dart';

class WinLost {
  final Function restart;
  bool win;
  List<Color> currenCombination;
  WinLost(this.restart, this.win, this.currenCombination);
  showAlertDialog(BuildContext context) {
    // set up the buttons
    double height = MediaQuery.of(context).size.height * 0.07;
    Widget resetButton = TextButton(
      child: const Text(textScaleFactor: 1.4, "Restart"),
      onPressed: () {
        restart();
        Navigator.of(context).pop();
      },
    );
    List<Widget> content = [
      Text(textScaleFactor: 1.4, "${win ? 'Good' : 'Do a better'} job \n ")
    ];
    if (!win) {
      height = height + 80;
      content.addAll([
        const Text("The right combination is :"),
        Row(
            children:
                List.generate(4, (i) => Circle(40, 40, currenCombination[i])))
      ]);
    }
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.grey,
      title: Text(
          textAlign: TextAlign.center,
          textScaleFactor: 1.4,
          "You ${win ? 'Win' : 'Lost'}"),
      content: SizedBox(
        height: height,
        child: Column(children: content),
      ),
      actions: [resetButton],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
