import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/app/app_theme.dart';
import 'package:quran_kareem_flutter/controllers/app_controller.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/localization/app_strings.dart';
import 'package:quran_kareem_flutter/screens/reader_screen.dart';
import 'package:quran_kareem_flutter/utils/quran_reader_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'bookmarking an ayah highlights only its inline marker and toggles off',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final controller = await AppController.load();
      controller.language = AppLanguage.english;
      final repository = QuranRepository.fromJsonString(
        File('assets/data/quran.json').readAsStringSync(),
      );
      final verse = repository.surah(1).verses[1];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: ReaderScreen.surah(
            repository: repository,
            controller: controller,
            surahNumber: 1,
            initialVerseKey: verse.key,
          ),
        ),
      );
      await tester.pump();

      final initialMarker = _markerSpan(tester, verse.number);
      final verseText = _verseTextSpan(tester, verse.text);
      final colors = AppTheme.light().colorScheme;
      expect(initialMarker.style?.backgroundColor, isNull);
      expect(initialMarker.style?.color, colors.primary);
      expect(verseText.style?.backgroundColor, isNull);
      expect(
        initialMarker.semanticsLabel,
        '${AppStrings(AppLanguage.english).bookmarks} ${toArabicIndic(verse.number)}',
      );

      final recognizer = initialMarker.recognizer! as TapGestureRecognizer;
      recognizer.onTap!();
      await tester.pump();

      final bookmarkedMarker = _markerSpan(tester, verse.number);
      expect(controller.isBookmarked(verse.key), isTrue);
      expect(bookmarkedMarker.style?.backgroundColor, colors.tertiary);
      expect(bookmarkedMarker.style?.color, colors.onTertiary);
      expect(
        bookmarkedMarker.semanticsLabel,
        '${AppStrings(AppLanguage.english).removeBookmark} ${toArabicIndic(verse.number)}',
      );
      expect(_verseTextSpan(tester, verse.text).style?.backgroundColor, isNull);

      (bookmarkedMarker.recognizer! as TapGestureRecognizer).onTap!();
      await tester.pump();

      final unbookmarkedMarker = _markerSpan(tester, verse.number);
      expect(controller.isBookmarked(verse.key), isFalse);
      expect(unbookmarkedMarker.style?.backgroundColor, isNull);
      expect(unbookmarkedMarker.style?.color, colors.primary);
      expect(
        unbookmarkedMarker.semanticsLabel,
        '${AppStrings(AppLanguage.english).bookmarks} ${toArabicIndic(verse.number)}',
      );
      expect(_verseTextSpan(tester, verse.text).style?.backgroundColor, isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );
}

TextSpan _markerSpan(WidgetTester tester, int verseNumber) {
  final markerText = '${inlineVerseMarker(verseNumber)} ';
  return _allTextSpans(tester).firstWhere((span) => span.text == markerText);
}

TextSpan _verseTextSpan(WidgetTester tester, String verseText) {
  final text = '$verseText ';
  return _allTextSpans(tester).firstWhere((span) => span.text == text);
}

Iterable<TextSpan> _allTextSpans(WidgetTester tester) sync* {
  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    yield* _textSpans(richText.text);
  }
}

Iterable<TextSpan> _textSpans(InlineSpan span) sync* {
  if (span is TextSpan) {
    yield span;
    for (final child in span.children ?? const <InlineSpan>[]) {
      yield* _textSpans(child);
    }
  }
}
