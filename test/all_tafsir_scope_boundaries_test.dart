import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/data/scanned_tafsir_repository.dart';
import 'package:quran_kareem_flutter/data/tafsir_repository.dart';
import 'package:quran_kareem_flutter/models/tafsir_reading_scope.dart';
import 'package:quran_kareem_flutter/models/tafsir_work.dart';
import 'package:quran_kareem_flutter/widgets/scoped_ayah_wheel_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuranRepository quran;
  late TafsirRepository tafsir;
  late ScannedTafsirRepository scans;

  setUpAll(() async {
    quran = QuranRepository.fromJsonString(
      await File('assets/data/quran.json').readAsString(),
    );
    tafsir = TafsirRepository.fromJsonString(
      await File('assets/data/tafsir_saadi.json').readAsString(),
    );
    scans = ScannedTafsirRepository.fromJsonString(
      await File('assets/data/tafsir_pdf_index.json').readAsString(),
    );
  });

  void expectCompleteScope({
    required String label,
    required String startKey,
    required String endKey,
  }) {
    final start = quran.verse(startKey);
    final end = quran.verse(endKey);
    expect(start, isNotNull, reason: '$label start key $startKey is missing');
    expect(end, isNotNull, reason: '$label end key $endKey is missing');
    final canonicalStart = start!;
    final canonicalEnd = end!;

    final scope = TafsirReadingScope.fromVerses(
      start: canonicalStart,
      end: canonicalEnd,
    );
    expect(scope.startVerseKey, equals(startKey), reason: label);
    expect(scope.endVerseKey, equals(endKey), reason: label);
    expect(
      scope.startGlobal,
      equals(canonicalStart.globalNumber),
      reason: label,
    );
    expect(scope.endGlobal, equals(canonicalEnd.globalNumber), reason: label);
    expect(
      scope.startGlobal,
      lessThanOrEqualTo(scope.endGlobal),
      reason: label,
    );

    final expectedVerses = quran.versesForRange(
      startKey: startKey,
      endKey: endKey,
    );
    final wheelVerses = ScopedAyahWheelPicker.versesInScope(
      surahs: quran.data.surahs,
      scope: scope,
    );
    expect(expectedVerses, isNotEmpty, reason: label);
    expect(wheelVerses, hasLength(expectedVerses.length), reason: label);
    expect(wheelVerses.first.key, equals(startKey), reason: label);
    expect(wheelVerses.last.key, equals(endKey), reason: label);
    expect(
      wheelVerses.map((verse) => verse.key).toList(),
      equals(expectedVerses.map((verse) => verse.key).toList()),
      reason: '$label wheel verses must be the exact inclusive range',
    );
    expect(
      wheelVerses.length,
      equals(scope.endGlobal - scope.startGlobal + 1),
      reason: '$label wheel range must not have gaps',
    );

    for (final verse in wheelVerses) {
      expect(
        verse.globalNumber,
        inInclusiveRange(scope.startGlobal, scope.endGlobal),
        reason: '$label wheel contains ${verse.key} outside its scope',
      );
      expect(scope.contains(verse), isTrue, reason: label);
    }

    final previous = quran.previousVerse(canonicalStart);
    if (previous != null) {
      expect(
        scope.contains(previous),
        isFalse,
        reason: '$label scope includes the verse before its start',
      );
    }
    final next = quran.nextVerse(canonicalEnd);
    if (next != null) {
      expect(
        scope.contains(next),
        isFalse,
        reason: '$label scope includes the verse after its end',
      );
    }

    final expectedSurahs =
        expectedVerses.map((verse) => verse.surahNumber).toSet().toList()
          ..sort();
    final actualSurahs =
        wheelVerses.map((verse) => verse.surahNumber).toSet().toList()..sort();
    expect(actualSurahs, equals(expectedSurahs), reason: label);
    for (final surahNumber in expectedSurahs) {
      expect(
        actualSurahs,
        contains(surahNumber),
        reason: '$label omitted crossed Surah $surahNumber',
      );
    }

    expect(
      scans.pageForVerse(TafsirWork.muyassar, canonicalStart),
      equals(canonicalStart.page),
      reason: '$label Muyassar start page must use the canonical verse page',
    );
    expect(
      scans.pageForVerse(TafsirWork.muyassar, canonicalEnd),
      equals(canonicalEnd.page),
      reason: '$label Muyassar end page must use the canonical verse page',
    );
  }

  test('all 30 Juz have exact tafsir scope boundaries', () {
    expect(quran.data.juzs, hasLength(30));
    expect(quran.data.metadata.juzCount, equals(30));

    for (final juz in quran.data.juzs) {
      expect(juz.number, equals(quran.data.juzs.indexOf(juz) + 1));
      expectCompleteScope(
        label: 'Juz ${juz.number}',
        startKey: juz.startKey,
        endKey: juz.endKey,
      );
    }
  });

  test('all 240 Rub sections have exact tafsir scope boundaries', () {
    expect(tafsir.data.rubs, hasLength(240));
    expect(tafsir.data.metadata.rubCount, equals(240));

    for (final rub in tafsir.data.rubs) {
      final start = quran.verse(rub.startKey);
      final end = quran.verse(rub.endKey);
      expect(start, isNotNull, reason: 'Rub ${rub.number} start key');
      expect(end, isNotNull, reason: 'Rub ${rub.number} end key');
      expect(
        rub.startGlobal,
        equals(start!.globalNumber),
        reason: 'Rub ${rub.number}',
      );
      expect(
        rub.endGlobal,
        equals(end!.globalNumber),
        reason: 'Rub ${rub.number}',
      );
      expect(
        rub.startSurah,
        equals(start.surahNumber),
        reason: 'Rub ${rub.number}',
      );
      expect(
        rub.endSurah,
        equals(end.surahNumber),
        reason: 'Rub ${rub.number}',
      );
      expect(rub.startAyah, equals(start.number), reason: 'Rub ${rub.number}');
      expect(rub.endAyah, equals(end.number), reason: 'Rub ${rub.number}');

      expectCompleteScope(
        label: 'Rub ${rub.number}',
        startKey: rub.startKey,
        endKey: rub.endKey,
      );
    }
  });
}
