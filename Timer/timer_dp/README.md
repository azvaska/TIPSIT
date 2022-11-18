# Timer
A simple application where you can create a timer or use a stopwach
## Additional Features
- Stopwach
- AlarmSound
## In depth
### Time
The timer has been implemented thought 2 streams, the real timer stream is implemented with the ```Timer.Periodic``` that acts as a ticker
while the other stream is a transformation from every tick  to an ElapsedTime object
```dart
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
```
That will then be rendered by two different widgets for performance reasons this is achived tanks to the widget ```RepaintBoundary```, one for hours minutes and seconds the other one the milliseconds.
<br>
```dart
  static const int timerMillisecondsRefreshRate = 16;
```
the tick is repeted every 16ms since flutter is optimized for max 60fps
The streams are implemented like this:
```dart
  Stream<int> timedCounter(int interval, bool isTimer) {
    Timer? timer;
    late StreamController<int> controller;

    void tickDown(_) {
      currentRemainingTimeMs = currentRemainingTimeMs - interval;
      controller.add(
          currentRemainingTimeMs); // Ask stream to send currentime value as an event.
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
```

To transform the tick into an object that will then be then showed in the ui
```dart
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
```

The widgets that will show the value they subscribe to the stream that generates the ```ElapsedTime``` is like this:
```dart
@override
  void initState() {
    onTick(widget.defaultTime);

    streamSubMinutesAndSeconds = widget.timeStream.listen(
        (ElapsedTime elapsedTime) {
      onTick(elapsedTime);
    });
    super.initState();
  }
```
The function onTick for example in the widgets that manages the minutes and seconds is like this:
```dart
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
```

# References
[StreamController](https://api.dart.dev/stable/2.18.4/dart-async/StreamController-class.html)
<br>
[Timer](https://api.dart.dev/stable/2.18.4/dart-async/Timer-class.html)
<br>
[flutterRingtonePlayer](https://pub.dev/packages/flutter_ringtone_player)
