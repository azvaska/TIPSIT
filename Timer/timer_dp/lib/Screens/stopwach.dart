import 'dart:async';

import 'package:flutter/material.dart';

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;
  final int hours;

  ElapsedTime({
    required this.hundreds,
    required this.seconds,
    required this.minutes,
    required this.hours,
  });
}

class TimerPage extends StatefulWidget {
  static const Duration timerMillisecondsRefreshRate =
      Duration(milliseconds: 30);
  final Duration timerDuration;
  final void Function() cancelTimer;
  const TimerPage(
      {super.key, required this.timerDuration, required this.cancelTimer});

  @override
  TimerPageState createState() => TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  late Stream<ElapsedTime> timeStreams;
  bool reset = false;
  late StreamController<ElapsedTime> controllerTimeConverted;

  late Duration currentRemainingTime;
  late StreamSubscription<int> subscriptionTimerMs;

  late ElapsedTime defaultTime;
//
  Stream<ElapsedTime> convertedTimeStream(Stream<int> timedCounter) {
    subscriptionTimerMs = timedCounter.listen((int ms) {
      controllerTimeConverted.add(convertTime(ms));
    });
    // subscriptionTimerMs.pause();
    // subscriptionTimerMs.pause();
    controllerTimeConverted = StreamController<ElapsedTime>(
        onListen: () => {subscriptionTimerMs.resume()},
        onPause: () => subscriptionTimerMs.pause(),
        onResume: () => subscriptionTimerMs.resume(),
        onCancel: () {
          subscriptionTimerMs.cancel();
        });

    return controllerTimeConverted.stream.asBroadcastStream();
  }

  Stream<int> timedCounter(Duration interval) {
    Timer? timer;
    late StreamController<int> controller;

    void tick(_) {
      currentRemainingTime = currentRemainingTime - interval;
      controller.add(currentRemainingTime
          .inMilliseconds); // Ask stream to send counter values as event.
      if ((currentRemainingTime - interval).inMilliseconds <= 1) {
        controller.add(0);
        timer?.cancel();
        controller.close(); // Ask stream to shut down and tell listeners.
      }
    }

    void startTimerPage() {
      timer = Timer.periodic(interval, tick);
    }

    void stopTimerPage() {
      timer?.cancel();
      timer = null;
    }

    controller = StreamController<int>(
        onListen: startTimerPage,
        onPause: stopTimerPage,
        onResume: startTimerPage,
        onCancel: stopTimerPage);
    return controller.stream;
  }

  @override
  void initState() {
    currentRemainingTime =
        Duration(milliseconds: widget.timerDuration.inMilliseconds);
    defaultTime = convertTime(currentRemainingTime.inMilliseconds);

    timeStreams = convertedTimeStream(
        timedCounter(TimerPage.timerMillisecondsRefreshRate));
    super.initState();
  }

  @override
  void dispose() {
    subscriptionTimerMs.cancel();
    super.dispose();
  }

  // void callback(TimerPage timerPage) {}
  ElapsedTime convertTime(int milliseconds) {
    final int hundreds = (milliseconds / 10).truncate();
    final int seconds = (hundreds / 100).truncate();
    final int minutes = (seconds / 60).truncate();
    final int hours = (minutes / 60).truncate();

    final ElapsedTime elapsedTime = ElapsedTime(
      hundreds: hundreds,
      seconds: seconds,
      minutes: minutes,
      hours: hours,
    );
    return elapsedTime;
  }

  void restartTimer(Duration currentRemainingTime) {
    reset = !reset;
    timeStreams = convertedTimeStream(
        timedCounter(TimerPage.timerMillisecondsRefreshRate));
    subscriptionTimerMs.pause();
    subscriptionTimerMs.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RepaintBoundary(
                child: MinutesAndSeconds(
                  timeStream: timeStreams,
                  defaultTime: defaultTime,
                  key: ValueKey(reset),
                ),
              ),
              RepaintBoundary(
                child: Hundreds(
                    timeStream: timeStreams,
                    defaultTime: defaultTime,
                    key: ValueKey(reset)),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: (() {
                        // subscriptionTimerMs.resume();
                        currentRemainingTime += const Duration(minutes: 1);
                        if (subscriptionTimerMs.isPaused) {
                          setState(() {
                            restartTimer(currentRemainingTime);
                            defaultTime = convertTime(
                                currentRemainingTime.inMilliseconds);
                          });
                        }
                      }),
                      child: const Text("+1 min")),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: (() {
                        setState(() {
                          subscriptionTimerMs.isPaused
                              ? subscriptionTimerMs.resume()
                              : subscriptionTimerMs.pause();
                        });
                      }),
                      child: Text(
                          subscriptionTimerMs.isPaused ? "Start" : "Stop")),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: (() {
                        setState(() {
                          // subscriptionTimerMs.cancel();
                          Future.delayed(const Duration(milliseconds: 0),
                              () async {
                            print(await controllerTimeConverted.close());
                          }).then((value) => {
                                setState(() {
                                  currentRemainingTime = Duration(
                                      milliseconds:
                                          widget.timerDuration.inMilliseconds);

                                  defaultTime = convertTime(
                                      currentRemainingTime.inMilliseconds);
                                  restartTimer(currentRemainingTime);
                                })
                              });
                        });
                      }),
                      child: const Text("Reset")),
                ),
              ),
            ],
          ),
          Center(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: (() {
                          subscriptionTimerMs.cancel();
                          widget.cancelTimer();
                        }),
                        child: const Text("cancel")),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  const MinutesAndSeconds(
      {super.key, required this.timeStream, required this.defaultTime});
  final Stream<ElapsedTime> timeStream;
  final ElapsedTime defaultTime;
  @override
  MinutesAndSecondsState createState() => MinutesAndSecondsState();
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState();
  late StreamSubscription<ElapsedTime> streamSubMinutesAndSeconds;
  int minutes = 0;
  int seconds = 0;
  int hours = 0;
  @override
  void initState() {
    onTick(widget.defaultTime);

    streamSubMinutesAndSeconds = widget.timeStream.listen(onDone: () => print,
        (ElapsedTime elapsedTime) {
      onTick(elapsedTime);
    });
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutes != minutes ||
        elapsed.seconds != seconds ||
        elapsed.hours != hours) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
        hours = elapsed.hours;
      });
    }
  }

  @override
  void dispose() {
    streamSubMinutesAndSeconds.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hoursStr = (hours % 60).toString().padLeft(2, '0');

    return Text(
        style: const TextStyle(color: Colors.black, fontSize: 50),
        '$hoursStr:$minutesStr:$secondsStr.');
  }
}

class Hundreds extends StatefulWidget {
  const Hundreds(
      {super.key, required this.timeStream, required this.defaultTime});
  final Stream<ElapsedTime> timeStream;
  final ElapsedTime defaultTime;

  @override
  HundredsState createState() => HundredsState();
}

class HundredsState extends State<Hundreds> {
  HundredsState();
  late StreamSubscription<ElapsedTime> StreamSubHundreds;

  int hundreds = 0;

  @override
  void initState() {
    onTick(widget.defaultTime);

    StreamSubHundreds = widget.timeStream.listen(onDone: () => print("DIOCAN"),
        (ElapsedTime elapsedTime) {
      onTick(elapsedTime);
    });
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
  void dispose() {
    StreamSubHundreds.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return Text(
        style: const TextStyle(color: Colors.black, fontSize: 50), hundredsStr);
  }
}
