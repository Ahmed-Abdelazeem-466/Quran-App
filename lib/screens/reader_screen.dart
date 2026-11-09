import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../localization/app_strings.dart';
import '../models/quran_models.dart';
import '../models/reader_section.dart';
import '../sharing/branded_quote_share.dart';
import '../sharing/quran_share_composer.dart';
import '../utils/quran_reader_text.dart';
import '../utils/reader_navigation.dart';

enum ReaderMode { surah, juz, rub }

enum _ReaderOption { zoomIn, zoomOut, share, fullScreen }

class ReaderScreen extends StatefulWidget {
  const ReaderScreen.surah({
    required this.repository,
    required this.controller,
    required int surahNumber,
    this.initialVerseKey,
    super.key,
  }) : mode = ReaderMode.surah,
       number = surahNumber,
       rangeStartKey = null,
       rangeEndKey = null;

  const ReaderScreen.juz({
    required this.repository,
    required this.controller,
    required int juzNumber,
    this.initialVerseKey,
    super.key,
  }) : mode = ReaderMode.juz,
       number = juzNumber,
       rangeStartKey = null,
       rangeEndKey = null;

  const ReaderScreen.rub({
    required this.repository,
    required this.controller,
    required int rubNumber,
    required String startVerseKey,
    required String endVerseKey,
    super.key,
  }) : mode = ReaderMode.rub,
       number = rubNumber,
       initialVerseKey = startVerseKey,
       rangeStartKey = startVerseKey,
       rangeEndKey = endVerseKey;

  final QuranRepository repository;
  final AppController controller;
  final ReaderMode mode;
  final int number;
  final String? initialVerseKey;
  final String? rangeStartKey;
  final String? rangeEndKey;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _scrollController = ScrollController();
  late final List<QuranVerse> _verses;
  late final List<ReaderSection> _sections;
  late final Map<String, GlobalKey> _verseKeys;
  ReaderDisplayMode _displayMode = ReaderDisplayMode.standard;
  final Set<String> _selectedVerseKeys = <String>{};
  var _selectionMode = false;
  var _hasRestoredInitialVerse = false;

  bool get _isFullScreen => _displayMode == ReaderDisplayMode.fullScreen;
  bool get _isSelectingVerses => _selectionMode;

  @override
  void initState() {
    super.initState();
    _verses = switch (widget.mode) {
      ReaderMode.surah => widget.repository.surah(widget.number).verses,
      ReaderMode.juz => widget.repository.versesForJuz(widget.number),
      ReaderMode.rub => widget.repository.versesForRange(
        startKey: widget.rangeStartKey!,
        endKey: widget.rangeEndKey!,
      ),
    };
    _sections = buildReaderSections(_verses);
    _verseKeys = {for (final verse in _verses) verse.key: GlobalKey()};
    _scrollController.addListener(_trackReadingPosition);
    if (widget.initialVerseKey != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _restoreInitialVerse(),
      );
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scrollController
      ..removeListener(_trackReadingPosition)
      ..dispose();
    super.dispose();
  }

  void _restoreInitialVerse() {
    if (!mounted ||
        _hasRestoredInitialVerse ||
        widget.initialVerseKey == null) {
      return;
    }
    _hasRestoredInitialVerse = true;
    _scrollToVerse(widget.initialVerseKey!, duration: Duration.zero);
  }

  void _trackReadingPosition() {
    QuranVerse? firstVisible;
    var nearestTop = double.infinity;
    for (final verse in _verses) {
      final box = _verseKeys[verse.key]?.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy >= 0 && dy < nearestTop) {
        nearestTop = dy;
        firstVisible = verse;
      }
    }
    if (firstVisible != null) {
      widget.controller.updateReadingPosition(firstVisible.key);
    }
  }

  void _scrollToVerse(
    String verseKey, {
    Duration duration = const Duration(milliseconds: 220),
  }) {
    final target = _verseKeys[verseKey]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: duration,
      alignment: 0.18,
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleFullScreen() {
    final next = _displayMode.toggled;
    setState(() => _displayMode = next);
    SystemChrome.setEnabledSystemUIMode(
      next == ReaderDisplayMode.fullScreen
          ? SystemUiMode.immersiveSticky
          : SystemUiMode.edgeToEdge,
    );
  }

  String _title(AppStrings strings) {
    if (widget.mode == ReaderMode.rub) {
      return '${strings.rub} ${widget.number}';
    }
    if (widget.mode == ReaderMode.juz) {
      return strings.numberedJuz(widget.number);
    }
    final surah = widget.repository.surah(widget.number);
    return strings.language == AppLanguage.arabic
        ? 'سورة ${surah.name}'
        : strings.numberedSurah(widget.number, surah.transliteration);
  }

  void _openAdjacent(int offset) {
    if (widget.mode == ReaderMode.rub) return;
    final max = widget.mode == ReaderMode.surah ? 114 : 30;
    final target = widget.number + offset;
    if (target < 1 || target > max) return;
    final next = widget.mode == ReaderMode.surah
        ? ReaderScreen.surah(
            repository: widget.repository,
            controller: widget.controller,
            surahNumber: target,
          )
        : ReaderScreen.juz(
            repository: widget.repository,
            controller: widget.controller,
            juzNumber: target,
          );
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  void _startVerseSelection() => setState(() {
    _selectionMode = true;
    _selectedVerseKeys.clear();
  });

  void _toggleVerseSelection(String verseKey) => setState(() {
    if (!_selectedVerseKeys.add(verseKey)) _selectedVerseKeys.remove(verseKey);
  });

  void _clearVerseSelection() => setState(() {
    _selectionMode = false;
    _selectedVerseKeys.clear();
  });

  String _selectedVerseReference(List<QuranVerse> verses) {
    final grouped = <int, List<QuranVerse>>{};
    for (final verse in verses) {
      (grouped[verse.surahNumber] ??= <QuranVerse>[]).add(verse);
    }
    return grouped.entries
        .map((entry) {
          final surah = widget.repository.surah(entry.key);
          final ayahs = entry.value
              .map((verse) => toArabicIndic(verse.number))
              .join('، ');
          return 'سورة ${surah.name} • الآيات $ayahs';
        })
        .join('\n');
  }

  Future<void> _shareSelectedVerses() async {
    final verses = _verses
        .where((verse) => _selectedVerseKeys.contains(verse.key))
        .toList(growable: false);
    if (verses.isEmpty) return;
    final strings = AppStrings(widget.controller.language);
    final groups = composeQuranShareCardGroups(verses);
    await BrandedQuoteShareSheet.show(
      context,
      cards: [
        for (final group in groups)
          BrandedShareCardData(
            title: strings.quranVersesShareTitle,
            reference: _selectedVerseReference(group.verses),
            content: group.composition.content,
            contentFontSize: (widget.controller.quranFontSize * 0.72).clamp(
              20,
              28,
            ),
            standaloneBasmala: group.composition.standaloneBasmala,
          ),
      ],
      strings: strings,
    );
    if (mounted) _clearVerseSelection();
  }

  void _handleReaderOption(_ReaderOption option) {
    switch (option) {
      case _ReaderOption.zoomIn:
        widget.controller.setFontSize(widget.controller.quranFontSize + 2);
      case _ReaderOption.zoomOut:
        widget.controller.setFontSize(widget.controller.quranFontSize - 2);
      case _ReaderOption.share:
        _startVerseSelection();
      case _ReaderOption.fullScreen:
        _toggleFullScreen();
    }
  }

  PopupMenuItem<_ReaderOption> _readerOptionItem({
    required _ReaderOption value,
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem<_ReaderOption>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 21),
          const SizedBox(width: 14),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings(widget.controller.language);
    final readerBody = _buildReaderBody(colors);
    return PopScope(
      canPop: !_isFullScreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && shouldExitFullscreenOnBack(_displayMode)) {
          _toggleFullScreen();
        }
      },
      child: _isFullScreen
          ? Scaffold(body: readerBody)
          : Scaffold(
              appBar: AppBar(
                title: Text(
                  _isSelectingVerses
                      ? _selectedVerseKeys.isEmpty
                            ? strings.selectAyahsToShare
                            : strings.selectedAyahs(_selectedVerseKeys.length)
                      : _title(strings),
                ),
                actions: [
                  if (_isSelectingVerses) ...[
                    IconButton(
                      tooltip: strings.shareSelectedAyahs,
                      onPressed: _selectedVerseKeys.isEmpty
                          ? null
                          : _shareSelectedVerses,
                      icon: const Icon(Icons.ios_share_rounded),
                    ),
                    IconButton(
                      tooltip: strings.clearShareSelection,
                      onPressed: _clearVerseSelection,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ] else ...[
                    PopupMenuButton<_ReaderOption>(
                      tooltip: strings.readerOptions,
                      icon: const Icon(Icons.more_vert_rounded),
                      onSelected: _handleReaderOption,
                      itemBuilder: (context) => [
                        _readerOptionItem(
                          value: _ReaderOption.zoomIn,
                          icon: Icons.text_increase_rounded,
                          label: strings.increaseText,
                        ),
                        _readerOptionItem(
                          value: _ReaderOption.zoomOut,
                          icon: Icons.text_decrease_rounded,
                          label: strings.decreaseText,
                        ),
                        _readerOptionItem(
                          value: _ReaderOption.share,
                          icon: Icons.ios_share_rounded,
                          label: strings.share,
                        ),
                        _readerOptionItem(
                          value: _ReaderOption.fullScreen,
                          icon: Icons.fullscreen_rounded,
                          label: strings.fullScreen,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(width: 6),
                ],
              ),
              body: readerBody,
              bottomNavigationBar: widget.mode == ReaderMode.rub
                  ? null
                  : SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.number > 1
                                    ? () => _openAdjacent(-1)
                                    : null,
                                icon: const Icon(Icons.chevron_right_rounded),
                                label: Text(
                                  '${strings.previous} ${widget.mode == ReaderMode.surah ? strings.surah : strings.juz}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed:
                                    widget.number <
                                        (widget.mode == ReaderMode.surah
                                            ? 114
                                            : 30)
                                    ? () => _openAdjacent(1)
                                    : null,
                                icon: const Icon(Icons.chevron_left_rounded),
                                label: Text(
                                  '${strings.next} ${widget.mode == ReaderMode.surah ? strings.surah : strings.juz}',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
    );
  }

  Widget _buildReaderBody(ColorScheme colors) {
    return Column(
      children: [
        if (!_isFullScreen)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                widget.mode == ReaderMode.surah
                    ? '${widget.repository.surah(widget.number).revelationType} • ${toArabicIndic(_verses.length)} آية • من الصفحة ${toArabicIndic(_verses.first.page)}'
                    : widget.mode == ReaderMode.juz
                    ? '${toArabicIndic(_verses.length)} آية • من ${widget.repository.surahForVerse(_verses.first).name} إلى ${widget.repository.surahForVerse(_verses.last).name}'
                    : '${toArabicIndic(_verses.length)} آية • من ${widget.repository.surahForVerse(_verses.first).name} ${toArabicIndic(_verses.first.number)} إلى ${widget.repository.surahForVerse(_verses.last).name} ${toArabicIndic(_verses.last.number)}',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        Expanded(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) => SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(20, _isFullScreen ? 18 : 4, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < _sections.length; index++)
                    _buildSurahFlow(index),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurahFlow(int index) {
    final section = _sections[index];
    final firstVerse = section.verses.first;
    final hasBasmala = usesStandaloneBasmala(
      surahNumber: section.surahNumber,
      firstVerseText: firstVerse.text,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SurahIntroduction(
          name: widget.repository.surah(section.surahNumber).name,
          showName: widget.mode != ReaderMode.surah || index > 0,
          showBasmala: hasBasmala,
        ),
        _ContinuousQuranText(
          section: section,
          controller: widget.controller,
          selectedVerseKeys: _selectedVerseKeys,
          selectionMode: _isSelectingVerses,
          onToggleSelection: _toggleVerseSelection,
          removeBasmalaFromFirstVerse: hasBasmala,
          verseKeys: _verseKeys,
        ),
      ],
    );
  }
}

class _SurahIntroduction extends StatelessWidget {
  const _SurahIntroduction({
    required this.name,
    required this.showName,
    required this.showBasmala,
  });

  final String name;
  final bool showName;
  final bool showBasmala;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        top: showName ? 24 : 6,
        bottom: showBasmala ? 10 : 4,
      ),
      child: Column(
        children: [
          if (showName) ...[
            Text(
              'سورة $name',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Divider(
              color: colors.secondary.withValues(alpha: 0.6),
              indent: 24,
              endIndent: 24,
            ),
          ],
          if (showBasmala) ...[
            SizedBox(height: showName ? 10 : 4),
            Text(
              standaloneBasmala,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 28,
                height: 1.65,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _ContinuousQuranText extends StatefulWidget {
  const _ContinuousQuranText({
    required this.section,
    required this.controller,
    required this.selectedVerseKeys,
    required this.selectionMode,
    required this.onToggleSelection,
    required this.removeBasmalaFromFirstVerse,
    required this.verseKeys,
  });

  final ReaderSection section;
  final AppController controller;
  final Set<String> selectedVerseKeys;
  final bool selectionMode;
  final ValueChanged<String> onToggleSelection;
  final bool removeBasmalaFromFirstVerse;
  final Map<String, GlobalKey> verseKeys;

  @override
  State<_ContinuousQuranText> createState() => _ContinuousQuranTextState();
}

class _ContinuousQuranTextState extends State<_ContinuousQuranText> {
  late final List<TapGestureRecognizer> _markerRecognizers;

  @override
  void initState() {
    super.initState();
    _markerRecognizers = [
      for (final verse in widget.section.verses)
        TapGestureRecognizer()
          ..onTap = () {
            if (widget.selectionMode) {
              widget.onToggleSelection(verse.key);
            } else {
              widget.controller.updateReadingPosition(verse.key);
              widget.controller.toggleBookmark(verse.key);
            }
          },
    ];
  }

  @override
  void dispose() {
    for (final recognizer in _markerRecognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings(widget.controller.language);
    final lineHeight = 1.88 - (widget.controller.quranFontSize * 0.006);
    final baseStyle = TextStyle(
      fontFamily: 'NotoNaskhArabic',
      fontSize: widget.controller.quranFontSize,
      height: lineHeight,
      fontWeight: FontWeight.w500,
      color: colors.onSurface,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            for (var index = 0; index < widget.section.verses.length; index++)
              _VerseFlowSpan(
                verse: widget.section.verses[index],
                strings: strings,
                baseStyle: baseStyle,
                markerColor: colors.primary,
                highlightColor: colors.tertiary,
                bookmarkForegroundColor: colors.onTertiary,
                selectionColor: colors.secondary,
                isBookmarked: widget.controller.isBookmarked(
                  widget.section.verses[index].key,
                ),
                isSelected: widget.selectedVerseKeys.contains(
                  widget.section.verses[index].key,
                ),
                text: widget.removeBasmalaFromFirstVerse && index == 0
                    ? withoutStandaloneBasmala(
                        widget.section.verses[index].text,
                      )
                    : widget.section.verses[index].text,
                markerRecognizer: _markerRecognizers[index],
                verseKey: widget.verseKeys[widget.section.verses[index].key],
              ).build(),
          ],
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        textWidthBasis: TextWidthBasis.parent,
        strutStyle: StrutStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: widget.controller.quranFontSize,
          height: lineHeight,
          forceStrutHeight: true,
        ),
        softWrap: true,
      ),
    );
  }
}

class _VerseFlowSpan {
  const _VerseFlowSpan({
    required this.verse,
    required this.strings,
    required this.baseStyle,
    required this.markerColor,
    required this.highlightColor,
    required this.bookmarkForegroundColor,
    required this.selectionColor,
    required this.isBookmarked,
    required this.isSelected,
    required this.text,
    required this.markerRecognizer,
    required this.verseKey,
  });

  final QuranVerse verse;
  final AppStrings strings;
  final TextStyle baseStyle;
  final Color markerColor;
  final Color highlightColor;
  final Color bookmarkForegroundColor;
  final Color selectionColor;
  final bool isBookmarked;
  final bool isSelected;
  final String text;
  final TapGestureRecognizer markerRecognizer;
  final GlobalKey? verseKey;

  InlineSpan build() {
    final markerBackgroundColor = isBookmarked ? highlightColor : null;
    final markerForegroundColor = isSelected
        ? selectionColor
        : isBookmarked
        ? bookmarkForegroundColor
        : markerColor;
    return TextSpan(
      children: [
        WidgetSpan(child: SizedBox(key: verseKey, width: 0, height: 0)),
        if (text.isNotEmpty)
          TextSpan(
            text: '$text ',
            style: baseStyle.copyWith(
              backgroundColor: isSelected
                  ? selectionColor.withValues(alpha: 0.15)
                  : null,
            ),
          ),
        TextSpan(
          text: '${inlineVerseMarker(verse.number)} ',
          recognizer: markerRecognizer,
          semanticsLabel: isSelected
              ? '${strings.clearShareSelection} ${toArabicIndic(verse.number)}'
              : '${isBookmarked ? strings.removeBookmark : strings.bookmarks} '
                    '${toArabicIndic(verse.number)}',
          style: baseStyle.copyWith(
            fontSize: 17,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: markerForegroundColor,
            backgroundColor: markerBackgroundColor,
          ),
        ),
      ],
    );
  }
}
