import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:timer_dp/Screens/numpad.dart';

import 'timerpage.dart';

class TimerScreen extends StatefulWidget {
  final bool isTimer;

  const TimerScreen({super.key, this.isTimer = true});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TimeTextController _myController = TimeTextController();
  Duration? timerDuration;
  void cancelTimer() {
    setState(() {
      timerDuration = null;
      _myController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return timerDuration != null
        ? Column(
            children: [
              Expanded(
                child: TimerPage(
                  timerDuration: timerDuration!,
                  cancelTimer: cancelTimer,
                  isTimer: widget.isTimer,
                ),
              ),
            ],
          )
        : Column(
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                      ),
                      "Timer"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: SizedBox(
                  height: 120,
                  child: Center(
                      child: TextField(
                    enableInteractiveSelection: false,
                    controller: _myController,
                    textAlign: TextAlign.center,
                    showCursor: false,
                    style: const TextStyle(fontSize: 40),
                    // Disable the default soft keybaord
                    keyboardType: TextInputType.none,
                  )),
                ),
              ),
              // implement the custom NumPad
              NumPad(
                buttonSize: 85,
                buttonColor: const Color.fromARGB(255, 19, 64, 186),
                iconColor: const Color.fromARGB(247, 5, 25, 79),
                controller: _myController,
                delete: () {
                  _myController.text = "delete";
                },
                // do something with the input numbers
                onSubmit: () {
                  setState(() {
                    if (_myController.realTimeStr.isNotEmpty) {
                      timerDuration =
                          parseDuration(_myController.text, separator: ":");
                    }
                  });
                },
              ),
            ],
          );
  }
}

class TimeTextController extends TextEditingController {
  String realTimeStr = "";
  static const List<String> separators = ["h", "m", "s"];

  @override
  clear() {
    realTimeStr = "";
    value = const TextEditingValue(
        text: '00h:00m:00s', selection: TextSelection.collapsed(offset: 0));
  }

  @override
  set text(String newText) {
    if (realTimeStr.length >= 6 && newText != "delete") {
      value = value.copyWith(
        text: value.text,
        selection: const TextSelection.collapsed(offset: -1),
        composing: TextRange.empty,
      );
      return;
    }
    if ((newText.startsWith("0") && realTimeStr.isEmpty) ||
        (newText.startsWith("00") && realTimeStr.length == 5)) {
      return;
    }
    if (newText == "delete") {
      if (realTimeStr.isNotEmpty) {
        realTimeStr = realTimeStr.substring(0, realTimeStr.length - 1);
      }
    } else {
      realTimeStr += newText;
    }
    String tempValue = realTimeStr;
    RegExp exp = RegExp(r"\d{2}");
    tempValue = realTimeStr.padLeft(6, '0').splitMapJoin(exp,
        onMatch: (m) => "${m.group(0)}${separators[m.start ~/ 2]}:");
    tempValue = tempValue.substring(0, tempValue.length - 1);
    value = value.copyWith(
      text: tempValue,
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  TimeTextController() {
    super.text = '00h:00m:00s';
  }
}
