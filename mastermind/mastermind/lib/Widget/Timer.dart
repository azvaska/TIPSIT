import 'package:flutter/material.dart';
import 'dart:async';

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({
    required this.hundreds,
    required this.seconds,
    required this.minutes,
  });
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners =
      <ValueChanged<ElapsedTime>>[];
  final Stopwatch stopwatch = Stopwatch();
  final int timerMillisecondsRefreshRate = 30;
}

class TimerPage extends StatelessWidget {
  final Dependencies dependencies;
  const TimerPage(this.dependencies, {super.key});
  @override
  Widget build(BuildContext context) {
    return TimerText(dependencies: dependencies);
  }
}

class TimerText extends StatefulWidget {
  const TimerText({super.key, required this.dependencies});
  final Dependencies dependencies;

  @override
  TimerTextState createState() => TimerTextState();
}

class TimerTextState extends State<TimerText> {
  TimerTextState();
  late Timer timer;
  int milliseconds = 0;

  @override
  void initState() {
    timer = Timer.periodic(
        Duration(
            milliseconds: widget.dependencies.timerMillisecondsRefreshRate),
        callback);
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != widget.dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = widget.dependencies.stopwatch.elapsedMilliseconds;
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final ElapsedTime elapsedTime = ElapsedTime(
        hundreds: hundreds,
        seconds: seconds,
        minutes: minutes,
      );
      for (final listener in widget.dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RepaintBoundary(
          child: SizedBox(
            height: 65.0,
            child: MinutesAndSeconds(dependencies: widget.dependencies),
          ),
        ),
        RepaintBoundary(
          child: SizedBox(
            height: 65.0,
            child: Hundreds(dependencies: widget.dependencies),
          ),
        ),
      ],
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  const MinutesAndSeconds({super.key, required this.dependencies});
  final Dependencies dependencies;

  @override
  MinutesAndSecondsState createState() => MinutesAndSecondsState();
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState();

  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    widget.dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutes != minutes || elapsed.seconds != seconds) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return Text(
        style: const TextStyle(color: Color.fromARGB(255, 164, 177, 183)),
        textScaleFactor: 1.2,
        '$minutesStr:$secondsStr.');
  }
}

class Hundreds extends StatefulWidget {
  const Hundreds({super.key, required this.dependencies});
  final Dependencies dependencies;

  @override
  HundredsState createState() => HundredsState();
}

class HundredsState extends State<Hundreds> {
  HundredsState();

  int hundreds = 0;

  @override
  void initState() {
    widget.dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.hundreds != hundreds) {
      setState(() {
        hundreds = elapsed.hundreds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return Text(
        textScaleFactor: 1.2,
        style: const TextStyle(color: Color.fromARGB(255, 164, 177, 183)),
        hundredsStr);
  }
}
