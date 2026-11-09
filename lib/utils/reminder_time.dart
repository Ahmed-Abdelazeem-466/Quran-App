import '../localization/app_strings.dart';

int hour12From24Hour(int hour24) {
  if (hour24 < 0 || hour24 > 23) {
    throw ArgumentError.value(hour24, 'hour24', 'Must be from 0 to 23.');
  }
  final hour = hour24 % 12;
  return hour == 0 ? 12 : hour;
}

int hour24From12Hour({required int hour12, required bool isMorning}) {
  if (hour12 < 1 || hour12 > 12) {
    throw ArgumentError.value(hour12, 'hour12', 'Must be from 1 to 12.');
  }
  final baseHour = hour12 % 12;
  return isMorning ? baseHour : baseHour + 12;
}

String formatReminderTime({
  required int hour24,
  required int minute,
  required AppStrings strings,
}) {
  if (minute < 0 || minute > 59) {
    throw ArgumentError.value(minute, 'minute', 'Must be from 0 to 59.');
  }
  final time =
      '${hour12From24Hour(hour24)}:${minute.toString().padLeft(2, '0')}';
  return '$time ${hour24 < 12 ? strings.morning : strings.evening}';
}
