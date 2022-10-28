import 'package:flutter/material.dart';

import 'Circle.dart';
import 'utils.dart';

class WinLost {
  final Function restart;
  final bool win;
  final List<Color> currenCombination;
  final int timerElapsedMilliseconds;
  final int? bestTime;
  WinLost(this.restart, this.win, this.currenCombination,
      this.timerElapsedMilliseconds, this.bestTime);
  showAlertDialog(BuildContext context) {
    // set up the buttons
    double height = MediaQuery.of(context).size.height * 0.21;
    Widget resetButton = TextButton(
      child: const Text(textScaleFactor: 1.4, "Restart"),
      onPressed: () {
        restart();
        Navigator.of(context).pop();
      },
    );
    List<Widget> content = [
      Text(
          textAlign: TextAlign.center,
          textScaleFactor: 1.4,
          "${win ? 'Good' : 'Do a better'} job \n "),
      Text(
          textAlign: TextAlign.center,
          textScaleFactor: 1.4,
          "The elapsed time is : ${Utils.formatTime(timerElapsedMilliseconds)}"),
    ];

    if (!win) {
      height = height + 15;
      content.addAll([
        const Text("The right combination is :"),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
              children: List.generate(
                  4, (i) => Circle(40, 40, currenCombination[i]))),
        )
      ]);
    } else {
      String bestTimeText = '';
      if (bestTime != null &&
          (bestTime! / 10).truncate() <
              (timerElapsedMilliseconds / 10).truncate()) {
        bestTimeText =
            "The best time is : \n ${Utils.formatTime(bestTime ?? timerElapsedMilliseconds)}";
      } else {
        bestTimeText = "This is the fastest time !";
      }
      content.add(Text(
        bestTimeText,
        textAlign: TextAlign.center,
        textScaleFactor: 1.4,
      ));
    }
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0))),
      backgroundColor: const Color.fromARGB(255, 236, 224, 224),
      title: Text(
          textAlign: TextAlign.center,
          textScaleFactor: 1.4,
          "You ${win ? 'Won!' : 'Lost'}"),
      content: SizedBox(height: height, child: Column(children: content)),
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
