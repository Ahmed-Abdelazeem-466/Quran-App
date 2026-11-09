import '../data/quran_repository.dart';

enum ReaderDisplayMode {
  standard,
  fullScreen;

  ReaderDisplayMode get toggled => switch (this) {
    ReaderDisplayMode.standard => ReaderDisplayMode.fullScreen,
    ReaderDisplayMode.fullScreen => ReaderDisplayMode.standard,
  };
}

bool shouldExitFullscreenOnBack(ReaderDisplayMode mode) =>
    mode == ReaderDisplayMode.fullScreen;

class SavedVerseDestination {
  const SavedVerseDestination({
    required this.surahNumber,
    required this.verseKey,
  });

  final int surahNumber;
  final String verseKey;
}

SavedVerseDestination? resolveSavedVerseDestination({
  required QuranRepository repository,
  required String? verseKey,
}) {
  if (verseKey == null) return null;
  final verse = repository.verse(verseKey);
  if (verse == null) return null;
  return SavedVerseDestination(
    surahNumber: verse.surahNumber,
    verseKey: verse.key,
  );
}
