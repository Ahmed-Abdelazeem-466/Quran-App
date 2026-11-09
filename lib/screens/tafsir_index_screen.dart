import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../data/scanned_tafsir_repository.dart';
import '../data/tafsir_repository.dart';
import '../localization/app_strings.dart';
import '../localization/tafsir_strings.dart';
import '../models/quran_models.dart';
import '../models/tafsir_models.dart';
import '../models/tafsir_reading_scope.dart';
import '../models/tafsir_work.dart';
import '../sharing/branded_quote_share.dart';
import '../sharing/tafsir_share_composer.dart';
import '../widgets/ayah_wheel_picker.dart';
import 'scanned_tafsir_reader_screen.dart';

class TafsirIndexScreen extends StatefulWidget {
  const TafsirIndexScreen({
    required this.quranRepository,
    required this.tafsirRepository,
    required this.controller,
    super.key,
  });

  final QuranRepository quranRepository;
  final TafsirRepository tafsirRepository;
  final AppController controller;

  @override
  State<TafsirIndexScreen> createState() => _TafsirIndexScreenState();
}

class _TafsirIndexScreenState extends State<TafsirIndexScreen> {
  _TafsirNavigationMode _mode = _TafsirNavigationMode.surah;
  TafsirWork? _selectedWork;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings(widget.controller.language);
    final labels = TafsirStrings(widget.controller.language);
    if (_selectedWork == null) {
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Text(
              strings.tafsir,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              labels.chooseTafsir,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            for (final work in TafsirWork.values) ...[
              Card(
                key: ValueKey('tafsir-work-${work.id}'),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                    child: const Icon(Icons.auto_stories_rounded),
                  ),
                  title: Text(
                    work.title,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(work.subtitle, textDirection: TextDirection.rtl),
                      const SizedBox(height: 4),
                      Text(
                        work.isScanned
                            ? '${AppLanguage.arabic.nativeName} • ${labels.originalScan}'
                            : AppLanguage.arabic.nativeName,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => setState(() {
                    _selectedWork = work;
                    _mode = _TafsirNavigationMode.surah;
                  }),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _selectedWork = null);
      },
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: labels.chooseTafsir,
                        onPressed: () => setState(() => _selectedWork = null),
                        icon: const BackButtonIcon(),
                      ),
                      Expanded(
                        child: Text(
                          _selectedWork!.title,
                          textDirection: TextDirection.rtl,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedWork!.subtitle,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<_TafsirNavigationMode>(
                    segments: [
                      ButtonSegment(
                        value: _TafsirNavigationMode.surah,
                        icon: const Icon(Icons.menu_book_rounded),
                        label: Text(strings.surah),
                      ),
                      ButtonSegment(
                        value: _TafsirNavigationMode.juz,
                        icon: const Icon(Icons.auto_stories_rounded),
                        label: Text(strings.juz),
                      ),
                      ButtonSegment(
                        value: _TafsirNavigationMode.rub,
                        icon: const Icon(Icons.grid_view_rounded),
                        label: Text(strings.rub),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (value) =>
                        setState(() => _mode = value.first),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList() => switch (_mode) {
    _TafsirNavigationMode.surah => _surahList(),
    _TafsirNavigationMode.juz => _juzList(),
    _TafsirNavigationMode.rub => _rubList(),
  };

  Widget _surahList() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
    itemCount: 114,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final surah = widget.quranRepository.surah(index + 1);
      final strings = AppStrings(widget.controller.language);
      return _IndexCard(
        icon: Icons.menu_book_rounded,
        title: strings.language == AppLanguage.arabic
            ? 'سورة ${surah.name}'
            : strings.numberedSurah(surah.number, surah.transliteration),
        subtitle: '${surah.verseCount} ${strings.verses}',
        onTap: () => _openSurah(surah),
      );
    },
  );

  Widget _juzList() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
    itemCount: widget.quranRepository.data.juzs.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final juz = widget.quranRepository.data.juzs[index];
      final startVerse = widget.quranRepository.verse(juz.startKey)!;
      final endVerse = widget.quranRepository.verse(juz.endKey)!;
      final entries = widget.tafsirRepository.forJuz(
        juzNumber: juz.number,
        startGlobal: startVerse.globalNumber,
        endGlobal: endVerse.globalNumber,
      );
      final firstSurah = widget.quranRepository.surah(juz.startSurah);
      final lastSurah = widget.quranRepository.surah(juz.endSurah);
      final strings = AppStrings(widget.controller.language);
      return _IndexCard(
        icon: Icons.auto_stories_rounded,
        title: strings.numberedJuz(juz.number),
        subtitle:
            '${strings.from} ${firstSurah.name} ${juz.startAyah} ${strings.to} ${lastSurah.name} ${juz.endAyah}',
        onTap: () => _selectedWork!.isScanned
            ? _openScan(
                startVerse,
                scope: TafsirReadingScope.fromVerses(
                  start: startVerse,
                  end: endVerse,
                ),
              )
            : _openReader(
                title:
                    '${_selectedWork!.title} • ${strings.numberedJuz(juz.number)}',
                entries: entries,
              ),
      );
    },
  );

  Widget _rubList() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
    itemCount: widget.tafsirRepository.data.rubs.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final rub = widget.tafsirRepository.data.rubs[index];
      final startSurah = widget.quranRepository.surah(rub.startSurah);
      final endSurah = widget.quranRepository.surah(rub.endSurah);
      final strings = AppStrings(widget.controller.language);
      return _IndexCard(
        icon: Icons.grid_view_rounded,
        title: '${strings.rub} ${rub.number}',
        subtitle:
            '${strings.juz} ${rub.juz} • ${startSurah.name} ${rub.startAyah} – ${endSurah.name} ${rub.endAyah}',
        onTap: () => _selectedWork!.isScanned
            ? _openScan(
                widget.quranRepository.verse(
                  '${rub.startSurah}:${rub.startAyah}',
                )!,
                scope: TafsirReadingScope.fromVerses(
                  start: widget.quranRepository.verse(rub.startKey)!,
                  end: widget.quranRepository.verse(rub.endKey)!,
                ),
              )
            : _openReader(
                title: '${_selectedWork!.title} • ${strings.rub} ${rub.number}',
                entries: widget.tafsirRepository.forRub(rub.number),
              ),
      );
    },
  );

  Future<void> _openSurah(QuranSurah surah) async {
    final work = _selectedWork!;
    final ayah = await AyahWheelPicker.show(
      context,
      surah: surah,
      strings: AppStrings(widget.controller.language),
    );
    if (!mounted || ayah == null || _selectedWork != work) return;
    final verse = surah.verses[ayah - 1];
    if (work.isScanned) {
      await _openScan(verse, scope: TafsirReadingScope.forSurah(surah));
    } else {
      _openReader(
        title: '${work.title} • ${surah.name}',
        entries: widget.tafsirRepository.forSurah(surah.number),
        initialVerseKey: verse.key,
      );
    }
  }

  Future<void> _openScan(QuranVerse verse, {TafsirReadingScope? scope}) async {
    final work = _selectedWork!;
    try {
      final repository = await ScannedTafsirRepository.load();
      if (!mounted || _selectedWork != work) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScannedTafsirReaderScreen(
            work: work,
            repository: widget.quranRepository,
            scanRepository: repository,
            controller: widget.controller,
            selectedVerse: verse,
            initialPage: repository.pageForVerse(work, verse),
            scope: scope,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TafsirStrings(widget.controller.language).loadFailed),
          ),
        );
      }
    }
  }

  void _openReader({
    required String title,
    required List<TafsirEntry> entries,
    String? initialVerseKey,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TafsirReaderScreen(
          title: title,
          entries: entries,
          quranRepository: widget.quranRepository,
          controller: widget.controller,
          initialVerseKey: initialVerseKey,
        ),
      ),
    );
  }
}

enum _TafsirNavigationMode { surah, juz, rub }

class TafsirReaderScreen extends StatefulWidget {
  const TafsirReaderScreen({
    required this.title,
    required this.entries,
    required this.quranRepository,
    required this.controller,
    this.initialVerseKey,
    super.key,
  });

  final String title;
  final List<TafsirEntry> entries;
  final QuranRepository quranRepository;
  final AppController controller;
  final String? initialVerseKey;

  @override
  State<TafsirReaderScreen> createState() => _TafsirReaderScreenState();
}

class _TafsirReaderScreenState extends State<TafsirReaderScreen> {
  final Set<String> _selectedEntryKeys = <String>{};
  final Map<String, String> _selectedExcerptByEntryKey = <String, String>{};
  var _selectionMode = false;
  final _itemScrollController = ItemScrollController();

  int get _initialIndex {
    if (widget.initialVerseKey == null) return 0;
    final verse = widget.quranRepository.verse(widget.initialVerseKey!);
    if (verse == null) return 0;
    final index = widget.entries.indexWhere(
      (entry) =>
          entry.surah == verse.surahNumber &&
          entry.ayah <= verse.number &&
          entry.endAyah >= verse.number,
    );
    return index < 0 ? 0 : index;
  }

  Future<void> _chooseAyah() async {
    if (widget.entries.isEmpty) return;
    final surah = widget.quranRepository.surah(
      widget.entries[_initialIndex].surah,
    );
    final ayah = await AyahWheelPicker.show(
      context,
      surah: surah,
      strings: AppStrings(widget.controller.language),
      initialAyah: widget.entries[_initialIndex].ayah,
    );
    if (!mounted || ayah == null) return;
    final index = widget.entries.indexWhere(
      (entry) =>
          entry.surah == surah.number &&
          entry.ayah <= ayah &&
          entry.endAyah >= ayah,
    );
    if (index >= 0 && _itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  void _startSelection() => setState(() {
    _selectionMode = true;
    _selectedEntryKeys.clear();
    _selectedExcerptByEntryKey.clear();
  });

  void _toggleSelection(String key) => setState(() {
    if (!_selectedEntryKeys.add(key)) _selectedEntryKeys.remove(key);
  });

  void _clearSelection() => setState(() {
    _selectionMode = false;
    _selectedEntryKeys.clear();
    _selectedExcerptByEntryKey.clear();
  });

  Future<void> _shareSelectedEntries() async {
    final selected = widget.entries
        .where((entry) => _selectedEntryKeys.contains(entry.key))
        .toList(growable: false);
    if (selected.isEmpty) return;
    final strings = AppStrings(widget.controller.language);
    final cards = composeTafsirShareCards([
      for (final entry in selected)
        TafsirShareSection(reference: _referenceFor(entry), text: entry.text),
    ]);
    await BrandedQuoteShareSheet.show(
      context,
      cards: [
        for (final card in cards)
          BrandedShareCardData(
            title: strings.tafsirSaadiShareTitle,
            reference: card.reference,
            content: card.content,
            contentFontSize: 19,
          ),
      ],
      strings: strings,
    );
    if (mounted) _clearSelection();
  }

  void _updateExcerptSelection(TafsirEntry entry, TextSelection selection) {
    final excerpt = selection.textInside(entry.text).trim();
    setState(() {
      if (excerpt.isEmpty) {
        _selectedExcerptByEntryKey.remove(entry.key);
      } else {
        _selectedExcerptByEntryKey[entry.key] = excerpt;
      }
    });
  }

  Future<void> _shareSelectedExcerpts() async {
    if (_selectedExcerptByEntryKey.isEmpty) return;
    final strings = AppStrings(widget.controller.language);
    final cards = composeTafsirShareCards([
      for (final entry in widget.entries)
        if (_selectedExcerptByEntryKey.containsKey(entry.key))
          TafsirShareSection(
            reference: _referenceFor(entry),
            text: _selectedExcerptByEntryKey[entry.key]!,
          ),
    ]);
    if (cards.isEmpty) return;
    await BrandedQuoteShareSheet.show(
      context,
      cards: [
        for (final card in cards)
          BrandedShareCardData(
            title: strings.tafsirSaadiShareTitle,
            reference: card.reference,
            content: card.content,
            contentFontSize: 19,
          ),
      ],
      strings: strings,
    );
    if (mounted) {
      setState(_selectedExcerptByEntryKey.clear);
    }
  }

  String _referenceFor(TafsirEntry entry) {
    final surah = widget.quranRepository.surah(entry.surah);
    return entry.ayah == entry.endAyah
        ? 'سورة ${surah.name} • الآية ${entry.ayah}'
        : 'سورة ${surah.name} • الآيات ${entry.ayah} – ${entry.endAyah}';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.controller.language);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? _selectedEntryKeys.isEmpty
                    ? strings.selectTafsirToShare
                    : strings.selectedTafsir(_selectedEntryKeys.length)
              : widget.title,
        ),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              tooltip: strings.shareSelectedTafsir,
              onPressed: _selectedEntryKeys.isEmpty
                  ? null
                  : _shareSelectedEntries,
              icon: const Icon(Icons.ios_share_rounded),
            ),
            IconButton(
              tooltip: strings.clearShareSelection,
              onPressed: _clearSelection,
              icon: const Icon(Icons.close_rounded),
            ),
          ] else ...[
            if (widget.entries.isNotEmpty &&
                widget.entries.first.surah == widget.entries.last.surah &&
                widget.entries.first.ayah == 1 &&
                widget.entries.last.endAyah ==
                    widget.quranRepository
                        .surah(widget.entries.first.surah)
                        .verseCount)
              IconButton(
                tooltip: TafsirStrings(widget.controller.language).chooseAyah,
                onPressed: _chooseAyah,
                icon: const Icon(Icons.format_list_numbered_rounded),
              ),
            if (_selectedExcerptByEntryKey.isNotEmpty)
              IconButton(
                tooltip: strings.shareSelectedText,
                onPressed: _shareSelectedExcerpts,
                icon: const Icon(Icons.ios_share_rounded),
              ),
            IconButton(
              tooltip: strings.selectTafsirToShare,
              onPressed: _startSelection,
              icon: const Icon(Icons.checklist_rounded),
            ),
          ],
        ],
      ),
      body: ScrollablePositionedList.separated(
        itemScrollController: _itemScrollController,
        initialScrollIndex: _initialIndex,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        itemCount: widget.entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = widget.entries[index];
          final isSelected = _selectedEntryKeys.contains(entry.key);
          final colors = Theme.of(context).colorScheme;
          return Card(
            color: isSelected
                ? colors.secondaryContainer.withValues(alpha: 0.5)
                : null,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _selectionMode ? () => _toggleSelection(entry.key) : null,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_selectionMode) ...[
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isSelected
                                ? colors.secondary
                                : colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            _referenceFor(entry),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        if (!_selectionMode)
                          AnimatedBuilder(
                            animation: widget.controller,
                            builder: (context, child) {
                              final isBookmarked = widget.controller
                                  .isTafsirBookmarked(entry.key);
                              return IconButton(
                                tooltip: isBookmarked
                                    ? strings.removeBookmark
                                    : strings.bookmarks,
                                onPressed: () => widget.controller
                                    .toggleTafsirBookmark(entry.key),
                                icon: Icon(
                                  isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: isBookmarked ? colors.primary : null,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _selectionMode
                        ? Text(
                            entry.text,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 22,
                              height: 1.85,
                            ),
                          )
                        : SelectableText(
                            entry.text,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            onSelectionChanged: (selection, _) =>
                                _updateExcerptSelection(entry, selection),
                            style: const TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 22,
                              height: 1.85,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IndexCard extends StatelessWidget {
  const _IndexCard({
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left_rounded),
      ),
    );
  }
}
