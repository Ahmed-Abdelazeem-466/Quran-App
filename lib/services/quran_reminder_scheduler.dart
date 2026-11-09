import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/quran_repository.dart';
import '../localization/app_strings.dart';
import '../models/quran_reminder.dart';

class QuranReminderSchedulePlan {
  const QuranReminderSchedulePlan({
    required this.notificationId,
    required this.matchDateTimeComponents,
    this.weekday,
  });

  final int notificationId;
  final DateTimeComponents matchDateTimeComponents;
  final int? weekday;
}

List<QuranReminderSchedulePlan> reminderSchedulePlanFor(
  QuranReminder reminder,
) {
  if (reminder.repeatsEveryDay) {
    return <QuranReminderSchedulePlan>[
      QuranReminderSchedulePlan(
        notificationId: reminder.notificationBaseId,
        matchDateTimeComponents: DateTimeComponents.time,
      ),
    ];
  }
  return reminder.weekdays
      .map(
        (weekday) => QuranReminderSchedulePlan(
          notificationId: reminder.notificationBaseId + weekday,
          weekday: weekday,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        ),
      )
      .toList(growable: false);
}

class QuranReminderScheduler {
  QuranReminderScheduler({FlutterLocalNotificationsPlugin? notifications})
    : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _notifications;
  bool _isInitialized = false;
  static const _channelId = 'quran_reading_reminders_v2';

  Future<void> initialize() async {
    if (_isInitialized) return;
    tz.initializeTimeZones();
    try {
      final deviceZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceZone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
    );
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        'Quran reading reminders',
        description: 'Scheduled local Quran reading reminders',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
    _isInitialized = true;
  }

  Future<bool> requestNotificationPermission() async {
    await initialize();
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  Future<bool> areNotificationsEnabled() async {
    await initialize();
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.areNotificationsEnabled() ?? true;
  }

  Future<void> rescheduleAll({
    required Iterable<QuranReminder> reminders,
    required QuranRepository repository,
    required AppStrings strings,
  }) async {
    await initialize();
    for (final reminder in reminders) {
      await cancel(reminder);
      if (reminder.enabled) {
        await schedule(
          reminder: reminder,
          repository: repository,
          strings: strings,
          cancelFirst: false,
        );
      }
    }
  }

  Future<void> schedule({
    required QuranReminder reminder,
    required QuranRepository repository,
    required AppStrings strings,
    bool cancelFirst = true,
  }) async {
    await initialize();
    if (cancelFirst) await cancel(reminder);
    if (!reminder.enabled || !reminder.hasValidSchedule) return;

    final content = reminderNotificationContent(
      reminder: reminder,
      repository: repository,
      strings: strings,
    );
    final now = tz.TZDateTime.now(tz.local);
    final scheduleMode = await _androidScheduleMode();
    for (final plan in reminderSchedulePlanFor(reminder)) {
      final scheduledDate = _nextOccurrence(
        now: now,
        hour: reminder.hour,
        minute: reminder.minute,
        weekday: plan.weekday,
      );
      await _notifications.zonedSchedule(
        id: plan.notificationId,
        title: strings.reminders,
        body: content,
        payload: reminder.id,
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Quran reading reminders',
            channelDescription: 'Scheduled local Quran reading reminders',
            icon: 'ic_notification',
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            playSound: true,
            styleInformation: BigTextStyleInformation(content),
          ),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: plan.matchDateTimeComponents,
      );
    }
  }

  Future<AndroidScheduleMode> _androidScheduleMode() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canScheduleExact = await android?.canScheduleExactNotifications();
    return canScheduleExact == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> cancel(QuranReminder reminder) async {
    await initialize();
    for (final notificationId in reminder.cancellableNotificationIds) {
      await _notifications.cancel(id: notificationId);
    }
  }

  static tz.TZDateTime _nextOccurrence({
    required tz.TZDateTime now,
    required int hour,
    required int minute,
    int? weekday,
  }) {
    var scheduled = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (weekday == null) {
      if (!scheduled.isAfter(now)) {
        scheduled = tz.TZDateTime(
          now.location,
          now.year,
          now.month,
          now.day + 1,
          hour,
          minute,
        );
      }
      return scheduled;
    }

    final daysUntilWeekday = (weekday - now.weekday + 7) % 7;
    scheduled = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day + daysUntilWeekday,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = tz.TZDateTime(
        now.location,
        scheduled.year,
        scheduled.month,
        scheduled.day + 7,
        hour,
        minute,
      );
    }
    return scheduled;
  }
}

String reminderNotificationContent({
  required QuranReminder reminder,
  required QuranRepository repository,
  required AppStrings strings,
}) {
  final surah = repository.surah(reminder.surahNumber);
  if (reminder.contentType == QuranReminderContentType.surah) {
    return strings.rememberToReadSurah(surah.name);
  }
  final reference = reminder.contentType == QuranReminderContentType.surah
      ? '${strings.surah} ${surah.number} • ${surah.name}'
      : '${strings.surah} ${surah.number} • ${surah.name} • '
            '${strings.verses} ${reminder.startAyah}–${reminder.endAyah}';
  final verses = repository.versesForRange(
    startKey: '${reminder.surahNumber}:${reminder.startAyah}',
    endKey: '${reminder.surahNumber}:${reminder.endAyah}',
  );
  final exactArabic = verses.map((verse) => verse.text).join(' ');
  return '$reference\n$exactArabic';
}
