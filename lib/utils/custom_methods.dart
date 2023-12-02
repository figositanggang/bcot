String generateDate({
  required DateTime now,
  required DateTime createdAt,
}) {
  // final year = createdAt.year;
  // final month = createdAt.month;
  // final day = createdAt.day;

  Duration difference = now.difference(createdAt);
  final rangeDay = difference.inDays;
  final rangeHour = difference.inHours;
  final rangeMinute = difference.inMinutes;
  final rangeSecond = difference.inSeconds;

  if (rangeDay > 0 && rangeDay <= 28) {
    return "$rangeDay hari";
  }
  if (rangeHour > 0 && rangeHour <= 24) {
    return "$rangeHour jam";
  }
  if (rangeMinute > 0 && rangeMinute < 60) {
    return "$rangeMinute menit";
  }
  if (rangeSecond > 0 && rangeSecond < 60) {
    return "$rangeSecond detik";
  }
  return "baru";

  // return "${day} ${months[month]} ${year}";
}
