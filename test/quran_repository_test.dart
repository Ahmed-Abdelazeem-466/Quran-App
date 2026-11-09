import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';

void main() {
  late QuranRepository repository;

  setUpAll(() async {
    final raw = await File('assets/data/quran.json').readAsString();
    repository = QuranRepository.fromJsonString(raw);
  });

  test('contains the complete canonical Quran structure', () {
    expect(repository.data.metadata.surahCount, 114);
    expect(repository.data.metadata.verseCount, 6236);
    expect(repository.data.metadata.juzCount, 30);
    expect(repository.data.metadata.pageCount, 604);
    expect(repository.data.surahs, hasLength(114));
    expect(repository.data.juzs, hasLength(30));
    expect(
      repository.data.surahs.expand((surah) => surah.verses),
      hasLength(6236),
    );
  });

  test('preserves canonical surah order and verse counts', () {
    expect(repository.surah(1).name, 'الفاتحة');
    expect(repository.surah(1).verseCount, 7);
    expect(repository.surah(2).name, 'البقرة');
    expect(repository.surah(2).verseCount, 286);
    expect(repository.surah(108).name, 'الكوثر');
    expect(repository.surah(108).verseCount, 3);
    expect(repository.surah(114).name, 'الناس');
    expect(repository.surah(114).verseCount, 6);
  });

  test('preserves verified first and last Uthmani verses', () {
    expect(
      repository.verse('1:1')!.text,
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
    );
    expect(repository.verse('114:6')!.text, 'مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ');
    expect(repository.verse('1:1')!.globalNumber, 1);
    expect(repository.verse('114:6')!.globalNumber, 6236);
  });

  test('assigns all verses to valid juz and Medina Mushaf pages', () {
    final verses = repository.data.surahs.expand((surah) => surah.verses);
    expect(verses.every((verse) => verse.juz >= 1 && verse.juz <= 30), isTrue);
    expect(
      verses.every((verse) => verse.page >= 1 && verse.page <= 604),
      isTrue,
    );
    expect(repository.data.juzs.first.startKey, '1:1');
    expect(repository.data.juzs.last.startKey, '78:1');
    expect(repository.data.juzs.last.endKey, '114:6');
  });

  test('returns exact surah and normalized Arabic verse searches', () {
    final surahResults = repository.search('الكوثر');
    expect(surahResults.any((result) => result.surah.number == 108), isTrue);

    final verseResults = repository.search('انا اعطيناك');
    expect(verseResults.any((result) => result.verse?.key == '108:1'), isTrue);

    final diacriticInsensitive = repository.search('الرحمن الرحيم');
    expect(diacriticInsensitive.any((result) => result.verse != null), isTrue);
  });
}
