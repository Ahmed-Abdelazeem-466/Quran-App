const standaloneBasmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ';

bool usesStandaloneBasmala({
  required int surahNumber,
  required String firstVerseText,
}) {
  return surahNumber != 9 && firstVerseText.startsWith(standaloneBasmala);
}

String withoutStandaloneBasmala(String verseText) {
  if (!verseText.startsWith(standaloneBasmala)) return verseText;
  return verseText.substring(standaloneBasmala.length).trim();
}

String toArabicIndic(int number) {
  const western = '0123456789';
  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  return number.toString().split('').map((digit) {
    return arabicIndic[western.indexOf(digit)];
  }).join();
}

/// Keeps a verse marker as one right-to-left text unit when a line reflows.
/// This avoids bidirectional placeholder reordering during orientation and
/// font-size changes while preserving the visible Mushaf-style marker.
String inlineVerseMarker(int verseNumber) =>
    '\u2067﴿${toArabicIndic(verseNumber)}﴾\u2069';
