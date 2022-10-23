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

class TimerPage extends StatefulWidget {
  final VoidCallbackAction start;
  TimerPage({super.key, required this.start});

  TimerPageState createState() => TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  final Dependencies dependencies = Dependencies();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dependencies.stopwatch.start();
  }

  void start() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
      } else {
        dependencies.stopwatch.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: TimerText(dependencies: dependencies),
        )
      ],
    );
  }
}

class TimerText extends StatefulWidget {
  TimerText({super.key, required this.dependencies});
  final Dependencies dependencies;

  TimerTextState createState() => TimerTextState(dependencies: dependencies);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({required this.dependencies});
  final Dependencies dependencies;
  late Timer timer;
  int milliseconds = 0;

  @override
  void initState() {
    timer = Timer.periodic(
        Duration(milliseconds: dependencies.timerMillisecondsRefreshRate),
        callback);

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = dependencies.stopwatch.elapsedMilliseconds;
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final ElapsedTime elapsedTime = ElapsedTime(
        hundreds: hundreds,
        seconds: seconds,
        minutes: minutes,
      );
      for (final listener in dependencies.timerListeners) {
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
            height: 72.0,
            child: MinutesAndSeconds(dependencies: dependencies),
          ),
        ),
        RepaintBoundary(
          child: SizedBox(
            height: 72.0,
            child: Hundreds(dependencies: dependencies),
          ),
        ),
      ],
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  MinutesAndSeconds({required this.dependencies});
  final Dependencies dependencies;

  MinutesAndSecondsState createState() =>
      MinutesAndSecondsState(dependencies: dependencies);
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState({required this.dependencies});
  final Dependencies dependencies;

  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
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
    return Text('$minutesStr:$secondsStr.');
  }
}

class Hundreds extends StatefulWidget {
  const Hundreds({required this.dependencies});
  final Dependencies dependencies;

  HundredsState createState() => HundredsState(dependencies: dependencies);
}

class HundredsState extends State<Hundreds> {
  HundredsState({required this.dependencies});
  final Dependencies dependencies;

  int hundreds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
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
    return Text(hundredsStr);
  }
}
