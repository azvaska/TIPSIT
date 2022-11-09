import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:timer_dp/Screens/numpad.dart';

import 'timerpage.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TextEditingController _myController = TimeTextController();
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
                ),
              ),
            ],
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 120,
                  child: Center(
                      child: TextField(
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
                buttonColor: Colors.purple,
                iconColor: Colors.deepOrange,
                controller: _myController,
                delete: () {
                  _myController.text = "delete";
                },
                // do something with the input numbers
                onSubmit: () {
                  setState(() {
                    timerDuration =
                        parseDuration(_myController.text, separator: ":");
                  });
                },
              ),
            ],
          );
  }
}

class TimeTextController extends TextEditingController {
  String _timeinternal = "";
  static const List<String> separators = ["h", "m", "s"];

  @override
  clear() {
    _timeinternal = "";
    value = const TextEditingValue(
        text: '00h:00m:00s', selection: TextSelection.collapsed(offset: 0));
  }

  @override
  set text(String newText) {
    if (newText.startsWith("0") && _timeinternal.isEmpty) {
      return;
    }
    if (_timeinternal.length >= 6 && newText != "delete") {
      value = value.copyWith(
        text: value.text,
        selection: const TextSelection.collapsed(offset: -1),
        composing: TextRange.empty,
      );
      return;
    }
    if (newText == "delete") {
      if (_timeinternal.isNotEmpty) {
        _timeinternal = _timeinternal.substring(0, _timeinternal.length - 1);
      }
    } else {
      _timeinternal += newText;
    }
    String tempValue = _timeinternal;
    RegExp exp = RegExp(r"\d{2}");
    tempValue = _timeinternal.padLeft(6, '0').splitMapJoin(exp,
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
