import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../localization/app_strings.dart';
import 'reader_screen.dart';

class JuzIndexScreen extends StatelessWidget {
  const JuzIndexScreen({
    required this.repository,
    required this.controller,
    super.key,
  });

  final QuranRepository repository;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(controller.language);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.juzIndex,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  strings.juzDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              itemCount: repository.data.juzs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final juz = repository.data.juzs[index];
                final firstSurah = repository.surah(juz.startSurah);
                final lastSurah = repository.surah(juz.endSurah);
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReaderScreen.juz(
                          repository: repository,
                          controller: controller,
                          juzNumber: juz.number,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.12),
                            child: Text(
                              '${juz.number}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.numberedJuz(juz.number),
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  strings.language == AppLanguage.arabic
                                      ? 'من ${firstSurah.name} ${juz.startAyah} إلى ${lastSurah.name} ${juz.endAyah}'
                                      : '${strings.from} ${firstSurah.transliteration} ${juz.startAyah} ${strings.to} ${lastSurah.transliteration} ${juz.endAyah}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            strings.language.isRtl
                                ? Icons.chevron_left_rounded
                                : Icons.chevron_right_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
