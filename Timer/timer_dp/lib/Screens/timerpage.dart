import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:timer_dp/Screens/time_button.dart';

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
  static const int timerMillisecondsRefreshRate = 30;
  final Duration timerDuration;
  final void Function() cancelTimer;
  final bool isTimer;
  void cancelTimerdef() {}
  const TimerPage(
      {super.key,
      this.timerDuration = const Duration(milliseconds: 0),
      required this.cancelTimer,
      required this.isTimer});

  @override
  TimerPageState createState() => TimerPageState();
}

class TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  late Stream<ElapsedTime> timeStreams;
  bool reset = false;
  static const alertStyle = TextStyle(
    fontSize: 25,
    color: Colors.white,
  );
  late StreamController<ElapsedTime> controllerTimeConverted;

  late int currentRemainingTimeMs;
  late StreamSubscription<int> subscriptionTimerMs;

  late ElapsedTime defaultTime;

//
  Stream<ElapsedTime> convertedTimeStream(Stream<int> timedCounter) {
    subscriptionTimerMs = timedCounter.listen((int ms) {
      controllerTimeConverted.add(convertTime(ms));
    });
    if (!widget.isTimer) {
      subscriptionTimerMs.pause();
      subscriptionTimerMs.pause();
    }

    controllerTimeConverted = StreamController<ElapsedTime>(
        onListen: () => {subscriptionTimerMs.resume()},
        onPause: () => subscriptionTimerMs.pause(),
        onResume: () => subscriptionTimerMs.resume(),
        onCancel: () {
          subscriptionTimerMs.cancel();
        });

    return controllerTimeConverted.stream.asBroadcastStream();
  }

  Stream<int> timedCounter(int interval, bool isTimer) {
    Timer? timer;

    late StreamController<int> controller;

    void tickDown(_) {
      currentRemainingTimeMs = currentRemainingTimeMs - interval;
      controller.add(
          currentRemainingTimeMs); // Ask stream to send counter values as event.
      if ((currentRemainingTimeMs - interval) <= 1) {
        FlutterRingtonePlayer.play(
            looping: true,
            asAlarm: true,
            fromAsset: "assets/audio/loud_indian_music.mp3");
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: const Color.fromARGB(255, 42, 81, 187),
                title: const Text("Timer", style: alertStyle),
                content: const Text(style: alertStyle, "Timer has finished"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      FlutterRingtonePlayer.stop();
                    },
                    child: const Text("OK", style: alertStyle),
                  ),
                ],
              );
            });

        controller.add(0);
        timer?.cancel();
        controller.close(); // Ask stream to shut down and tell listeners.
      }
    }

    void tickUp(_) {
      currentRemainingTimeMs = currentRemainingTimeMs + interval;
      controller.add(
          currentRemainingTimeMs); // Ask stream to send counter values as event.
    }

    void startTimerPage() {
      timer = Timer.periodic(
          Duration(milliseconds: interval), isTimer ? tickDown : tickUp);
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
    currentRemainingTimeMs = widget.timerDuration.inMilliseconds;
    defaultTime = convertTime(currentRemainingTimeMs);
    timeStreams = convertedTimeStream(
        timedCounter(TimerPage.timerMillisecondsRefreshRate, widget.isTimer));
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      FlutterRingtonePlayer.stop();
    }
  }

  @override
  void dispose() {
    subscriptionTimerMs.cancel();
    WidgetsBinding.instance.removeObserver(this);
    FlutterRingtonePlayer.stop();
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

  void restartTimer() {
    reset = !reset;
    timeStreams = convertedTimeStream(
        timedCounter(TimerPage.timerMillisecondsRefreshRate, widget.isTimer));
    if (widget.isTimer) {
      subscriptionTimerMs.pause();
      subscriptionTimerMs.pause();
    }
  }

  void addTime(Duration time) {
    currentRemainingTimeMs += time.inMilliseconds;
    if (subscriptionTimerMs.isPaused) {
      setState(() {
        restartTimer();
        defaultTime = convertTime(currentRemainingTimeMs);
      });
    }
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
          Visibility(
              visible: widget.isTimer,
              child: Row(
                children: [
                  TimerChangeTimeButton(
                    time: const Duration(minutes: -1),
                    addTime: addTime,
                    textValue: "-1 min",
                  ),
                  TimerChangeTimeButton(
                    time: const Duration(seconds: -30),
                    addTime: addTime,
                    textValue: "-30 sec",
                  ),
                  TimerChangeTimeButton(
                    time: const Duration(seconds: 30),
                    addTime: addTime,
                    textValue: "+30 sec",
                  ),
                  TimerChangeTimeButton(
                    time: const Duration(minutes: 1),
                    addTime: addTime,
                    textValue: "+1 min",
                  ),
                ],
              )),
          Row(
            children: [
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
                            await controllerTimeConverted.close();
                          }).then((value) => {
                                setState(() {
                                  currentRemainingTimeMs =
                                      widget.timerDuration.inMilliseconds;

                                  defaultTime =
                                      convertTime(currentRemainingTimeMs);
                                  restartTimer();
                                })
                              });
                        });
                      }),
                      child: const Text("Reset")),
                ),
              ),
            ],
          ),
          Visibility(
              visible: widget.isTimer,
              child: Center(
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
              ))
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
    String hoursStr = (hours).toString().padLeft(2, '0');

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
