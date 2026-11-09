import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../models/quran_models.dart';
import '../models/tafsir_reading_scope.dart';
import 'themed_selection_wheel.dart';

class ScopedAyahWheelPicker {
  const ScopedAyahWheelPicker._();

  static Future<QuranVerse?> show(
    BuildContext context, {
    required List<QuranVerse> verses,
    required AppStrings strings,
    QuranVerse? initialVerse,
    String? title,
  }) {
    if (verses.isEmpty) return Future<QuranVerse?>.value();
    return showModalBottomSheet<QuranVerse>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ScopedAyahWheelSheet(
        verses: verses,
        strings: strings,
        initialVerse: initialVerse,
        title: title,
      ),
    );
  }

  static List<QuranVerse> versesInScope({
    required Iterable<QuranSurah> surahs,
    required TafsirReadingScope scope,
  }) => [
    for (final surah in surahs)
      for (final verse in surah.verses)
        if (scope.contains(verse)) verse,
  ];
}

class _ScopedAyahWheelSheet extends StatefulWidget {
  const _ScopedAyahWheelSheet({
    required this.verses,
    required this.strings,
    this.initialVerse,
    this.title,
  });

  final List<QuranVerse> verses;
  final AppStrings strings;
  final QuranVerse? initialVerse;
  final String? title;

  @override
  State<_ScopedAyahWheelSheet> createState() => _ScopedAyahWheelSheetState();
}

class _ScopedAyahWheelSheetState extends State<_ScopedAyahWheelSheet> {
  late final FixedExtentScrollController _controller;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialVerse == null
        ? -1
        : widget.verses.indexWhere(
            (verse) => verse.key == widget.initialVerse!.key,
          );
    _selectedIndex = initial < 0 ? 0 : initial;
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _wheel(double height) => SizedBox(
    key: const Key('scoped-ayah-wheel'),
    height: height,
    child: ThemedSelectionWheel(
      controller: _controller,
      itemCount: widget.verses.length,
      height: height,
      onSelectedItemChanged: (index) => setState(() => _selectedIndex = index),
      itemBuilder: (context, index) {
        final verse = widget.verses[index];
        return Center(
          child: Text(
            '${verse.surahNumber}:${verse.number}',
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 500 && size.width > size.height;
    final height = (size.height * 0.27).clamp(156.0, 224.0);
    final selected = widget.verses[_selectedIndex];
    final preview = _AyahPreview(
      key: const Key('scoped-ayah-preview'),
      verse: selected,
      ayahNumber: selected.number,
      surahName: '${selected.surahNumber}:${selected.number}',
      compact: compact,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Text(
                      widget.title ?? widget.strings.searchAyah,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    if (compact)
                      Row(
                        children: [
                          Expanded(child: preview),
                          const SizedBox(width: 16),
                          Expanded(child: _wheel(height)),
                        ],
                      )
                    else ...[
                      preview,
                      const SizedBox(height: 14),
                      _wheel(height),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(widget.strings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context)
                            .pop(widget.verses[_selectedIndex]),
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
    );
  }
}

class _AyahPreview extends StatelessWidget {
  const _AyahPreview({
    required this.verse,
    required this.ayahNumber,
    required this.surahName,
    this.compact = false,
    super.key,
  });

  final QuranVerse verse;
  final int ayahNumber;
  final String surahName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$surahName • ﴿$ayahNumber﴾',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: compact ? 96 : 112,
              child: Center(
                child: Text(
                  verse.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: compact ? 19 : 21,
                    height: compact ? 1.5 : 1.65,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
