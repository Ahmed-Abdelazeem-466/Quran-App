import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/sharing/tafsir_share_composer.dart';

void main() {
  test('splits Tafsir text into word-limited share cards', () {
    final cards = composeTafsirShareCards(const [
      TafsirShareSection(
        reference: 'سورة الفاتحة • الآية ١',
        text: 'واحد اثنان ثلاثة أربعة خمسة ستة سبعة',
      ),
    ], maxWords: 3);

    expect(cards, hasLength(3));
    expect(cards.map((card) => card.content), [
      'واحد اثنان ثلاثة',
      'أربعة خمسة ستة',
      'سبعة',
    ]);
    expect(cards.every((card) => card.reference.contains('الفاتحة')), isTrue);
  });

  test('keeps separate Tafsir passages as separate readable card series', () {
    final cards = composeTafsirShareCards(const [
      TafsirShareSection(reference: 'مرجع ١', text: 'أ ب ج د'),
      TafsirShareSection(reference: 'مرجع ٢', text: 'هـ و'),
    ], maxWords: 2);

    expect(cards.map((card) => card.reference), ['مرجع ١', 'مرجع ١', 'مرجع ٢']);
    expect(cards.map((card) => card.content), ['أ ب', 'ج د', 'هـ و']);
  });
}
