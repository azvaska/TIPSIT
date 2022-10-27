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
