enum QuranReminderContentType { surah, ayahRange }

class QuranReminder {
  const QuranReminder({
    required this.id,
    required this.notificationBaseId,
    required this.contentType,
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
    required this.hour,
    required this.minute,
    required this.everyDay,
    required this.weekdays,
    required this.enabled,
  });

  factory QuranReminder.fromJson(Map<String, dynamic> json) {
    final rawWeekdays = json['weekdays'];
    final weekdays = rawWeekdays is List
        ? rawWeekdays.whereType<num>().map((day) => day.toInt()).toList()
        : <int>[];
    final everyDay = json['everyDay'] as bool? ?? true;
    final normalisedWeekdays = _normaliseWeekdays(weekdays);
    final repeatsEveryDay =
        everyDay || normalisedWeekdays.length == DateTime.daysPerWeek;
    return QuranReminder(
      id: json['id'] as String,
      notificationBaseId: json['notificationBaseId'] as int,
      contentType: QuranReminderContentType.values.firstWhere(
        (type) => type.name == json['contentType'],
        orElse: () => QuranReminderContentType.surah,
      ),
      surahNumber: json['surahNumber'] as int,
      startAyah: json['startAyah'] as int,
      endAyah: json['endAyah'] as int,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      everyDay: repeatsEveryDay,
      weekdays: repeatsEveryDay ? <int>[] : normalisedWeekdays,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  final String id;
  final int notificationBaseId;
  final QuranReminderContentType contentType;
  final int surahNumber;
  final int startAyah;
  final int endAyah;
  final int hour;
  final int minute;
  final bool everyDay;
  final List<int> weekdays;
  final bool enabled;

  bool get repeatsEveryDay =>
      everyDay || weekdays.toSet().length == DateTime.daysPerWeek;

  bool get hasValidSchedule => repeatsEveryDay || weekdays.isNotEmpty;

  List<int> get notificationIds => repeatsEveryDay
      ? <int>[notificationBaseId]
      : weekdays.map((weekday) => notificationBaseId + weekday).toList();

  List<int> get cancellableNotificationIds => <int>[
    notificationBaseId,
    ...List<int>.generate(
      DateTime.daysPerWeek,
      (index) => notificationBaseId + index + 1,
    ),
  ];

  bool isValidForVerseCount(int verseCount) {
    if (surahNumber < 1 || surahNumber > 114 || hour < 0 || hour > 23) {
      return false;
    }
    if (minute < 0 || minute > 59 || !hasValidSchedule) return false;
    if (contentType == QuranReminderContentType.surah) return verseCount > 0;
    return startAyah >= 1 && startAyah <= endAyah && endAyah <= verseCount;
  }

  QuranReminder copyWith({
    QuranReminderContentType? contentType,
    int? surahNumber,
    int? startAyah,
    int? endAyah,
    int? hour,
    int? minute,
    bool? everyDay,
    List<int>? weekdays,
    bool? enabled,
  }) => QuranReminder(
    id: id,
    notificationBaseId: notificationBaseId,
    contentType: contentType ?? this.contentType,
    surahNumber: surahNumber ?? this.surahNumber,
    startAyah: startAyah ?? this.startAyah,
    endAyah: endAyah ?? this.endAyah,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    everyDay: everyDay ?? this.everyDay,
    weekdays: _normaliseWeekdays(weekdays ?? this.weekdays),
    enabled: enabled ?? this.enabled,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'notificationBaseId': notificationBaseId,
    'contentType': contentType.name,
    'surahNumber': surahNumber,
    'startAyah': startAyah,
    'endAyah': endAyah,
    'hour': hour,
    'minute': minute,
    'everyDay': repeatsEveryDay,
    'weekdays': repeatsEveryDay ? <int>[] : _normaliseWeekdays(weekdays),
    'enabled': enabled,
  };

  static List<int> _normaliseWeekdays(List<int> value) =>
      value
          .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
          .toSet()
          .toList()
        ..sort();
}
