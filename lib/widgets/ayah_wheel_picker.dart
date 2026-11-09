import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../models/quran_models.dart';
import 'themed_selection_wheel.dart';

class AyahWheelPicker {
  const AyahWheelPicker._();

  static Future<int?> show(
    BuildContext context, {
    required QuranSurah surah,
    required AppStrings strings,
    int initialAyah = 1,
    String? title,
  }) => showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _AyahWheelSheet(
      surah: surah,
      strings: strings,
      initialAyah: initialAyah,
      title: title,
    ),
  );
}

class _AyahWheelSheet extends StatefulWidget {
  const _AyahWheelSheet({
    required this.surah,
    required this.strings,
    required this.initialAyah,
    this.title,
  });
  final QuranSurah surah;
  final AppStrings strings;
  final int initialAyah;
  final String? title;

  @override
  State<_AyahWheelSheet> createState() => _AyahWheelSheetState();
}

class _AyahWheelSheetState extends State<_AyahWheelSheet> {
  late final FixedExtentScrollController _controller;
  late int _selectedAyah;

  @override
  void initState() {
    super.initState();
    _selectedAyah = widget.initialAyah.clamp(1, widget.surah.verseCount);
    _controller = FixedExtentScrollController(initialItem: _selectedAyah - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _wheel(double height) => SizedBox(
    key: const Key('ayah-wheel'),
    height: height,
    child: ThemedSelectionWheel(
      controller: _controller,
      itemCount: widget.surah.verseCount,
      height: height,
      onSelectedItemChanged: (index) =>
          setState(() => _selectedAyah = index + 1),
      itemBuilder: (context, index) => Center(
        child: Text(
          '${index + 1}',
          textDirection: TextDirection.ltr,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 500 && size.width > size.height;
    final height = (size.height * 0.27).clamp(156.0, 224.0);
    final preview = _AyahPreview(
      key: const Key('ayah-preview'),
      verse: widget.surah.verses[_selectedAyah - 1],
      ayahNumber: _selectedAyah,
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
                      widget.title ??
                          '${widget.strings.surah} ${widget.surah.name}',
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
                    onPressed: () => Navigator.of(context).pop(_selectedAyah),
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
    this.compact = false,
    super.key,
  });
  final QuranVerse verse;
  final int ayahNumber;
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
              '﴿$ayahNumber﴾',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            // Fixed height keeps the wheel stationary when long and short ayahs alternate.
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
