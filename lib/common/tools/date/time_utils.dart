/// 毫秒转时分秒如 01:12:23
String toHMS(int microsecond) {
  int minutesPerHour = 60;
  int secondsPerMinute = 60;
  int microsecondsPerSecond = 1000;
  int microsecondsPerMillisecond = 1000;
  int inMilliseconds = microsecond ~/ microsecondsPerMillisecond;
  int inSeconds = inMilliseconds ~/ microsecondsPerSecond;
  int inMinutes = inSeconds ~/ secondsPerMinute;
  int inHours = inMinutes ~/ minutesPerHour;
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(inMinutes.remainder(minutesPerHour));
  String twoDigitSeconds = twoDigits(inSeconds.remainder(secondsPerMinute));
  if (inHours == 0) {
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
  return "$inHours:$twoDigitMinutes:$twoDigitSeconds";
}

String secToHMS(second) => toHMS(second * 1000 * 1000);
