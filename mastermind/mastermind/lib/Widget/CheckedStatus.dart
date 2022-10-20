import 'package:flutter/material.dart';
import 'package:mastermind/Widget/Hints.dart';

class CheckedStatus extends StatelessWidget {
  bool checked = false;
  List<Color> hints;
  CheckedStatus(this.checked, this.hints);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: checked && hints.isNotEmpty
          ? Hints(hints)
          : Container(
              width: 55.0,
              height: 55.0,
              margin: const EdgeInsets.fromLTRB(15, 0, 10, 0),
              padding: const EdgeInsets.all(
                  0.0), //I used some padding without fixed width and height
              decoration: const BoxDecoration(
                shape: BoxShape
                    .circle, // You can use like this way or like the below line
                //borderRadius: new BorderRadius.circular(30.0),
                color: Colors.green,
              ),
              child: const Icon(
                Icons.done,
                color: Colors.white,
              )),
    );
  }
}
