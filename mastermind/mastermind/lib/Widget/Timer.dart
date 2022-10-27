import 'package:flutter/material.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RepaintBoundary(
          child: SizedBox(
            height: 65.0,
            child: MinutesAndSeconds(dependencies: dependencies),
          ),
        ),
        RepaintBoundary(
          child: SizedBox(
            height: 65.0,
            child: Hundreds(dependencies: dependencies),
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
