import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quran_models.dart';
import '../models/tafsir_work.dart';

class ScannedTafsirRepository {
  ScannedTafsirRepository(
    this.ibnKathirSurahPages, [
    this.ibnKathirAyahRanges = const [],
  ]);

  final Map<int, int> ibnKathirSurahPages;

  /// Only visually verified ranges from this exact scan; never interpolated.
  final List<Map<String, int>> ibnKathirAyahRanges;
  static Future<ScannedTafsirRepository>? _loaded;

  static Future<ScannedTafsirRepository> load() => _loaded ??= _load();

  static Future<ScannedTafsirRepository> _load() async {
    final raw = await rootBundle.loadString(
      'assets/data/tafsir_pdf_index.json',
    );
    return fromJsonString(raw);
  }

  static ScannedTafsirRepository fromJsonString(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final pages = json['ibnKathirSurahPages'] as Map<String, dynamic>;
    return ScannedTafsirRepository(
      {
        for (final item in pages.entries)
          int.parse(item.key): item.value as int,
      },
      [
        for (final range
            in (json['ibnKathirVerifiedAyahRanges'] as List? ?? []))
          {
            for (final item in (range as Map<String, dynamic>).entries)
              item.key: item.value as int,
          },
      ],
    );
  }

  int? verifiedIbnKathirPage(QuranVerse verse) {
    for (final range in ibnKathirAyahRanges) {
      if (range['surah'] == verse.surahNumber &&
          verse.number >= range['startAyah']! &&
          verse.number <= range['endAyah']!) {
        return range['firstPage'];
      }
    }
    return null;
  }

  /// Al-Muyassar uses exact Madinah pagination. Ibn Kathir uses a verified
  /// explicit passage anchor where available, otherwise the Surah destination.
  int pageForVerse(TafsirWork work, QuranVerse verse) => switch (work) {
    TafsirWork.muyassar => verse.page,
    TafsirWork.ibnKathir =>
      verifiedIbnKathirPage(verse) ?? ibnKathirSurahPages[verse.surahNumber]!,
    TafsirWork.saadi => throw ArgumentError(
      'Sa‘di uses indexed text, not PDF pages',
    ),
  };

  int surahStart(TafsirWork work, QuranSurah surah) =>
      work == TafsirWork.ibnKathir
      ? ibnKathirSurahPages[surah.number]!
      : pageForVerse(work, surah.verses.first);
}
