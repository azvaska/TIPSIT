# Mastermind

A guessing game.
<br>
lean what it is about
[here](https://en.wikipedia.org/wiki/Mastermind_(board_game))
## Additional Features
- Variable number of rows for the guess
- Possibility to disable duplicated colors in the combination
- Stopwatch for the match and the best time through all the games

## In depth
The stopwatch has been implemented trought the ```Stopwatch``` class and ``` Timer.periodic()``` is used for updating the Ui.
<br>
For performance reasons the minutes and seconds widgets are separated from the microseconds and also the repain are isolated tanks to the widget 
```RepaintBoundary```.
<br>
This is not the most efficent setup since i don't stop the ``` Timer.periodic()``` so it will call eaven when the timer is supposely stoped, to mitigate i check if the value of the stopwatch is changes if not i just exit the funciton.



This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
