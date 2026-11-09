import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../data/scanned_tafsir_repository.dart';
import '../data/tafsir_repository.dart';
import '../localization/app_strings.dart';
import '../localization/tafsir_strings.dart';
import '../models/quran_models.dart';
import '../models/tafsir_models.dart';
import '../models/tafsir_work.dart';
import 'reader_screen.dart';
import 'scanned_tafsir_reader_screen.dart';
import 'tafsir_index_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({
    required this.repository,
    required this.tafsirRepository,
    required this.controller,
    super.key,
  });

  final QuranRepository repository;
  final TafsirRepository tafsirRepository;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(controller.language);
    return Scaffold(
      appBar: AppBar(title: Text(strings.bookmarks)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _BookmarkSectionCard(
                icon: Icons.menu_book_rounded,
                title: strings.savedQuranAyahs,
                subtitle:
                    '${controller.bookmarks.length} • ${strings.bookmarks}',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _QuranBookmarksListScreen(
                      repository: repository,
                      controller: controller,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _BookmarkSectionCard(
                icon: Icons.format_quote_rounded,
                title: strings.savedTafsirPassages,
                subtitle:
                    '${controller.tafsirBookmarks.length} • ${strings.bookmarks}',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _TafsirBookmarksListScreen(
                      repository: repository,
                      tafsirRepository: tafsirRepository,
                      controller: controller,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookmarkSectionCard extends StatelessWidget {
  const _BookmarkSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colors.primary.withValues(alpha: 0.14),
                child: Icon(icon, color: colors.primary, size: 29),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuranBookmarksListScreen extends StatelessWidget {
  const _QuranBookmarksListScreen({
    required this.repository,
    required this.controller,
  });

  final QuranRepository repository;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(controller.language);
    return Scaffold(
      appBar: AppBar(title: Text(strings.savedQuranAyahs)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final verses =
              controller.bookmarks
                  .map(repository.verse)
                  .whereType<QuranVerse>()
                  .toList()
                ..sort((a, b) => a.globalNumber.compareTo(b.globalNumber));
          if (verses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  strings.noSavedQuranAyahs,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            itemCount: verses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _QuranBookmarkCard(
              verse: verses[index],
              repository: repository,
              controller: controller,
            ),
          );
        },
      ),
    );
  }
}

class _QuranBookmarkCard extends StatelessWidget {
  const _QuranBookmarkCard({
    required this.verse,
    required this.repository,
    required this.controller,
  });

  final QuranVerse verse;
  final QuranRepository repository;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(controller.language);
    final surah = repository.surahForVerse(verse);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReaderScreen.surah(
              repository: repository,
              controller: controller,
              surahNumber: surah.number,
              initialVerseKey: verse.key,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.language == AppLanguage.arabic
                          ? '${surah.name} • الآية ${verse.number}'
                          : '${strings.numberedSurah(surah.number, surah.transliteration)} • ${verse.number}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      verse.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 21, height: 1.8),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: strings.removeBookmark,
                onPressed: () => controller.toggleBookmark(verse.key),
                icon: const Icon(Icons.bookmark_remove_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TafsirBookmarksListScreen extends StatelessWidget {
  const _TafsirBookmarksListScreen({
    required this.repository,
    required this.tafsirRepository,
    required this.controller,
  });

  final QuranRepository repository;
  final TafsirRepository tafsirRepository;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(controller.language);
    return Scaffold(
      appBar: AppBar(title: Text(strings.savedTafsirPassages)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final entries =
              controller.tafsirBookmarks
                  .map(tafsirRepository.entryByKey)
                  .whereType<TafsirEntry>()
                  .toList()
                ..sort((a, b) => a.startGlobal.compareTo(b.startGlobal));
          final scanned =
              controller.tafsirBookmarks
                  .map(ScannedTafsirBookmark.tryParse)
                  .whereType<ScannedTafsirBookmark>()
                  .where(
                    (item) =>
                        repository.verse('${item.surah}:${item.ayah}') != null,
                  )
                  .toList()
                ..sort((a, b) {
                  final work = a.work.index.compareTo(b.work.index);
                  return work == 0 ? a.page.compareTo(b.page) : work;
                });
          if (entries.isEmpty && scanned.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  strings.noSavedTafsirPassages,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            itemCount: entries.length + scanned.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => index >= entries.length
                ? _ScannedTafsirBookmarkCard(
                    bookmark: scanned[index - entries.length],
                    repository: repository,
                    controller: controller,
                  )
                : _TafsirBookmarkCard(
                    entry: entries[index],
                    repository: repository,
                    controller: controller,
                  ),
          );
        },
      ),
    );
  }
}

class _ScannedTafsirBookmarkCard extends StatelessWidget {
  const _ScannedTafsirBookmarkCard({
    required this.bookmark,
    required this.repository,
    required this.controller,
  });
  final ScannedTafsirBookmark bookmark;
  final QuranRepository repository;
  final AppController controller;

  Future<void> _open(BuildContext context) async {
    try {
      final scanRepository = await ScannedTafsirRepository.load();
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScannedTafsirReaderScreen(
            work: bookmark.work,
            repository: repository,
            scanRepository: scanRepository,
            controller: controller,
            selectedVerse: repository.verse(
              '${bookmark.surah}:${bookmark.ayah}',
            )!,
            initialPage: bookmark.page,
          ),
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TafsirStrings(controller.language).loadFailed),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = TafsirStrings(controller.language);
    final strings = AppStrings(controller.language);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          bookmark.work.title,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${labels.page} ${bookmark.page} • ${repository.surah(bookmark.surah).name}',
        ),
        leading: const Icon(Icons.auto_stories_rounded),
        trailing: IconButton(
          tooltip: strings.removeBookmark,
          onPressed: () => controller.toggleTafsirBookmark(bookmark.key),
          icon: const Icon(Icons.bookmark_remove_rounded),
        ),
        onTap: () => _open(context),
      ),
    );
  }
}

class _TafsirBookmarkCard extends StatelessWidget {
  const _TafsirBookmarkCard({
    required this.entry,
    required this.repository,
    required this.controller,
  });

  final TafsirEntry entry;
  final QuranRepository repository;
  final AppController controller;

  String _reference(AppStrings strings) {
    final surah = repository.surah(entry.surah);
    final ayahLabel = entry.ayah == entry.endAyah
        ? '${entry.ayah}'
        : '${entry.ayah} – ${entry.endAyah}';
    final surahLabel = strings.language == AppLanguage.arabic
        ? surah.name
        : strings.numberedSurah(surah.number, surah.transliteration);
    return '${strings.tafsir} • $surahLabel • $ayahLabel';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(controller.language);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TafsirReaderScreen(
              title: _reference(strings),
              entries: [entry],
              quranRepository: repository,
              controller: controller,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _reference(strings),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 19,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: strings.removeBookmark,
                onPressed: () => controller.toggleTafsirBookmark(entry.key),
                icon: const Icon(Icons.bookmark_remove_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
