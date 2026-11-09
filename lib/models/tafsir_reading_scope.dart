import 'quran_models.dart';

/// The exact Quran verse interval a scanned tafsir reader was opened for.
///
/// Scanned books are rendered as complete source pages. A page shared by a
/// scope boundary can therefore show verses just outside this interval; the
/// reader constrains navigation and selection, but deliberately does not crop
/// arbitrary text out of the original scan.
class TafsirReadingScope {
  const TafsirReadingScope({
    required this.startVerseKey,
    required this.endVerseKey,
    required this.startGlobal,
    required this.endGlobal,
  }) : assert(startGlobal <= endGlobal);

  factory TafsirReadingScope.fromVerses({
    required QuranVerse start,
    required QuranVerse end,
  }) => TafsirReadingScope(
    startVerseKey: start.key,
    endVerseKey: end.key,
    startGlobal: start.globalNumber,
    endGlobal: end.globalNumber,
  );

  factory TafsirReadingScope.forSurah(QuranSurah surah) =>
      TafsirReadingScope.fromVerses(
        start: surah.verses.first,
        end: surah.verses.last,
      );

  final String startVerseKey;
  final String endVerseKey;
  final int startGlobal;
  final int endGlobal;

  bool contains(QuranVerse verse) =>
      verse.globalNumber >= startGlobal && verse.globalNumber <= endGlobal;

  @override
  bool operator ==(Object other) =>
      other is TafsirReadingScope &&
      other.startVerseKey == startVerseKey &&
      other.endVerseKey == endVerseKey &&
      other.startGlobal == startGlobal &&
      other.endGlobal == endGlobal;

  @override
  int get hashCode =>
      Object.hash(startVerseKey, endVerseKey, startGlobal, endGlobal);
}
