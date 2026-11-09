import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/utils/reader_navigation.dart';

void main() {
  late QuranRepository repository;

  setUpAll(() async {
    final raw = await File('assets/data/quran.json').readAsString();
    repository = QuranRepository.fromJsonString(raw);
  });

  test('toggles reader display mode between standard and full screen', () {
    expect(ReaderDisplayMode.standard.toggled, ReaderDisplayMode.fullScreen);
    expect(ReaderDisplayMode.fullScreen.toggled, ReaderDisplayMode.standard);
  });

  test('resolves a stored verse key to its exact surah and verse target', () {
    final destination = resolveSavedVerseDestination(
      repository: repository,
      verseKey: '2:255',
    );

    expect(destination, isNotNull);
    expect(destination!.surahNumber, 2);
    expect(destination.verseKey, '2:255');
  });

  test('rejects missing and invalid saved verse keys safely', () {
    expect(
      resolveSavedVerseDestination(repository: repository, verseKey: null),
      isNull,
    );
    expect(
      resolveSavedVerseDestination(repository: repository, verseKey: '999:1'),
      isNull,
    );
  });
}
