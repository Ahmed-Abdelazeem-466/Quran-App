import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/data/waqf_marks.dart';
import 'package:quran_kareem_flutter/localization/app_strings.dart';

void main() {
  test('Waqf Mark symbols and Arabic names stay unchanged', () {
    expect(
      waqfMarkDefinitions.map((definition) => definition.symbol),
      equals(['م', 'لا', 'ج', 'قلى', 'صلى', 'ۛ ۛ']),
    );
    expect(
      waqfMarkDefinitions.map((definition) => definition.arabicName),
      equals([
        'وقف لازم',
        'لا تقف',
        'وقف جائز',
        'الوقف أولى',
        'الوصل أولى',
        'وقف المعانقة',
      ]),
    );
  });

  test('Waqf reference lesson retains all six exact Uthmani examples', () {
    expect(waqfMarkDefinitions, hasLength(6));
    expect(
      waqfMarkDefinitions.every(
        (definition) =>
            definition.referenceBeforeExample.isNotEmpty &&
            definition.quranExample.isNotEmpty &&
            definition.referenceAfterExample.isNotEmpty,
      ),
      isTrue,
    );
    expect(
      waqfMarkDefinitions.map((definition) => definition.quranReference),
      equals([
        'الأنعام: ٣٦',
        'النحل: ٣٢',
        'الكهف: ١٣',
        'الكهف: ٢٢',
        'الأنعام: ١٧',
        'البقرة: ٢',
      ]),
    );
    expect(
      waqfMarkDefinitions.last.quranExample,
      contains(
        'ذَٰلِكَ ٱلْكِتَـٰبُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
      ),
    );
    expect(
      waqfReferenceSections.map((section) => section.title),
      equals([
        'علامات الوقف في المصحف الشريف',
        'الوقف في القرآن الكريم',
        'أنواع الوقف',
        'أهمية الوقف',
      ]),
    );
    expect(
      waqfReferenceSections.expand((section) => section.paragraphs).join('\n'),
      allOf(
        contains('كانت المصاحف في بدايتها تخلو من علامات الوقف'),
        contains('تعريف الوقف وحكمه'),
        contains('الوقف الاختباري'),
        contains('الوقف الانتظاري'),
        contains('الوقف الاضطراري'),
        contains('الوقف الاختياري'),
      ),
    );
  });

  test('Waqf explanations are available for every app language', () {
    for (final language in AppLanguage.values) {
      final content = waqfMarksContentFor(language);
      expect(content.title, isNotEmpty);
      expect(content.intro, isNotEmpty);
      expect(content.note, isNotEmpty);
      expect(content.teacherNote, isNotEmpty);
      expect(content.explanations, hasLength(waqfMarkDefinitions.length));
      expect(
        content.explanations.every((explanation) => explanation.isNotEmpty),
        isTrue,
      );
    }
  });

  test('Waqf lesson explanatory copy follows the selected language', () {
    final englishSections = waqfReferenceSectionsFor(AppLanguage.english);
    final englishDetails = waqfMarkReferenceDetailsFor(AppLanguage.english);
    final arabicSections = waqfReferenceSectionsFor(AppLanguage.arabic);

    expect(englishSections.first.title, 'Waqf Marks in the Noble Mushaf');
    expect(
      englishSections.expand((section) => section.paragraphs).join('\n'),
      contains('Definition and ruling of Waqf'),
    );
    expect(englishDetails.first.beforeExample, startsWith('م means'));
    expect(englishDetails.first.beforeExample, isNot(contains('تعني')));
    expect(arabicSections.first.title, 'علامات الوقف في المصحف الشريف');
    expect(
      waqfMarkDefinitions.first.quranExample,
      contains('إِنَّمَا يَسْتَجِيبُ'),
    );
  });

  test('Every app language has detailed translated Waqf lesson content', () {
    for (final language in AppLanguage.values) {
      final sections = waqfReferenceSectionsFor(language);
      final details = waqfMarkReferenceDetailsFor(language);
      expect(sections, hasLength(4));
      expect(details, hasLength(waqfMarkDefinitions.length));
      expect(sections.every((section) => section.title.isNotEmpty), isTrue);
      expect(
        sections.every((section) => section.paragraphs.isNotEmpty),
        isTrue,
      );
      expect(
        details.every(
          (detail) =>
              detail.beforeExample.isNotEmpty && detail.afterExample.isNotEmpty,
        ),
        isTrue,
      );
    }
    expect(
      waqfReferenceSectionsFor(AppLanguage.chinese).first.title,
      '尊贵穆斯哈夫中的停顿标记',
    );
    expect(
      waqfMarkReferenceDetailsFor(AppLanguage.chinese).first.beforeExample,
      '古兰经示例：',
    );
  });
}
