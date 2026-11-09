import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quran_models.dart';
import '../utils/arabic_text.dart';

class QuranRepository {
  QuranRepository(this.data)
    : _surahByNumber = {for (final surah in data.surahs) surah.number: surah},
      _verseByKey = {
        for (final surah in data.surahs)
          for (final verse in surah.verses) verse.key: verse,
      };

  static Future<QuranRepository> load() async {
    final raw = await rootBundle.loadString('assets/data/quran.json');
    return fromJsonString(raw);
  }

  static QuranRepository fromJsonString(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return QuranRepository(QuranData.fromJson(decoded));
  }

  final QuranData data;
  final Map<int, QuranSurah> _surahByNumber;
  final Map<String, QuranVerse> _verseByKey;

  QuranSurah surah(int number) => _surahByNumber[number]!;

  QuranVerse? verse(String? key) => key == null ? null : _verseByKey[key];

  QuranSurah surahForVerse(QuranVerse verse) => surah(verse.surahNumber);

  List<QuranVerse> versesForJuz(int juzNumber) => data.surahs
      .expand((surah) => surah.verses)
      .where((verse) => verse.juz == juzNumber)
      .toList(growable: false);

  List<QuranVerse> versesForRange({
    required String startKey,
    required String endKey,
  }) {
    final start = verse(startKey);
    final end = verse(endKey);
    if (start == null || end == null || end.globalNumber < start.globalNumber) {
      return const <QuranVerse>[];
    }
    return data.surahs
        .expand((surah) => surah.verses)
        .where(
          (verse) =>
              verse.globalNumber >= start.globalNumber &&
              verse.globalNumber <= end.globalNumber,
        )
        .toList(growable: false);
  }

  List<QuranSurah> surahsForJuz(int juzNumber) => data.surahs
      .where((surah) => surah.verses.any((verse) => verse.juz == juzNumber))
      .toList(growable: false);

  QuranVerse? previousVerse(QuranVerse verse) => _verseByKey.values
      .where((item) => item.globalNumber == verse.globalNumber - 1)
      .firstOrNull;

  QuranVerse? nextVerse(QuranVerse verse) => _verseByKey.values
      .where((item) => item.globalNumber == verse.globalNumber + 1)
      .firstOrNull;

  List<QuranSearchResult> search(String input, {int limit = 100}) {
    final query = normalizeArabic(input);
    final looseQuery = normalizeArabicLoose(input);
    if (query.length < 2) return const [];

    final results = <QuranSearchResult>[];
    for (final surah in data.surahs) {
      final surahText = normalizeArabic(
        '${surah.name} ${surah.transliteration} ${surah.englishName}',
      );
      if (surahText.contains(query) ||
          normalizeArabicLoose(surahText).contains(looseQuery)) {
        results.add(QuranSearchResult(surah: surah));
      }
    }

    for (final surah in data.surahs) {
      for (final verse in surah.verses) {
        final verseText = normalizeArabic(verse.text);
        if (verseText.contains(query) ||
            normalizeArabicLoose(verseText).contains(looseQuery)) {
          results.add(QuranSearchResult(surah: surah, verse: verse));
          if (results.length >= limit) return results;
        }
      }
    }
    return results.take(limit).toList(growable: false);
  }
}
