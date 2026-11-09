import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../data/tafsir_repository.dart';
import '../data/waqf_marks.dart';
import '../localization/app_strings.dart';
import 'bookmarks_screen.dart';
import 'reader_screen.dart';
import 'reminders_screen.dart';
import 'search_screen.dart';
import 'surah_index_screen.dart';
import 'waqf_marks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.repository,
    required this.tafsirRepository,
    required this.controller,
    required this.onOpenQuranBrowse,
    super.key,
  });

  final QuranRepository repository;
  final TafsirRepository tafsirRepository;
  final AppController controller;
  final ValueChanged<QuranBrowseSection> onOpenQuranBrowse;

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            SearchScreen(repository: repository, controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final strings = AppStrings(controller.language);
          final waqfContent = waqfMarksContentFor(controller.language);
          final lastVerse = repository.verse(controller.lastVerseKey);
          final lastSurah = lastVerse == null
              ? null
              : repository.surahForVerse(lastVerse);
          final resumeSurah = lastSurah ?? repository.surah(1);
          final resumeSurahLabel = controller.language == AppLanguage.arabic
              ? 'سورة ${resumeSurah.name}'
              : strings.numberedSurah(
                  resumeSurah.number,
                  resumeSurah.transliteration,
                );
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    controller.language == AppLanguage.arabic
                        ? 'القرآن الكريم'
                        : 'Quran Kareem',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.secondary],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.auto_stories_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                          const SizedBox(height: 22),
                          Text(
                            lastVerse == null
                                ? strings.selectToRead
                                : strings.lastReading,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            resumeSurahLabel,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: colors.primary,
                            ),
                            onPressed: () {
                              final surah = resumeSurah;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ReaderScreen.surah(
                                    repository: repository,
                                    controller: controller,
                                    surahNumber: surah.number,
                                    initialVerseKey: lastVerse?.key,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(resumeSurahLabel),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    strings.selectToRead,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.14,
                  children: [
                    _QuickCard(
                      icon: Icons.menu_book_rounded,
                      title: strings.surahs,
                      subtitle: '114 ${strings.surahs}',
                      onTap: () => onOpenQuranBrowse(QuranBrowseSection.surah),
                    ),
                    _QuickCard(
                      icon: Icons.notifications_active_rounded,
                      title: strings.reminders,
                      subtitle:
                          '${controller.reminders.length} ${strings.reminders}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RemindersScreen(
                            repository: repository,
                            controller: controller,
                          ),
                        ),
                      ),
                    ),
                    _QuickCard(
                      icon: Icons.bookmark_rounded,
                      title: strings.bookmarks,
                      subtitle:
                          '${controller.bookmarks.length + controller.tafsirBookmarks.length} ${strings.bookmarks}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookmarksScreen(
                            repository: repository,
                            tafsirRepository: tafsirRepository,
                            controller: controller,
                          ),
                        ),
                      ),
                    ),
                    _QuickCard(
                      icon: Icons.search_rounded,
                      title: strings.searchAyah,
                      subtitle: strings.searchHelp,
                      onTap: () => _openSearch(context),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              WaqfMarksScreen(language: controller.language),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.pause_circle_outline_rounded,
                                color: colors.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    waqfContent.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  const Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Text(
                                      'م  •  لا  •  ج  •  قلى  •  صلى',
                                      style: TextStyle(
                                        fontFamily: 'NotoNaskhArabic',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ),
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

class _QuickCard extends StatelessWidget {
  const _QuickCard({
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.primary, size: 30),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
