import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../localization/app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({
    required this.repository,
    required this.controller,
    super.key,
  });

  final QuranRepository repository;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final metadata = repository.data.metadata;
    final strings = AppStrings(controller.language);
    return Scaffold(
      appBar: AppBar(title: Text(strings.about)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metadata.title,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text('${metadata.sourceEdition} • ${metadata.riwayah}'),
                  const SizedBox(height: 14),
                  Text(
                    '${metadata.surahCount} ${strings.surahs} • ${metadata.verseCount} ${strings.verses} • ${metadata.juzCount} ${strings.juzs} • ${metadata.pageCount}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.source,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(metadata.textSource),
                  Text(metadata.textLicense),
                  const SizedBox(height: 12),
                  SelectableText(
                    '${strings.quranArabicNotice}\n\n${metadata.textSource}\nhttps://tanzil.net/',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(strings.languageDescription),
            ),
          ),
        ],
      ),
    );
  }
}
