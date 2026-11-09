import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/tafsir_models.dart';

class TafsirRepository {
  TafsirRepository(this.data)
    : _entryByVerseKey = {
        for (final entry in data.entries)
          for (var ayah = entry.ayah; ayah <= entry.endAyah; ayah += 1)
            '${entry.surah}:$ayah': entry,
      };

  static Future<TafsirRepository> load() async {
    final raw = await rootBundle.loadString('assets/data/tafsir_saadi.json');
    return fromJsonString(raw);
  }

  static TafsirRepository fromJsonString(String raw) {
    return TafsirRepository(
      TafsirData.fromJson(jsonDecode(raw) as Map<String, dynamic>),
    );
  }

  final TafsirData data;
  final Map<String, TafsirEntry> _entryByVerseKey;

  TafsirEntry? entryByKey(String entryKey) => data.entries
      .where((entry) => entry.key == entryKey)
      .cast<TafsirEntry?>()
      .firstOrNull;

  TafsirEntry? forVerse(String verseKey) => _entryByVerseKey[verseKey];

  List<TafsirEntry> forSurah(int surahNumber) => data.entries
      .where((entry) => entry.surah == surahNumber)
      .toList(growable: false);

  List<TafsirEntry> forJuz({
    required int juzNumber,
    required int startGlobal,
    required int endGlobal,
  }) => data.entries
      .where((entry) => entry.overlapsGlobalRange(startGlobal, endGlobal))
      .toList(growable: false);

  List<TafsirEntry> forRub(int rubNumber) {
    final rub = data.rubs[rubNumber - 1];
    return data.entries
        .where(
          (entry) => entry.overlapsGlobalRange(rub.startGlobal, rub.endGlobal),
        )
        .toList(growable: false);
  }
}
