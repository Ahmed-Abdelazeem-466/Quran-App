import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/data/tafsir_repository.dart';

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

  test(
    'contains the complete Arabic Al-Sa‘di dataset and all 240 Rub indexes',
    () {
      expect(
        tafsir.data.metadata.title,
        'تيسير الكريم الرحمن في تفسير كلام المنان',
      );
      expect(tafsir.data.metadata.author, 'عبد الرحمن بن ناصر السعدي');
      expect(tafsir.data.entries, hasLength(6177));
      expect(tafsir.data.rubs, hasLength(240));
    },
  );

  test('routes every canonical Quran ayah to exactly one Tafsir range', () {
    for (final surah in quran.data.surahs) {
      for (final verse in surah.verses) {
        final entry = tafsir.forVerse(verse.key);
        expect(
          entry,
          isNotNull,
          reason: 'Missing tafsir route for ${verse.key}',
        );
        expect(entry!.containsAyah(verse.number), isTrue);
      }
    }
  });

  test(
    'provides connected Tafsir sections for Surah, Juz, and Rub navigation',
    () {
      final fatihah = tafsir.forSurah(1);
      expect(fatihah.first.ayah, 1);
      expect(fatihah.last.endAyah, 7);

      final firstJuz = quran.data.juzs.first;
      final firstJuzEntries = tafsir.forJuz(
        juzNumber: firstJuz.number,
        startGlobal: quran.verse(firstJuz.startKey)!.globalNumber,
        endGlobal: quran.verse(firstJuz.endKey)!.globalNumber,
      );
      expect(firstJuzEntries, isNotEmpty);
      expect(tafsir.forRub(1), isNotEmpty);
      expect(tafsir.data.rubs.first.startKey, '1:1');
    },
  );

  test('maps every Rubʿ to its exact canonical Quran start and end verses', () {
    for (final rub in tafsir.data.rubs) {
      final verses = quran.versesForRange(
        startKey: rub.startKey,
        endKey: rub.endKey,
      );
      expect(verses, isNotEmpty, reason: 'Empty Rubʿ ${rub.number}');
      expect(verses.first.key, rub.startKey, reason: 'Rubʿ ${rub.number}');
      expect(verses.last.key, rub.endKey, reason: 'Rubʿ ${rub.number}');
    }
  });
}
