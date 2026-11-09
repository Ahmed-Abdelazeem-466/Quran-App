import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/localization/app_strings.dart';
import 'package:quran_kareem_flutter/models/quran_reminder.dart';
import 'package:quran_kareem_flutter/services/quran_reminder_scheduler.dart';
import 'package:quran_kareem_flutter/utils/reminder_time.dart';

QuranReminder buildReminder({
  bool everyDay = true,
  List<int> weekdays = const <int>[],
  QuranReminderContentType contentType = QuranReminderContentType.surah,
  int startAyah = 1,
  int endAyah = 7,
}) => QuranReminder(
  id: 'test-reminder',
  notificationBaseId: 100000,
  contentType: contentType,
  surahNumber: 1,
  startAyah: startAyah,
  endAyah: endAyah,
  hour: 7,
  minute: 30,
  everyDay: everyDay,
  weekdays: weekdays,
  enabled: true,
);

void main() {
  test('validates Quran ayah-range boundaries within a selected surah', () {
    final valid = buildReminder(
      contentType: QuranReminderContentType.ayahRange,
      startAyah: 5,
      endAyah: 7,
    );
    expect(valid.isValidForVerseCount(7), isTrue);
    expect(valid.isValidForVerseCount(6), isFalse);
    expect(
      buildReminder(
        contentType: QuranReminderContentType.ayahRange,
        startAyah: 6,
        endAyah: 5,
      ).isValidForVerseCount(7),
      isFalse,
    );
  });

  test('creates one recurring daily plan for an every-day reminder', () {
    final plan = reminderSchedulePlanFor(buildReminder());
    expect(plan, hasLength(1));
    expect(plan.single.notificationId, 100000);
    expect(plan.single.weekday, isNull);
    expect(plan.single.matchDateTimeComponents, DateTimeComponents.time);
  });

  test('creates one weekly schedule per selected weekday', () {
    final plan = reminderSchedulePlanFor(
      buildReminder(
        everyDay: false,
        weekdays: const <int>[DateTime.monday, DateTime.friday],
      ),
    );
    expect(plan.map((item) => item.notificationId), <int>[100001, 100005]);
    expect(plan.map((item) => item.weekday), <int?>[
      DateTime.monday,
      DateTime.friday,
    ]);
    expect(
      plan.every(
        (item) =>
            item.matchDateTimeComponents == DateTimeComponents.dayOfWeekAndTime,
      ),
      isTrue,
    );
  });

  test('normalizes all seven selected weekdays to one every-day schedule', () {
    final reminder = buildReminder(
      everyDay: false,
      weekdays: const <int>[
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      ],
    );

    expect(reminder.repeatsEveryDay, isTrue);
    expect(reminderSchedulePlanFor(reminder), hasLength(1));
    expect(reminderSchedulePlanFor(reminder).single.notificationId, 100000);
    expect(reminder.toJson()['everyDay'], isTrue);
    expect(reminder.toJson()['weekdays'], isEmpty);
    expect(reminder.cancellableNotificationIds, hasLength(8));
  });

  test(
    'keeps notification ID blocks separate for multiple reminder schedules',
    () {
      final weekdayReminder = buildReminder(
        everyDay: false,
        weekdays: const <int>[DateTime.monday, DateTime.sunday],
      );
      final dailyReminder = QuranReminder(
        id: 'second-reminder',
        notificationBaseId: 100100,
        contentType: QuranReminderContentType.surah,
        surahNumber: 67,
        startAyah: 1,
        endAyah: 30,
        hour: 21,
        minute: 0,
        everyDay: true,
        weekdays: const <int>[],
        enabled: true,
      );
      final allIds = <int>{
        ...weekdayReminder.notificationIds,
        ...dailyReminder.notificationIds,
      };
      expect(allIds, hasLength(3));
      expect(allIds, containsAll(<int>[100001, 100007, 100100]));
    },
  );

  test('converts and formats reminder times with 12-hour morning and evening labels', () {
    final strings = AppStrings(AppLanguage.arabic);
    expect(hour12From24Hour(0), 12);
    expect(hour12From24Hour(13), 1);
    expect(hour24From12Hour(hour12: 12, isMorning: true), 0);
    expect(hour24From12Hour(hour12: 12, isMorning: false), 12);
    expect(
      formatReminderTime(hour24: 7, minute: 5, strings: strings),
      '7:05 صباحي',
    );
    expect(
      formatReminderTime(hour24: 19, minute: 30, strings: strings),
      '7:30 مسائي',
    );
  });

  test('uses the selected ayah text and a whole-Surah reading prompt in notification bodies', () async {
    final raw = await File('assets/data/quran.json').readAsString();
    final repository = QuranRepository.fromJsonString(raw);
    final strings = AppStrings(AppLanguage.arabic);
    final rangeReminder = QuranReminder(
      id: 'baqarah-ending',
      notificationBaseId: 100000,
      contentType: QuranReminderContentType.ayahRange,
      surahNumber: 2,
      startAyah: 285,
      endAyah: 286,
      hour: 7,
      minute: 0,
      everyDay: true,
      weekdays: const <int>[],
      enabled: true,
    );
    final rangeContent = reminderNotificationContent(
      reminder: rangeReminder,
      repository: repository,
      strings: strings,
    );
    expect(rangeContent, contains(repository.verse('2:285')!.text));
    expect(rangeContent, contains(repository.verse('2:286')!.text));

    final wholeSurahContent = reminderNotificationContent(
      reminder: buildReminder(),
      repository: repository,
      strings: strings,
    );
    expect(wholeSurahContent, 'تذكّر أن تقرأ سورة الفاتحة');
  });
}
