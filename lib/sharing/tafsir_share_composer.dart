const maxTafsirWordsPerShareCard = 90;

class TafsirShareSection {
  const TafsirShareSection({required this.reference, required this.text});

  final String reference;
  final String text;
}

class TafsirShareCardGroup {
  const TafsirShareCardGroup({required this.reference, required this.content});

  final String reference;
  final String content;
}

List<TafsirShareCardGroup> composeTafsirShareCards(
  List<TafsirShareSection> sections, {
  int maxWords = maxTafsirWordsPerShareCard,
}) {
  assert(maxWords > 0);
  final cards = <TafsirShareCardGroup>[];
  for (final section in sections) {
    final words = section.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) continue;
    for (var start = 0; start < words.length; start += maxWords) {
      final end = (start + maxWords).clamp(0, words.length);
      cards.add(
        TafsirShareCardGroup(
          reference: section.reference,
          content: words.sublist(start, end).join(' '),
        ),
      );
    }
  }
  return cards;
}
