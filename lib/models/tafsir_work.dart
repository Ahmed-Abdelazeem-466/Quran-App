enum TafsirWork {
  saadi(
    'saadi',
    'تفسير السعدي',
    'تيسير الكريم الرحمن في تفسير كلام المنان',
    null,
    0,
  ),
  muyassar(
    'muyassar',
    'التفسير الميسر',
    'مجمع الملك فهد لطباعة المصحف الشريف',
    'assets/tafsir/tafsir_muyassar.pdf',
    609,
  ),
  ibnKathir(
    'ibnKathir',
    'تفسير ابن كثير',
    'تفسير القرآن العظيم',
    'assets/tafsir/tafsir_ibn_kathir.pdf',
    2061,
  );

  const TafsirWork(
    this.id,
    this.title,
    this.subtitle,
    this.assetPath,
    this.pageCount,
  );

  final String id;
  final String title;
  final String subtitle;
  final String? assetPath;
  final int pageCount;
  bool get isScanned => assetPath != null;

  static TafsirWork? fromId(String id) =>
      values.where((work) => work.id == id).firstOrNull;
}

/// Page bookmarks retain their source, so a page number can never collide with
/// a Sa‘di entry or a page from a different book. Ayah is selection context,
/// not a claimed precise location inside an unindexed scan.
class ScannedTafsirBookmark {
  const ScannedTafsirBookmark({
    required this.work,
    required this.page,
    required this.surah,
    required this.ayah,
  });

  final TafsirWork work;
  final int page;
  final int surah;
  final int ayah;

  String get key => 'pdf|${work.id}|$page|$surah|$ayah';

  static ScannedTafsirBookmark? tryParse(String key) {
    final parts = key.split('|');
    if (parts.length != 5 || parts[0] != 'pdf') return null;
    final work = TafsirWork.fromId(parts[1]);
    final page = int.tryParse(parts[2]);
    final surah = int.tryParse(parts[3]);
    final ayah = int.tryParse(parts[4]);
    if (work == null ||
        !work.isScanned ||
        page == null ||
        page < 1 ||
        page > work.pageCount ||
        surah == null ||
        surah < 1 ||
        surah > 114 ||
        ayah == null ||
        ayah < 1) {
      return null;
    }
    return ScannedTafsirBookmark(
      work: work,
      page: page,
      surah: surah,
      ayah: ayah,
    );
  }
}
