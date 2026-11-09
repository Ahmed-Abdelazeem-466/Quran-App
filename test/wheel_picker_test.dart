import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/app/app_theme.dart';
import 'package:quran_kareem_flutter/controllers/app_controller.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/localization/app_strings.dart';
import 'package:quran_kareem_flutter/models/quran_models.dart';
import 'package:quran_kareem_flutter/screens/settings_screen.dart';
import 'package:quran_kareem_flutter/widgets/ayah_wheel_picker.dart';
import 'package:quran_kareem_flutter/widgets/language_wheel_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late QuranSurah surah;

  setUp(() {
    surah = _testSurah();
  });

  testWidgets('ayah picker starts at the requested ayah', (tester) async {
    await tester.pumpWidget(_pickerApp(initialAyah: 2));
    await _showAyahPicker(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ayah-preview')), findsOneWidget);
    expect(find.text('ثَانِيَةٌ'), findsOneWidget);
  });

  testWidgets('ayah preview updates after dragging the wheel', (tester) async {
    await tester.pumpWidget(_pickerApp());
    await _showAyahPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('أُولَى'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('ayah-wheel')),
      const Offset(0, -58),
    );
    await tester.pumpAndSettle();

    expect(find.text('ثَانِيَةٌ'), findsOneWidget);
  });

  testWidgets(
    'language wheel opens on the current language and cancel changes nothing',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppController(await SharedPreferences.getInstance());
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: SettingsScreen(
            repository: QuranRepository(_testData(surah)),
            controller: controller,
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('language-picker-tile')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('language-wheel')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('language-wheel')),
          matching: find.text(AppLanguage.arabic.nativeName),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(AppStrings(AppLanguage.arabic).cancel));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('language-wheel')), findsNothing);
      expect(controller.language, AppLanguage.arabic);
    },
  );

  testWidgets('settings language confirmation updates the controller', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(await SharedPreferences.getInstance());
    final repository = QuranRepository(_testData(surah));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: SettingsScreen(repository: repository, controller: controller),
      ),
    );
    await tester.tap(find.byKey(const Key('language-picker-tile')));
    await tester.pumpAndSettle();

    final wheel = find.byKey(const Key('language-wheel'));
    await tester.drag(wheel, const Offset(0, -58));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(
        MaterialLocalizations.of(
          tester.element(find.byKey(const Key('language-wheel'))),
        ).okButtonLabel,
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.language, isNot(AppLanguage.arabic));
    expect(controller.language, AppLanguage.english);
    expect((await SharedPreferences.getInstance()).getString('language'), 'en');
  });
}

Widget _pickerApp({int initialAyah = 1}) => MaterialApp(
  theme: AppTheme.light(),
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => AyahWheelPicker.show(
                context,
                surah: _testSurah(),
                strings: const AppStrings(AppLanguage.english),
                initialAyah: initialAyah,
              ),
              child: const Text('ayah'),
            ),
            ElevatedButton(
              onPressed: () => LanguageWheelPicker.show(
                context,
                initialLanguage: AppLanguage.arabic,
                strings: const AppStrings(AppLanguage.english),
              ),
              child: const Text('language'),
            ),
          ],
        ),
      ),
    ),
  ),
);

Future<void> _showAyahPicker(WidgetTester tester) async {
  await tester.tap(find.text('ayah'));
}

QuranSurah _testSurah() => QuranSurah(
  number: 1,
  name: 'الفاتحة',
  transliteration: 'Al-Fatihah',
  englishName: 'The Opening',
  revelationType: 'Meccan',
  revelationOrder: 5,
  rukuCount: 1,
  verseCount: 3,
  firstJuz: 1,
  firstPage: 1,
  verses: [_verse(1, 'أُولَى'), _verse(2, 'ثَانِيَةٌ'), _verse(3, 'ثَالِثَةٌ')],
);

QuranVerse _verse(int number, String text) => QuranVerse(
  globalNumber: number,
  surahNumber: 1,
  number: number,
  text: text,
  key: '1:$number',
  juz: 1,
  page: 1,
);

QuranData _testData(QuranSurah surah) => QuranData(
  metadata: const QuranMetadata(
    title: 'القرآن الكريم',
    riwayah: 'Hafs',
    surahCount: 1,
    verseCount: 3,
    juzCount: 1,
    pageCount: 1,
    sourceEdition: 'test',
    textSource: 'test',
    textLicense: 'test',
    sourceUrl: 'https://example.com',
  ),
  surahs: [surah],
  juzs: const [],
);
