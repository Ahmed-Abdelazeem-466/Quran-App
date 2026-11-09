class QuranMetadata {
  const QuranMetadata({
    required this.title,
    required this.riwayah,
    required this.surahCount,
    required this.verseCount,
    required this.juzCount,
    required this.pageCount,
    required this.sourceEdition,
    required this.textSource,
    required this.textLicense,
    required this.sourceUrl,
  });

  factory QuranMetadata.fromJson(Map<String, dynamic> json) => QuranMetadata(
    title: json['title'] as String,
    riwayah: json['riwayah'] as String,
    surahCount: json['surahCount'] as int,
    verseCount: json['verseCount'] as int,
    juzCount: json['juzCount'] as int,
    pageCount: json['pageCount'] as int,
    sourceEdition: json['sourceEdition'] as String,
    textSource: json['textSource'] as String,
    textLicense: json['textLicense'] as String,
    sourceUrl: json['sourceUrl'] as String,
  );

  final String title;
  final String riwayah;
  final int surahCount;
  final int verseCount;
  final int juzCount;
  final int pageCount;
  final String sourceEdition;
  final String textSource;
  final String textLicense;
  final String sourceUrl;
}

class SajdahInfo {
  const SajdahInfo({required this.type});

  factory SajdahInfo.fromJson(Map<String, dynamic> json) =>
      SajdahInfo(type: json['type'] as String);

  final String type;
}

class QuranVerse {
  const QuranVerse({
    required this.globalNumber,
    required this.surahNumber,
    required this.number,
    required this.text,
    required this.key,
    required this.juz,
    required this.page,
    this.sajdah,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json, int surahNumber) =>
      QuranVerse(
        globalNumber: json['globalNumber'] as int,
        surahNumber: surahNumber,
        number: json['number'] as int,
        text: json['text'] as String,
        key: json['key'] as String,
        juz: json['juz'] as int,
        page: json['page'] as int,
        sajdah: json['sajdah'] == null
            ? null
            : SajdahInfo.fromJson(json['sajdah'] as Map<String, dynamic>),
      );

  final int globalNumber;
  final int surahNumber;
  final int number;
  final String text;
  final String key;
  final int juz;
  final int page;
  final SajdahInfo? sajdah;
}

class QuranSurah {
  const QuranSurah({
    required this.number,
    required this.name,
    required this.transliteration,
    required this.englishName,
    required this.revelationType,
    required this.revelationOrder,
    required this.rukuCount,
    required this.verseCount,
    required this.firstJuz,
    required this.firstPage,
    required this.verses,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> json) {
    final number = json['number'] as int;
    return QuranSurah(
      number: number,
      name: json['name'] as String,
      transliteration: json['transliteration'] as String,
      englishName: json['englishName'] as String,
      revelationType: json['revelationType'] as String,
      revelationOrder: json['revelationOrder'] as int,
      rukuCount: json['rukuCount'] as int,
      verseCount: json['verseCount'] as int,
      firstJuz: json['firstJuz'] as int,
      firstPage: json['firstPage'] as int,
      verses: (json['verses'] as List<dynamic>)
          .map(
            (item) => QuranVerse.fromJson(item as Map<String, dynamic>, number),
          )
          .toList(growable: false),
    );
  }

  final int number;
  final String name;
  final String transliteration;
  final String englishName;
  final String revelationType;
  final int revelationOrder;
  final int rukuCount;
  final int verseCount;
  final int firstJuz;
  final int firstPage;
  final List<QuranVerse> verses;
}

class QuranJuz {
  const QuranJuz({
    required this.number,
    required this.startKey,
    required this.startSurah,
    required this.startAyah,
    required this.endKey,
    required this.endSurah,
    required this.endAyah,
    required this.verseCount,
  });

  factory QuranJuz.fromJson(Map<String, dynamic> json) => QuranJuz(
    number: json['number'] as int,
    startKey: json['startKey'] as String,
    startSurah: json['startSurah'] as int,
    startAyah: json['startAyah'] as int,
    endKey: json['endKey'] as String,
    endSurah: json['endSurah'] as int,
    endAyah: json['endAyah'] as int,
    verseCount: json['verseCount'] as int,
  );

  final int number;
  final String startKey;
  final int startSurah;
  final int startAyah;
  final String endKey;
  final int endSurah;
  final int endAyah;
  final int verseCount;
}

class QuranData {
  const QuranData({
    required this.metadata,
    required this.surahs,
    required this.juzs,
  });

  factory QuranData.fromJson(Map<String, dynamic> json) => QuranData(
    metadata: QuranMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    surahs: (json['surahs'] as List<dynamic>)
        .map((item) => QuranSurah.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
    juzs: (json['juzs'] as List<dynamic>)
        .map((item) => QuranJuz.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );

  final QuranMetadata metadata;
  final List<QuranSurah> surahs;
  final List<QuranJuz> juzs;
}

class QuranSearchResult {
  const QuranSearchResult({required this.surah, this.verse});

  final QuranSurah surah;
  final QuranVerse? verse;

  String get key => verse?.key ?? '${surah.number}:1';
}
