class TafsirMetadata {
  const TafsirMetadata({
    required this.title,
    required this.author,
    required this.language,
    required this.sourceName,
    required this.sourceUrl,
    required this.sourceNote,
    required this.entryCount,
    required this.rubCount,
  });

  factory TafsirMetadata.fromJson(Map<String, dynamic> json) => TafsirMetadata(
    title: json['title'] as String,
    author: json['author'] as String,
    language: json['language'] as String,
    sourceName: json['sourceName'] as String,
    sourceUrl: json['sourceUrl'] as String,
    sourceNote: json['sourceNote'] as String,
    entryCount: json['entryCount'] as int,
    rubCount: json['rubCount'] as int,
  );

  final String title;
  final String author;
  final String language;
  final String sourceName;
  final String sourceUrl;
  final String sourceNote;
  final int entryCount;
  final int rubCount;
}

class TafsirEntry {
  const TafsirEntry({
    required this.key,
    required this.surah,
    required this.ayah,
    required this.endAyah,
    required this.juz,
    required this.endJuz,
    required this.startGlobal,
    required this.endGlobal,
    required this.text,
  });

  factory TafsirEntry.fromJson(Map<String, dynamic> json) => TafsirEntry(
    key: json['key'] as String,
    surah: json['surah'] as int,
    ayah: json['ayah'] as int,
    endAyah: json['endAyah'] as int,
    juz: json['juz'] as int,
    endJuz: json['endJuz'] as int,
    startGlobal: json['startGlobal'] as int,
    endGlobal: json['endGlobal'] as int,
    text: json['text'] as String,
  );

  final String key;
  final int surah;
  final int ayah;
  final int endAyah;
  final int juz;
  final int endJuz;
  final int startGlobal;
  final int endGlobal;
  final String text;

  bool containsAyah(int number) => number >= ayah && number <= endAyah;
  bool overlapsGlobalRange(int start, int end) =>
      startGlobal <= end && endGlobal >= start;
}

class TafsirRub {
  const TafsirRub({
    required this.number,
    required this.startKey,
    required this.endKey,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    required this.juz,
    required this.startGlobal,
    required this.endGlobal,
  });

  factory TafsirRub.fromJson(Map<String, dynamic> json) => TafsirRub(
    number: json['number'] as int,
    startKey: json['startKey'] as String,
    endKey: json['endKey'] as String,
    startSurah: json['startSurah'] as int,
    startAyah: json['startAyah'] as int,
    endSurah: json['endSurah'] as int,
    endAyah: json['endAyah'] as int,
    juz: json['juz'] as int,
    startGlobal: json['startGlobal'] as int,
    endGlobal: json['endGlobal'] as int,
  );

  final int number;
  final String startKey;
  final String endKey;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final int juz;
  final int startGlobal;
  final int endGlobal;
}

class TafsirData {
  const TafsirData({
    required this.metadata,
    required this.entries,
    required this.rubs,
  });

  factory TafsirData.fromJson(Map<String, dynamic> json) => TafsirData(
    metadata: TafsirMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    entries: (json['entries'] as List<dynamic>)
        .map((item) => TafsirEntry.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
    rubs: (json['rubs'] as List<dynamic>)
        .map((item) => TafsirRub.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );

  final TafsirMetadata metadata;
  final List<TafsirEntry> entries;
  final List<TafsirRub> rubs;
}
