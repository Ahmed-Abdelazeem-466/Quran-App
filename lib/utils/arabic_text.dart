String normalizeArabic(String input) {
  return input
      .toLowerCase()
      .replaceAll('\u0670', 'ا')
      .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u06D6-\u06ED]'), '')
      .replaceAll('ـ', '')
      .replaceAll(RegExp('[إأآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String normalizeArabicLoose(String input) {
  return normalizeArabic(input).replaceAll('ا', '');
}
