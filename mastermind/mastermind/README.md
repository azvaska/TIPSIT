# Mastermind

A guessing game.
<br>
Lean what it is about
[here](https://en.wikipedia.org/wiki/Mastermind_(board_game))
## Additional Features
- Variable number of rows for the guess
- Possibility to disable duplicated colors in the combination
- Stopwatch for the match and the best time through all the games

## In depth
### Stopwatch
The stopwatch has been implemented thought the ```Stopwatch``` class and ``` Timer.periodic()``` is used for telling the UI that it should probably update.
<br>
For performance reasons the minutes and seconds widgets are separated from the microseconds and also the repaint are isolated thanks to the widget 
```RepaintBoundary```.
<br>
This is not the most efficient setup since I don't stop the ``` Timer.periodic()``` if for example the user opens the settings or exits the app, so it will call even when the timer is supposedly stopped, to mitigate I check if the value of the stopwatch is changed if the function just exits.
The function otherwise I create an object with all the time information that all the subscribed listeners will receive, and they will reload the UI if the value is different.
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
```
With Utils as:
```dart
class Utils {
  static const int maxInt = 0x7fffffffffffffff;
  static const bestTimeKey = 'besttime';

  static String formatTime(int milliseconds) {
    final int hundreds = (milliseconds / 10).truncate();
    final int seconds = (hundreds / 100).truncate();
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String minutesStr =
        ((seconds / 60).truncate() % 60).toString().padLeft(2, '0');
    return "$minutesStr:$secondsStr.$hundredsStr";
  }
}
```
```0x7fffffffffffffff``` is the biggest integer that dart can handle we use that value when the ```bestTime``` on the disk is null.

### Settings
For the settings a new screen is created:
```dart
Navigator.of(context)
    .push(MaterialPageRoute<SettingsData>(
  builder: (context) => Settings(SettingsData(
      allowDuplicates: duplicates, nRows: nMaxRows)),
))
    .then((value) {
  if (value != null) {
    if (duplicates != value.allowDuplicates ||
        nMaxRows != value.nRows) {
      setState(() {
        duplicates = value.allowDuplicates;
        controller = Controller(duplicates);
        nMaxRows = value.nRows;
        restart();
      });
    } else {
      if (timerisRunning) timerController.stopwatch.start();
    }
  }
});
```
The data between the screen is shared using a ```SettingsData``` class
To get the new data from the settings screen, when the user is done (he clicked the arrow or used the android back) thanks to the ```WillPopScope``` class it will call this function:
```dart
onWillPop: () async {
  Navigator.pop(context, widget.settings);
  return false;
},
```
That will return the ```SettingsData``` object back to the Board
That in the case that it changed it will reset the game and reload the UI.
### App in background
To stop the timer when the user puts the app in the background i subscribed to WidgetsBindingObserver
in the initState:
```dart
    WidgetsBinding.instance.addObserver(this);
```

Then every time a new change in the app appends this function is called:
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);
  if (AppLifecycleState.paused == state) {
    timerController.stopwatch.stop();
  } else if (AppLifecycleState.resumed == state) {
    if (timerisRunning) timerController.stopwatch.start();
  }
}
```


## References
[WillPopScope](https://api.flutter.dev/flutter/widgets/WillPopScope-class.html)

[MaterialPageRoute](https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html)

[SharedPreferences](https://docs.flutter.dev/cookbook/persistence/key-value)

[RepaintBoundary](https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html)

[Stopwatch](https://api.flutter.dev/flutter/dart-core/Stopwatch-class.html)

[Timer](https://api.flutter.dev/flutter/dart-async/Timer-class.html)

[WidgetsBindingObserver](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html)
