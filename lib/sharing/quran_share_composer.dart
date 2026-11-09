import '../models/quran_models.dart';
import '../utils/quran_reader_text.dart';

class QuranShareComposition {
  const QuranShareComposition({
    required this.content,
    required this.standaloneBasmala,
  });

  final String content;
  final String? standaloneBasmala;
}

class QuranShareCardGroup {
  const QuranShareCardGroup({required this.verses, required this.composition});

  final List<QuranVerse> verses;
  final QuranShareComposition composition;
}

const maxQuranVersesPerShareCard = 4;
const maxQuranCharactersPerShareCard = 460;

QuranShareComposition composeQuranShare(List<QuranVerse> verses) {
  final content = <String>[];
  String? standalone;

  for (final verse in verses) {
    var text = verse.text;
    final opensSurahWithBasmala =
        verse.number == 1 &&
        usesStandaloneBasmala(
          surahNumber: verse.surahNumber,
          firstVerseText: verse.text,
        );
    if (opensSurahWithBasmala) {
      standalone ??= standaloneBasmala;
      text = withoutStandaloneBasmala(text);
    }
    content.add('$text ${inlineVerseMarker(verse.number)}');
  }

  return QuranShareComposition(
    content: content.join(' '),
    standaloneBasmala: standalone,
  );
}

List<QuranShareComposition> composeQuranShareCards(
  List<QuranVerse> verses, {
  int maxVerses = maxQuranVersesPerShareCard,
  int maxCharacters = maxQuranCharactersPerShareCard,
}) => composeQuranShareCardGroups(
  verses,
  maxVerses: maxVerses,
  maxCharacters: maxCharacters,
).map((group) => group.composition).toList(growable: false);

List<QuranShareCardGroup> composeQuranShareCardGroups(
  List<QuranVerse> verses, {
  int maxVerses = maxQuranVersesPerShareCard,
  int maxCharacters = maxQuranCharactersPerShareCard,
}) {
  if (verses.isEmpty) return const [];
  assert(maxVerses > 0);
  assert(maxCharacters > 0);

  final groups = <List<QuranVerse>>[];
  var current = <QuranVerse>[];
  var currentCharacters = 0;

  for (final verse in verses) {
    final opensSurahWithBasmala =
        verse.number == 1 &&
        usesStandaloneBasmala(
          surahNumber: verse.surahNumber,
          firstVerseText: verse.text,
        );
    final estimatedCharacters =
        verse.text.length + inlineVerseMarker(verse.number).length + 2;
    final startsNewSurahCard = current.isNotEmpty && opensSurahWithBasmala;
    final exceedsVerseLimit = current.length >= maxVerses;
    final exceedsCharacterLimit =
        current.isNotEmpty &&
        currentCharacters + estimatedCharacters > maxCharacters;

    if (startsNewSurahCard || exceedsVerseLimit || exceedsCharacterLimit) {
      groups.add(current);
      current = <QuranVerse>[];
      currentCharacters = 0;
    }

    current.add(verse);
    currentCharacters += estimatedCharacters;
  }

  if (current.isNotEmpty) groups.add(current);
  return [
    for (final group in groups)
      QuranShareCardGroup(
        verses: List<QuranVerse>.unmodifiable(group),
        composition: composeQuranShare(group),
      ),
  ];
}
