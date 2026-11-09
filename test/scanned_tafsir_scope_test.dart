import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/app/app_theme.dart';
import 'package:quran_kareem_flutter/controllers/app_controller.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/data/scanned_tafsir_repository.dart';
import 'package:quran_kareem_flutter/localization/app_strings.dart';
import 'package:quran_kareem_flutter/models/tafsir_reading_scope.dart';
import 'package:quran_kareem_flutter/models/tafsir_work.dart';
import 'package:quran_kareem_flutter/screens/scanned_tafsir_reader_screen.dart';
import 'package:quran_kareem_flutter/services/tafsir_pdf_service.dart';
import 'package:quran_kareem_flutter/widgets/scoped_ayah_wheel_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuranRepository quran;
  late ScannedTafsirRepository scans;

  setUpAll(() async {
    quran = QuranRepository.fromJsonString(
      await File('assets/data/quran.json').readAsString(),
    );
    scans = ScannedTafsirRepository.fromJsonString(
      await File('assets/data/tafsir_pdf_index.json').readAsString(),
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'language': 'en'});
  });

  test(
    'scope retains exact canonical endpoints and Rub 1 includes both Surahs',
    () {
      final scope = TafsirReadingScope.fromVerses(
        start: quran.verse('1:1')!,
        end: quran.verse('2:25')!,
      );
      expect(scope.startVerseKey, '1:1');
      expect(scope.endVerseKey, '2:25');
      expect(scope.startGlobal, 1);
      expect(scope.endGlobal, quran.verse('2:25')!.globalNumber);

      final verses = ScopedAyahWheelPicker.versesInScope(
        surahs: quran.data.surahs,
        scope: scope,
      );
      expect(verses.first.key, '1:1');
      expect(verses.last.key, '2:25');
      expect(verses, hasLength(7 + 25));
      expect(verses.any((verse) => verse.key == '2:1'), isTrue);
      expect(verses.any((verse) => verse.key == '2:26'), isFalse);
    },
  );

  test('Muyassar scope page endpoints come from canonical verse pages', () {
    final scope = TafsirReadingScope.fromVerses(
      start: quran.verse('2:1')!,
      end: quran.verse('2:25')!,
    );
    expect(
      scans.pageForVerse(
        TafsirWork.muyassar,
        quran.verse(scope.startVerseKey)!,
      ),
      quran.verse('2:1')!.page,
    );
    expect(
      scans.pageForVerse(TafsirWork.muyassar, quran.verse(scope.endVerseKey)!),
      quran.verse('2:25')!.page,
    );
  });

  testWidgets('scoped reader page wheel only exposes intersecting pages', (
    tester,
  ) async {
    final controller = await AppController.load();
    final start = quran.verse('2:1')!;
    final end = quran.verse('2:25')!;
    final scope = TafsirReadingScope.fromVerses(start: start, end: end);
    final firstPage = start.page;
    final lastPage = end.page;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(TafsirPdfService.channel, (call) async {
          if (call.method == 'release') return null;
          throw PlatformException(code: 'PDF_RENDER_FAILED');
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(TafsirPdfService.channel, null);
      controller.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(QuranThemeFamily.desert),
        home: ScannedTafsirReaderScreen(
          work: TafsirWork.muyassar,
          repository: quran,
          scanRepository: scans,
          controller: controller,
          selectedVerse: start,
          initialPage: 1,
          scope: scope,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Page $firstPage / 609'), findsOneWidget);
    final nextIcon = find.byIcon(Icons.navigate_next_rounded);
    final next = find.ancestor(of: nextIcon, matching: find.byType(IconButton));
    for (var page = firstPage; page < lastPage; page += 1) {
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text('Page $lastPage / 609'), findsOneWidget);
    expect(tester.widget<IconButton>(next), isA<IconButton>());
    expect(tester.widget<IconButton>(next).onPressed, isNull);
  });

  testWidgets('scoped ayah wheel shows cross-Surah labels and live preview', (
    tester,
  ) async {
    final scope = TafsirReadingScope.fromVerses(
      start: quran.verse('1:1')!,
      end: quran.verse('2:25')!,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(QuranThemeFamily.desert),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => ScopedAyahWheelPicker.show(
                  context,
                  verses: ScopedAyahWheelPicker.versesInScope(
                    surahs: quran.data.surahs,
                    scope: scope,
                  ),
                  strings: const AppStrings(AppLanguage.english),
                  initialVerse: quran.verse('2:1'),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scoped-ayah-wheel')), findsOneWidget);
    expect(find.byKey(const Key('scoped-ayah-preview')), findsOneWidget);
    expect(find.text('2:1'), findsWidgets);
  });
}
