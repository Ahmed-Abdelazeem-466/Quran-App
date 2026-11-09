import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../data/tafsir_repository.dart';
import '../localization/app_strings.dart';
import '../widgets/surah_list_tile.dart';
import 'reader_screen.dart';

enum QuranBrowseSection { surah, juz, rub }

class SurahIndexScreen extends StatefulWidget {
  const SurahIndexScreen({
    required this.repository,
    required this.tafsirRepository,
    required this.controller,
    this.initialSection = QuranBrowseSection.surah,
    super.key,
  });

  final QuranRepository repository;
  final TafsirRepository tafsirRepository;
  final AppController controller;
  final QuranBrowseSection initialSection;

  @override
  State<SurahIndexScreen> createState() => _SurahIndexScreenState();
}

class _SurahIndexScreenState extends State<SurahIndexScreen> {
  String _query = '';
  late QuranBrowseSection _section;

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.controller.language);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.surahIndex,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                SegmentedButton<QuranBrowseSection>(
                  segments: [
                    ButtonSegment(
                      value: QuranBrowseSection.surah,
                      icon: const Icon(Icons.menu_book_rounded),
                      label: Text(strings.surah),
                    ),
                    ButtonSegment(
                      value: QuranBrowseSection.juz,
                      icon: const Icon(Icons.auto_stories_rounded),
                      label: Text(strings.juz),
                    ),
                    ButtonSegment(
                      value: QuranBrowseSection.rub,
                      icon: const Icon(Icons.grid_view_rounded),
                      label: Text(strings.rub),
                    ),
                  ],
                  selected: {_section},
                  onSelectionChanged: (value) =>
                      setState(() => _section = value.first),
                ),
                if (_section == QuranBrowseSection.surah) ...[
                  const SizedBox(height: 14),
                  TextField(
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: strings.searchSurah,
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(child: _buildSection(strings)),
        ],
      ),
    );
  }

  Widget _buildSection(AppStrings strings) => switch (_section) {
    QuranBrowseSection.surah => _surahList(strings),
    QuranBrowseSection.juz => _juzList(strings),
    QuranBrowseSection.rub => _rubList(strings),
  };

  Widget _surahList(AppStrings strings) {
    final normalized = _query.trim().toLowerCase();
    final surahs = widget.repository.data.surahs
        .where((surah) {
          if (normalized.isEmpty) return true;
          return surah.name.contains(normalized) ||
              surah.transliteration.toLowerCase().contains(normalized) ||
              '${surah.number}'.contains(normalized);
        })
        .toList(growable: false);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      itemCount: surahs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return SurahListTile(
          surah: surah,
          strings: strings,
          onTap: () => _openSurah(surah.number),
        );
      },
    );
  }

  Widget _juzList(AppStrings strings) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
    itemCount: widget.repository.data.juzs.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final juz = widget.repository.data.juzs[index];
      final firstSurah = widget.repository.surah(juz.startSurah);
      final lastSurah = widget.repository.surah(juz.endSurah);
      final range = strings.language == AppLanguage.arabic
          ? 'من ${firstSurah.name} ${juz.startAyah} إلى ${lastSurah.name} ${juz.endAyah}'
          : '${strings.from} ${firstSurah.transliteration} ${juz.startAyah} ${strings.to} ${lastSurah.transliteration} ${juz.endAyah}';
      return _QuranRangeTile(
        icon: Icons.auto_stories_rounded,
        number: juz.number,
        title: strings.numberedJuz(juz.number),
        subtitle: range,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReaderScreen.juz(
              repository: widget.repository,
              controller: widget.controller,
              juzNumber: juz.number,
            ),
          ),
        ),
      );
    },
  );

  Widget _rubList(AppStrings strings) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
    itemCount: widget.tafsirRepository.data.rubs.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final rub = widget.tafsirRepository.data.rubs[index];
      final firstSurah = widget.repository.surah(rub.startSurah);
      final lastSurah = widget.repository.surah(rub.endSurah);
      final range = strings.language == AppLanguage.arabic
          ? '${strings.numberedJuz(rub.juz)} • ${firstSurah.name} ${rub.startAyah} – ${lastSurah.name} ${rub.endAyah}'
          : '${strings.numberedJuz(rub.juz)} • ${firstSurah.transliteration} ${rub.startAyah} – ${lastSurah.transliteration} ${rub.endAyah}';
      return _QuranRangeTile(
        icon: Icons.grid_view_rounded,
        number: rub.number,
        title: '${strings.rub} ${rub.number}',
        subtitle: range,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReaderScreen.rub(
              repository: widget.repository,
              controller: widget.controller,
              rubNumber: rub.number,
              startVerseKey: rub.startKey,
              endVerseKey: rub.endKey,
            ),
          ),
        ),
      );
    },
  );

  void _openSurah(int number) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReaderScreen.surah(
          repository: widget.repository,
          controller: widget.controller,
          surahNumber: number,
        ),
      ),
    );
  }
}

class _QuranRangeTile extends StatelessWidget {
  const _QuranRangeTile({
    required this.icon,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final int number;
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                '$number',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_left_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
