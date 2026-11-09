import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/sharing/quran_share_composer.dart';
import 'package:quran_kareem_flutter/utils/quran_reader_text.dart';

void main() {
  late QuranRepository repository;

  setUpAll(() async {
    final raw = await File('assets/data/quran.json').readAsString();
    repository = QuranRepository.fromJsonString(raw);
  });

  test('renders the basmala separately for applicable surahs', () {
    final alFatiha = repository.verse('1:1')!;
    final alBaqarah = repository.verse('2:1')!;
    final alKawthar = repository.verse('108:1')!;

    expect(
      usesStandaloneBasmala(surahNumber: 1, firstVerseText: alFatiha.text),
      isTrue,
    );
    expect(
      usesStandaloneBasmala(surahNumber: 2, firstVerseText: alBaqarah.text),
      isTrue,
    );
    expect(
      usesStandaloneBasmala(surahNumber: 108, firstVerseText: alKawthar.text),
      isTrue,
    );
  });

  test('omits standalone basmala for At-Tawbah', () {
    final atTawbah = repository.verse('9:1')!;
    expect(
      usesStandaloneBasmala(surahNumber: 9, firstVerseText: atTawbah.text),
      isFalse,
    );
  });

  test('moves only the basmala out of the first verse without text loss', () {
    final alBaqarah = repository.verse('2:1')!;
    expect(withoutStandaloneBasmala(alBaqarah.text), 'الٓمٓ');
    expect(withoutStandaloneBasmala(repository.verse('1:1')!.text), isEmpty);
    expect(
      withoutStandaloneBasmala(repository.verse('9:1')!.text),
      repository.verse('9:1')!.text,
    );
  });

  test('formats inline verse markers with Arabic-Indic numbers', () {
    expect(toArabicIndic(1), '١');
    expect(toArabicIndic(7), '٧');
    expect(toArabicIndic(108), '١٠٨');
    expect(toArabicIndic(286), '٢٨٦');
  });

  test('composes a shared opening ayah with standalone basmala and marker', () {
    final composition = composeQuranShare([repository.verse('2:1')!]);

    expect(composition.standaloneBasmala, standaloneBasmala);
    expect(composition.content, 'الٓمٓ ${inlineVerseMarker(1)}');
  });

  test('keeps At-Tawbah without a standalone basmala in shared content', () {
    final verse = repository.verse('9:1')!;
    final composition = composeQuranShare([verse]);

    expect(composition.standaloneBasmala, isNull);
    expect(composition.content, '${verse.text} ${inlineVerseMarker(1)}');
  });

  test('splits long Quran selections into readable verse-limited cards', () {
    final groups = composeQuranShareCardGroups(
      repository.surah(2).verses.take(5).toList(growable: false),
      maxVerses: 2,
      maxCharacters: 5000,
    );

    expect(groups, hasLength(3));
    expect(groups.map((group) => group.verses.length), [2, 2, 1]);
    expect(groups.first.composition.standaloneBasmala, standaloneBasmala);
    expect(groups.first.composition.content, contains(inlineVerseMarker(1)));
    expect(groups[1].composition.content, contains(inlineVerseMarker(3)));
  });

  test('starts a separate Quran share card at a new basmala-opening surah', () {
    final groups = composeQuranShareCardGroups(
      [
        repository.verse('1:6')!,
        repository.verse('1:7')!,
        repository.verse('2:1')!,
      ],
      maxVerses: 4,
      maxCharacters: 5000,
    );

    expect(groups, hasLength(2));
    expect(groups.first.verses.map((verse) => verse.key), ['1:6', '1:7']);
    expect(groups.last.verses.single.key, '2:1');
    expect(groups.last.composition.standaloneBasmala, standaloneBasmala);
  });
}
