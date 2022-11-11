import 'package:flutter/material.dart';

class TimerChangeTimeButton extends StatelessWidget {
  final void Function(Duration time) addTime;
  final Duration time;
  final String textValue;

  const TimerChangeTimeButton(
      {super.key,
      required this.time,
      required this.addTime,
      required this.textValue});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
            onPressed: (() => addTime(time)), child: Text(textValue)),
      ),
    );
  }
}
