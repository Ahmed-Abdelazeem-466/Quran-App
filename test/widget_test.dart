import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/controllers/app_controller.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/data/tafsir_repository.dart';
import 'package:quran_kareem_flutter/localization/app_strings.dart';
import 'package:quran_kareem_flutter/main.dart';
import 'package:quran_kareem_flutter/screens/surah_index_screen.dart';
import 'package:quran_kareem_flutter/utils/arabic_text.dart';
import 'package:quran_kareem_flutter/widgets/reminder_saved_confirmation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Arabic normalization supports diacritic-insensitive Quran search', () {
    expect(normalizeArabic('ٱلرَّحْمَـٰنِ'), 'الرحمان');
    expect(normalizeArabic('إِنَّا أَعْطَيْنَـٰكَ'), 'انا اعطيناك');
  });

  test(
    'every interface language localizes the reader options menu actions',
    () {
      for (final language in AppLanguage.values) {
        final strings = AppStrings(language);
        expect(strings.readerOptions, isNotEmpty);
        expect(strings.searchAyah, isNotEmpty);
        expect(strings.increaseText, isNotEmpty);
        expect(strings.decreaseText, isNotEmpty);
        expect(strings.share, isNotEmpty);
        expect(strings.fullScreen, isNotEmpty);
        expect(strings.rub, isNotEmpty);
        expect(strings.savedQuranAyahs, isNotEmpty);
        expect(strings.savedTafsirPassages, isNotEmpty);
        expect(strings.noSavedQuranAyahs, isNotEmpty);
        expect(strings.noSavedTafsirPassages, isNotEmpty);
        expect(strings.reminders, isNotEmpty);
        expect(strings.addReminder, isNotEmpty);
        expect(strings.reminderDescription, isNotEmpty);
        expect(strings.weekdayShort(DateTime.monday), isNotEmpty);
        expect(strings.weekdayName(DateTime.monday), isNotEmpty);
        expect(strings.weekdayName(DateTime.sunday), isNotEmpty);
        expect(strings.weekdayName(DateTime.thursday), isNotEmpty);
        expect(strings.surah, isNotEmpty);
        expect(strings.invalidReminderRange, isNotEmpty);
        expect(strings.morning, isNotEmpty);
        expect(strings.evening, isNotEmpty);
        expect(strings.confirmTime, isNotEmpty);
        expect(strings.hourLabel, isNotEmpty);
        expect(strings.minuteLabel, isNotEmpty);
        expect(strings.rememberToReadSurah('الفاتحة'), isNotEmpty);
      }

      expect(
        AppStrings(AppLanguage.arabic).weekdayName(DateTime.thursday),
        'الخميس',
      );
    },
  );

  testWidgets(
    'reminder saved confirmation presents a checkmark and localized text',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReminderSavedConfirmation(message: 'تم حفظ التذكير.'),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('تم حفظ التذكير.'), findsOneWidget);
    },
  );

  test('defines the three unified Quran browsing sections', () {
    expect(QuranBrowseSection.values, [
      QuranBrowseSection.surah,
      QuranBrowseSection.juz,
      QuranBrowseSection.rub,
    ]);
  });

  test(
    'constructs the Arabic Quran application root with offline data',
    () async {
      SharedPreferences.setMockInitialValues({});
      final raw = await File('assets/data/quran.json').readAsString();
      final repository = QuranRepository.fromJsonString(raw);
      final tafsirRaw = await File('assets/data/tafsir_saadi.json')
          .readAsString();
      final tafsirRepository = TafsirRepository.fromJsonString(tafsirRaw);
      final controller = await AppController.load();
      final app = QuranApp(
        repository: repository,
        tafsirRepository: tafsirRepository,
        controller: controller,
      );

      expect(app.repository.data.metadata.title, 'القرآن الكريم');
      expect(app.repository.data.surahs, hasLength(114));
      expect(app.tafsirRepository.data.rubs, hasLength(240));
      expect(app.controller.appearance, AppearancePreference.system);
    },
  );
}
