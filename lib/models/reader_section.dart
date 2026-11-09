import 'quran_models.dart';

class ReaderSection {
  const ReaderSection({
    required this.page,
    required this.surahNumber,
    required this.verses,
  });

  final int page;
  final int surahNumber;
  final List<QuranVerse> verses;

  String get firstVerseKey => verses.first.key;
}

/// Uses one uninterrupted text section per surah. Medina-page metadata is
/// retained but never introduces an artificial break in the reading flow.
List<ReaderSection> buildReaderSections(List<QuranVerse> verses) {
  if (verses.isEmpty) return const [];
  final sections = <ReaderSection>[];
  var page = verses.first.page;
  var surahNumber = verses.first.surahNumber;
  var current = <QuranVerse>[];

  for (final verse in verses) {
    if (current.isNotEmpty && verse.surahNumber != surahNumber) {
      sections.add(
        ReaderSection(
          page: page,
          surahNumber: surahNumber,
          verses: List.unmodifiable(current),
        ),
      );
      current = <QuranVerse>[];
      page = verse.page;
      surahNumber = verse.surahNumber;
    }
    current.add(verse);
  }
  sections.add(
    ReaderSection(
      page: page,
      surahNumber: surahNumber,
      verses: List.unmodifiable(current),
    ),
  );
  return List.unmodifiable(sections);
}
