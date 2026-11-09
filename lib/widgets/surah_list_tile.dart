import 'package:flutter/material.dart';

import '../models/quran_models.dart';
import '../localization/app_strings.dart';

class SurahListTile extends StatelessWidget {
  const SurahListTile({
    required this.surah,
    required this.strings,
    required this.onTap,
    super.key,
  });

  final QuranSurah surah;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${surah.number}',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.language == AppLanguage.arabic
                          ? 'سورة ${surah.name}'
                          : strings.numberedSurah(
                              surah.number,
                              surah.transliteration,
                            ),
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.language == AppLanguage.arabic
                          ? '${surah.revelationType} • ${surah.verseCount} آية • الجزء ${surah.firstJuz}'
                          : '${surah.name} • ${surah.verseCount} ${strings.verses} • ${strings.numberedJuz(surah.firstJuz)}',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(
                strings.language.isRtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
