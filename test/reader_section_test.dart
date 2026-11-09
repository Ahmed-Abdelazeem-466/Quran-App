import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/models/reader_section.dart';

void main() {
  late QuranRepository repository;

  setUpAll(() async {
    final raw = await File('assets/data/quran.json').readAsString();
    repository = QuranRepository.fromJsonString(raw);
  });

  test(
    'merges every surah into one uninterrupted section without verse loss',
    () {
      for (final surah in repository.data.surahs) {
        final sections = buildReaderSections(surah.verses);
        final reconstructed = sections
            .expand((section) => section.verses)
            .toList();

        expect(
          reconstructed.map((verse) => verse.key),
          orderedEquals(surah.verses.map((verse) => verse.key)),
        );
        expect(
          reconstructed.map((verse) => verse.text),
          orderedEquals(surah.verses.map((verse) => verse.text)),
        );
        expect(
          sections.every(
            (section) => section.verses.every(
              (verse) => verse.surahNumber == surah.number,
            ),
          ),
          isTrue,
        );
        expect(sections, hasLength(1));
        expect(sections.single.page, surah.verses.first.page);
      }
    },
  );

  test('creates continuous surah sections without page-boundary breaks', () {
    final juzVerses = repository.versesForJuz(30);
    final sections = buildReaderSections(juzVerses);

    expect(sections, isNotEmpty);
    for (final section in sections) {
      expect(section.verses, isNotEmpty);
      expect(section.page, section.verses.first.page);
      expect(
        section.verses.every(
          (verse) => verse.surahNumber == section.surahNumber,
        ),
        isTrue,
      );
    }
    expect(
      sections.map((section) => section.surahNumber).toSet(),
      hasLength(juzVerses.map((verse) => verse.surahNumber).toSet().length),
    );
  });

  test('keeps the complete Al-Fatiha flow in canonical order', () {
    final alFatiha = repository.surah(1);
    final sections = buildReaderSections(alFatiha.verses);
    final verses = sections.expand((section) => section.verses).toList();

    expect(verses, hasLength(7));
    expect(verses.first.key, '1:1');
    expect(verses.last.key, '1:7');
    expect(
      verses.map((verse) => verse.number),
      orderedEquals([1, 2, 3, 4, 5, 6, 7]),
    );
  });
}
