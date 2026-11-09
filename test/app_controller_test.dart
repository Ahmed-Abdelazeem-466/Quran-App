import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/app/app_theme.dart';
import 'package:quran_kareem_flutter/controllers/app_controller.dart';
import 'package:quran_kareem_flutter/localization/app_strings.dart';
import 'package:quran_kareem_flutter/models/quran_reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists appearance, theme, text size, Quran and Tafsir bookmarks, and reading position', () async {
    final controller = await AppController.load();
    expect(controller.appearance.themeMode, ThemeMode.system);
    expect(controller.themeFamily, QuranThemeFamily.emerald);
    expect(controller.quranFontSize, AppController.defaultFontSize);

    await controller.setAppearance(AppearancePreference.dark);
    await controller.setThemeFamily(QuranThemeFamily.ocean);
    await controller.setLanguage(AppLanguage.japanese);
    await controller.setFontSize(35);
    await controller.toggleBookmark('2:255');
    await controller.toggleTafsirBookmark('2:255');
    controller.updateReadingPosition('18:10');
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final restored = await AppController.load();
    expect(restored.appearance, AppearancePreference.dark);
    expect(restored.themeFamily, QuranThemeFamily.ocean);
    expect(restored.language, AppLanguage.japanese);
    expect(restored.quranFontSize, 35);
    expect(restored.isBookmarked('2:255'), isTrue);
    expect(restored.isTafsirBookmarked('2:255'), isTrue);
    expect(restored.lastVerseKey, '18:10');
  });

  test('clamps reader font size and toggles bookmarks cleanly', () async {
    final controller = await AppController.load();
    await controller.setFontSize(100);
    expect(controller.quranFontSize, AppController.maxFontSize);
    await controller.setFontSize(1);
    expect(controller.quranFontSize, AppController.minFontSize);

    await controller.toggleBookmark('1:1');
    expect(controller.isBookmarked('1:1'), isTrue);
    await controller.toggleBookmark('1:1');
    expect(controller.isBookmarked('1:1'), isFalse);

    await controller.toggleTafsirBookmark('1:1');
    expect(controller.isTafsirBookmarked('1:1'), isTrue);
    await controller.toggleTafsirBookmark('1:1');
    expect(controller.isTafsirBookmarked('1:1'), isFalse);
  });

  test('persists, updates, and removes multiple Quran reminders', () async {
    final controller = await AppController.load();
    final first = QuranReminder(
      id: 'morning',
      notificationBaseId: 100000,
      contentType: QuranReminderContentType.ayahRange,
      surahNumber: 2,
      startAyah: 285,
      endAyah: 286,
      hour: 7,
      minute: 15,
      everyDay: false,
      weekdays: const <int>[DateTime.monday, DateTime.friday],
      enabled: true,
    );
    final second = QuranReminder(
      id: 'evening',
      notificationBaseId: 100010,
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

    await controller.upsertReminder(first);
    await controller.upsertReminder(second);
    await controller.upsertReminder(second.copyWith(enabled: false));
    await controller.removeReminder(first.id);

    expect(controller.reminders, hasLength(1));
    expect(controller.reminders.single.id, 'evening');
    expect(controller.reminders.single.enabled, isFalse);

    final restored = await AppController.load();
    expect(restored.reminders, hasLength(1));
    expect(restored.reminders.single.surahNumber, 67);
    expect(restored.reminders.single.everyDay, isTrue);
    expect(restored.reminders.single.enabled, isFalse);
    expect(restored.nextReminderNotificationBaseId(), 100000);
  });

  test(
    'remembers that the Android notification permission was requested once',
    () async {
      final controller = await AppController.load();
      expect(controller.notificationPermissionPromptSeen, isFalse);
      await controller.markNotificationPermissionPromptSeen();

      final restored = await AppController.load();
      expect(restored.notificationPermissionPromptSeen, isTrue);
    },
  );

  test('clearing reading progress cancels a pending delayed save', () async {
    final controller = await AppController.load();
    controller.updateReadingPosition('2:255');
    await controller.clearReadingProgress();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final restored = await AppController.load();
    expect(controller.lastVerseKey, isNull);
    expect(restored.lastVerseKey, isNull);
    controller.dispose();
    restored.dispose();
  });

  test('defines six distinct theme palettes for light and dark mode', () {
    expect(QuranThemeFamily.values, hasLength(6));
    final lightPrimaries = <Color>{};
    final darkPrimaries = <Color>{};
    for (final family in QuranThemeFamily.values) {
      final palette = AppTheme.palette(family);
      final light = AppTheme.light(family);
      final dark = AppTheme.dark(family);
      lightPrimaries.add(light.colorScheme.primary);
      darkPrimaries.add(dark.colorScheme.primary);
      expect(light.colorScheme.primary, palette.lightPrimary);
      expect(dark.colorScheme.primary, palette.darkPrimary);
    }
    expect(lightPrimaries, hasLength(6));
    expect(darkPrimaries, hasLength(6));
  });

  test('supports all requested navigation languages and their directions', () {
    expect(AppLanguage.values, hasLength(14));
    expect(AppLanguage.arabic.isRtl, isTrue);
    expect(AppLanguage.urdu.isRtl, isTrue);
    expect(AppLanguage.english.isRtl, isFalse);
    expect(AppStrings(AppLanguage.french).searchSurah, isNotEmpty);
    expect(AppStrings(AppLanguage.japanese).quranArabicNotice, isNotEmpty);
  });
}
