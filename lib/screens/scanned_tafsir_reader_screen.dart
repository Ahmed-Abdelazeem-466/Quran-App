import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../data/scanned_tafsir_repository.dart';
import '../localization/app_strings.dart';
import '../localization/tafsir_strings.dart';
import '../models/quran_models.dart';
import '../models/tafsir_reading_scope.dart';
import '../models/tafsir_work.dart';
import '../services/tafsir_pdf_service.dart';
import '../widgets/ayah_wheel_picker.dart';
import '../widgets/scoped_ayah_wheel_picker.dart';
import '../widgets/themed_selection_wheel.dart';

class ScannedTafsirReaderScreen extends StatefulWidget {
  const ScannedTafsirReaderScreen({
    required this.work,
    required this.repository,
    required this.scanRepository,
    required this.controller,
    required this.selectedVerse,
    required this.initialPage,
    this.scope,
    super.key,
  });
  final TafsirWork work;
  final QuranRepository repository;
  final ScannedTafsirRepository scanRepository;
  final AppController controller;
  final QuranVerse selectedVerse;
  final int initialPage;

  /// Optional exact range for Juz/Rub/Surah entry points. Old PDF bookmarks
  /// intentionally omit it and retain the historic whole-book navigation.
  final TafsirReadingScope? scope;

  @override
  State<ScannedTafsirReaderScreen> createState() =>
      _ScannedTafsirReaderScreenState();
}

class _ScannedTafsirReaderScreenState extends State<ScannedTafsirReaderScreen> {
  late int _page;
  late QuranVerse _selectedVerse;
  late final int _firstPage;
  late final int _lastPage;
  TafsirPdfPage? _image;
  bool _loading = true;
  bool _failed = false;
  int _request = 0;
  final _zoom = TransformationController();

  @override
  void initState() {
    super.initState();
    final scope = widget.scope;
    if (scope == null) {
      _firstPage = 1;
      _lastPage = widget.work.pageCount;
    } else {
      final start = widget.scanRepository.pageForVerse(
        widget.work,
        widget.repository.verse(scope.startVerseKey)!,
      );
      final end = widget.scanRepository.pageForVerse(
        widget.work,
        widget.repository.verse(scope.endVerseKey)!,
      );
      if (widget.work == TafsirWork.ibnKathir) {
        _firstPage =
            widget.scanRepository.ibnKathirSurahPages[widget.repository
                .verse(scope.startVerseKey)!
                .surahNumber]!;
        // Until exact ayah anchors exist, retain the whole final Surah interval.
        // Its first-page bookmark must never collapse the reader to one page.
        final endSurah = widget.repository
            .verse(scope.endVerseKey)!
            .surahNumber;
        final subsequent =
            widget.scanRepository.ibnKathirSurahPages.entries
                .where((entry) => entry.key > endSurah && entry.value > end)
                .map((entry) => entry.value)
                .toList()
              ..sort();
        _lastPage = subsequent.isEmpty
            ? widget.work.pageCount
            : subsequent.first;
      } else {
        _firstPage = start < end ? start : end;
        _lastPage = start < end ? end : start;
      }
    }
    _page = widget.initialPage.clamp(_firstPage, _lastPage);
    _selectedVerse = widget.scope?.contains(widget.selectedVerse) == false
        ? widget.repository.verse(widget.scope!.startVerseKey)!
        : widget.selectedVerse;
    _render();
  }

  @override
  void dispose() {
    _request++;
    _zoom.dispose();
    unawaited(TafsirPdfService.release().catchError((Object _) {}));
    super.dispose();
  }

  Future<void> _render() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _failed = false;
      _image = null;
    });
    _zoom.value = Matrix4.identity();
    try {
      final image = await TafsirPdfService.render(widget.work, _page);
      if (!mounted || request != _request) return;
      setState(() {
        _image = image;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _goToPage(int page) {
    final next = page.clamp(_firstPage, _lastPage);
    if (next == _page && !_failed) return;
    setState(() => _page = next);
    _render();
  }

  Future<void> _chooseAyah() async {
    final strings = AppStrings(widget.controller.language);
    final verse = widget.scope == null
        ? await _chooseUnscopedAyah(strings)
        : await ScopedAyahWheelPicker.show(
            context,
            verses: ScopedAyahWheelPicker.versesInScope(
              surahs: widget.repository.data.surahs,
              scope: widget.scope!,
            ),
            strings: strings,
            initialVerse: _selectedVerse,
            title: TafsirStrings(widget.controller.language).chooseAyah,
          );
    if (!mounted || verse == null) return;
    setState(() => _selectedVerse = verse);
    _goToPage(widget.scanRepository.pageForVerse(widget.work, verse));
  }

  Future<QuranVerse?> _chooseUnscopedAyah(AppStrings strings) async {
    final surah = widget.repository.surah(_selectedVerse.surahNumber);
    final ayah = await AyahWheelPicker.show(
      context,
      surah: surah,
      strings: strings,
      initialAyah: _selectedVerse.number,
    );
    if (!mounted || ayah == null) return null;
    return surah.verses[ayah - 1];
  }

  Future<void> _choosePage() async {
    final page = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PagePicker(
        initialPage: _page,
        firstPage: _firstPage,
        lastPage: _lastPage,
        strings: AppStrings(widget.controller.language),
      ),
    );
    if (mounted && page != null) _goToPage(page);
  }

  ScannedTafsirBookmark get _bookmark => ScannedTafsirBookmark(
    work: widget.work,
    page: _page,
    surah: _selectedVerse.surahNumber,
    ayah: _selectedVerse.number,
  );

  void _showScanNotice() {
    final labels = TafsirStrings(widget.controller.language);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.work.title, textDirection: TextDirection.rtl),
        content: Text(labels.ibnKathirNotice),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.controller.language);
    final labels = TafsirStrings(widget.controller.language);
    final colors = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).height < 500;
    final androidSupported =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.work.title,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (widget.work == TafsirWork.ibnKathir)
            IconButton(
              tooltip: labels.originalScan,
              onPressed: _showScanNotice,
              icon: const Icon(Icons.info_outline_rounded),
            ),
          IconButton(
            tooltip: labels.chooseAyah,
            onPressed: _chooseAyah,
            icon: const Icon(Icons.format_list_numbered_rounded),
          ),
          AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              final saved = widget.controller.isTafsirBookmarked(_bookmark.key);
              return IconButton(
                tooltip: saved ? strings.removeBookmark : strings.bookmarks,
                onPressed: _loading
                    ? null
                    : () =>
                          widget.controller.toggleTafsirBookmark(_bookmark.key),
                icon: Icon(
                  saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                color: saved ? colors.primary : null,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${labels.selectedAyah} • ${widget.repository.surah(_selectedVerse.surahNumber).name} ${_selectedVerse.number}',
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.menu_book_rounded, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedVerse.text,
                      key: const ValueKey('scan-ayah-reference'),
                      maxLines: compact ? 1 : 3,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: compact ? 18 : 20,
                        height: 1.5,
                      ),
                    ),
                    if (widget.work == TafsirWork.ibnKathir &&
                        !compact &&
                        widget.scanRepository.verifiedIbnKathirPage(
                              _selectedVerse,
                            ) ==
                            null) ...[
                      const SizedBox(height: 6),
                      Text(
                        labels.ibnKathirNotice,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _failed
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            androidSupported
                                ? labels.loadFailed
                                : labels.androidOnly,
                            textAlign: TextAlign.center,
                          ),
                          if (androidSupported) ...[
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _render,
                              child: Text(labels.retry),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : InteractiveViewer(
                    transformationController: _zoom,
                    minScale: 1,
                    maxScale: 5,
                    child: Center(
                      child: Image.memory(
                        _image!.bytes,
                        key: ValueKey('${widget.work.id}:$_page'),
                        fit: BoxFit.contain,
                        gaplessPlayback: false,
                        semanticLabel:
                            '${widget.work.title} • ${labels.page} $_page',
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: strings.previous,
                onPressed: _page > _firstPage && !_loading
                    ? () => _goToPage(_page - 1)
                    : null,
                icon: const Icon(Icons.navigate_before_rounded),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: _loading ? null : _choosePage,
                  icon: const Icon(Icons.unfold_more_rounded, size: 18),
                  label: Text(
                    '${labels.page} $_page / ${widget.work.pageCount}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                tooltip: strings.next,
                onPressed: _page < _lastPage && !_loading
                    ? () => _goToPage(_page + 1)
                    : null,
                icon: const Icon(Icons.navigate_next_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PagePicker extends StatefulWidget {
  const _PagePicker({
    required this.initialPage,
    required this.firstPage,
    required this.lastPage,
    required this.strings,
  });
  final int initialPage;
  final int firstPage;
  final int lastPage;
  final AppStrings strings;
  @override
  State<_PagePicker> createState() => _PagePickerState();
}

class _PagePickerState extends State<_PagePicker> {
  late final FixedExtentScrollController _wheel;
  late int _selected;
  @override
  void initState() {
    super.initState();
    _selected = widget.initialPage.clamp(widget.firstPage, widget.lastPage);
    _wheel = FixedExtentScrollController(
      initialItem: _selected - widget.firstPage,
    );
  }

  @override
  void dispose() {
    _wheel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              TafsirStrings(widget.strings.language).choosePage,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ThemedSelectionWheel(
              controller: _wheel,
              itemCount: widget.lastPage - widget.firstPage + 1,
              itemBuilder: (_, index) => Center(
                child: Text(
                  '${widget.firstPage + index}',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              onSelectedItemChanged: (index) =>
                  _selected = widget.firstPage + index,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(widget.strings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    child: Text(
                      MaterialLocalizations.of(context).okButtonLabel,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
