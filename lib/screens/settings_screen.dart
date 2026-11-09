import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../localization/app_strings.dart';
import '../utils/quran_reader_text.dart';
import '../utils/reader_navigation.dart';
import '../widgets/language_wheel_picker.dart';
import 'about_screen.dart';
import 'reader_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.repository,
    required this.controller,
    super.key,
  });

  final QuranRepository repository;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final strings = AppStrings(controller.language);
          final destination = resolveSavedVerseDestination(
            repository: repository,
            verseKey: controller.lastVerseKey,
          );
          final savedSurah = destination == null
              ? null
              : repository.surah(destination.surahNumber);
          final savedVerse = destination == null
              ? null
              : repository.verse(destination.verseKey);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            children: [
              Text(
                strings.settings,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: strings.languageLabel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      key: const Key('language-picker-tile'),
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.language_rounded),
                      title: Directionality(
                        textDirection: controller.language.isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: Text(
                          controller.language.nativeName,
                          textAlign: controller.language.isRtl
                              ? TextAlign.right
                              : TextAlign.left,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        final selected = await LanguageWheelPicker.show(
                          context,
                          initialLanguage: controller.language,
                          strings: strings,
                        );
                        if (selected != null &&
                            selected != controller.language) {
                          await controller.setLanguage(selected);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: strings.appearance,
                child: SegmentedButton<AppearancePreference>(
                  segments: [
                    ButtonSegment(
                      value: AppearancePreference.system,
                      icon: Icon(Icons.settings_suggest_rounded),
                      label: Text(strings.system),
                    ),
                    ButtonSegment(
                      value: AppearancePreference.light,
                      icon: Icon(Icons.light_mode_rounded),
                      label: Text(strings.light),
                    ),
                    ButtonSegment(
                      value: AppearancePreference.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                      label: Text(strings.dark),
                    ),
                  ],
                  selected: {controller.appearance},
                  onSelectionChanged: (selection) =>
                      controller.setAppearance(selection.first),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: strings.appColors,
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.86,
                  children: [
                    for (final family in QuranThemeFamily.values)
                      _ThemeFamilyTile(
                        family: family,
                        strings: strings,
                        selected: controller.themeFamily == family,
                        onTap: () => controller.setThemeFamily(family),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: strings.quranTextSize,
                child: Column(
                  children: [
                    Text(
                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: controller.quranFontSize,
                        height: 1.8,
                      ),
                    ),
                    Slider(
                      value: controller.quranFontSize,
                      min: AppController.minFontSize,
                      max: AppController.maxFontSize,
                      divisions: 8,
                      label: '${controller.quranFontSize.round()}',
                      onChanged: controller.setFontSize,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      enabled: destination != null,
                      leading: const Icon(Icons.history_rounded),
                      title: Text(strings.lastReading),
                      subtitle: Text(
                        destination == null ||
                                savedSurah == null ||
                                savedVerse == null
                            ? strings.noSavedReading
                            : strings.language == AppLanguage.arabic
                            ? 'سورة ${savedSurah.name} • الآية ${toArabicIndic(savedVerse.number)}'
                            : '${strings.numberedSurah(savedSurah.number, savedSurah.transliteration)} • ${savedVerse.number}',
                      ),
                      trailing: destination == null
                          ? null
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: strings.clearReading,
                                  onPressed: controller.clearReadingProgress,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                                const Icon(Icons.chevron_left_rounded),
                              ],
                            ),
                      onTap: destination == null
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReaderScreen.surah(
                                  repository: repository,
                                  controller: controller,
                                  surahNumber: destination.surahNumber,
                                  initialVerseKey: destination.verseKey,
                                ),
                              ),
                            ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(strings.about),
                      trailing: const Icon(Icons.chevron_left_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AboutScreen(
                            repository: repository,
                            controller: controller,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeFamilyTile extends StatelessWidget {
  const _ThemeFamilyTile({
    required this.family,
    required this.strings,
    required this.selected,
    required this.onTap,
  });

  final QuranThemeFamily family;
  final AppStrings strings;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.palette(family);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: strings.themeName(family.index),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected
                ? colors.primary.withValues(alpha: 0.1)
                : colors.surfaceContainerHighest.withValues(alpha: 0.45),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PaletteDot(color: palette.lightPrimary),
                        const SizedBox(width: 4),
                        _PaletteDot(color: palette.lightSecondary),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      strings.themeName(family.index),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletteDot extends StatelessWidget {
  const _PaletteDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
