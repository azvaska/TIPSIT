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
That will then be rendered by two different widgets for performance reasons this is achived tanks to the widget ```RepaintBoundary```.
<br>
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



```dart
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
```
The widgets that will show the value they subscribe to the ``` Timer.periodic()``` is like this:
```dart
@override
void initState() {
  widget.dependencies.timerListeners.add(onTick);
  super.initState();
}
```
The function onTick for example in the widgets that manages the minutes and seconds is like this:
```dart
void onTick(ElapsedTime elapsed) {
  if (elapsed.minutes != minutes || elapsed.seconds != seconds) {
    setState(() {
      minutes = elapsed.minutes;
      seconds = elapsed.seconds;
    });
  }
}
```

### BestTime
Thanks to the class ```SharedPreferences``` we can save the best time easily and retrieve it back.
```dart
int bestTime = min(prefs.getIn(Utils.bestTimeKey) ?? Utils.maxInt,
    timerController.stopwatch.elapsedMilliseconds);
Future.delayed(Duration.zero, () async {
  await prefs.setInt(Utils.bestTimeKey, bestTime);
});
This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

default timer -> 10-15-20m
suoneria quando e' finito

