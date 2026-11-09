import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/app/app_theme.dart';
import 'package:quran_kareem_flutter/controllers/app_controller.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/data/tafsir_repository.dart';
import 'package:quran_kareem_flutter/localization/app_strings.dart';
import 'package:quran_kareem_flutter/screens/tafsir_index_screen.dart';
import 'package:quran_kareem_flutter/widgets/themed_selection_wheel.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late QuranRepository quran;
  late TafsirRepository tafsir;
  setUpAll(() async {
    quran = QuranRepository.fromJsonString(
      await File('assets/data/quran.json').readAsString(),
    );
    tafsir = TafsirRepository.fromJsonString(
      await File('assets/data/tafsir_saadi.json').readAsString(),
    );
  });

  Future<AppController> showIndex(
    WidgetTester tester, {
    AppLanguage language = AppLanguage.english,
  }) async {
    SharedPreferences.setMockInitialValues({'language': language.code});
    final controller = await AppController.load();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(QuranThemeFamily.desert),
        home: Scaffold(
          body: Directionality(
            textDirection: language.isRtl
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: TafsirIndexScreen(
              quranRepository: quran,
              tafsirRepository: tafsir,
              controller: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets(
    'Tafsir opens with three works, and changing work returns to the chooser',
    (tester) async {
      final controller = await showIndex(tester);
      expect(find.byKey(const ValueKey('tafsir-work-saadi')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('tafsir-work-muyassar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('tafsir-work-ibnKathir')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('tafsir-work-ibnKathir')));
      await tester.pumpAndSettle();
      expect(find.text('تفسير ابن كثير'), findsOneWidget);
      expect(find.text('Surah'), findsOneWidget);
      await tester.tap(find.byTooltip('Choose a Tafsir'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('tafsir-work-saadi')), findsOneWidget);
      expect(tester.takeException(), isNull);
      controller.dispose();
    },
  );

  testWidgets('a wheel-selected Saadi ayah opens its exact indexed passage', (
    tester,
  ) async {
    final controller = await showIndex(tester);
    await tester.tap(find.byKey(const ValueKey('tafsir-work-saadi')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(
        AppStrings(AppLanguage.english)
            .numberedSurah(2, quran.surah(2).transliteration),
      ),
    );
    await tester.pumpAndSettle();
    final wheel = tester.widget<ThemedSelectionWheel>(
      find.byType(ThemedSelectionWheel),
    );
    wheel.controller.jumpToItem(285);
    await tester.pumpAndSettle();
    expect(find.text(quran.verse('2:286')!.text), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final reader = tester.widget<TafsirReaderScreen>(
      find.byType(TafsirReaderScreen),
    );
    expect(reader.initialVerseKey, '2:286');
    expect(reader.entries, hasLength(tafsir.forSurah(2).length));
    final list = tester.widget<ScrollablePositionedList>(
      find.byType(ScrollablePositionedList),
    );
    final expected = reader.entries.indexWhere(
      (entry) => entry.ayah <= 286 && entry.endAyah >= 286,
    );
    expect(list.initialScrollIndex, expected);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('canceling the ayah wheel leaves the Surah index unchanged', (
    tester,
  ) async {
    final controller = await showIndex(tester);
    await tester.tap(find.byKey(const ValueKey('tafsir-work-muyassar')));
    await tester.pumpAndSettle();
    final title = AppStrings(AppLanguage.english)
        .numberedSurah(1, quran.surah(1).transliteration);
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(TafsirReaderScreen), findsNothing);
    expect(find.text(title), findsOneWidget);
    controller.dispose();
  });
}
