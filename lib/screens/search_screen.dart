import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../localization/app_strings.dart';
import '../models/quran_models.dart';
import 'reader_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    required this.repository,
    required this.controller,
    super.key,
  });

  final QuranRepository repository;
  final AppController controller;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _textController = TextEditingController();
  List<QuranSearchResult> _results = const [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _search(String value) {
    setState(() => _results = widget.repository.search(value));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.controller.language);
    return Scaffold(
      appBar: AppBar(title: Text(strings.searchTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: TextField(
              controller: _textController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: strings.searchSurah,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _textController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _textController.clear();
                          _search('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _textController.text.trim().length < 2
                            ? strings.searchHelp
                            : strings.noResults,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            result.verse == null
                                ? strings.numberedSurah(
                                    result.surah.number,
                                    result.surah.transliteration,
                                  )
                                : strings.language == AppLanguage.arabic
                                ? '${result.surah.name} • الآية ${result.verse!.number}'
                                : '${strings.numberedSurah(result.surah.number, result.surah.transliteration)} • ${result.verse!.number}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: result.verse == null
                              ? Text(
                                  '${result.surah.verseCount} ${strings.verses}',
                                )
                              : Text(
                                  result.verse!.text,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    height: 1.7,
                                  ),
                                ),
                          leading: Icon(
                            result.verse == null
                                ? Icons.menu_book_rounded
                                : Icons.search_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          trailing: Icon(
                            strings.language.isRtl
                                ? Icons.chevron_left_rounded
                                : Icons.chevron_right_rounded,
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReaderScreen.surah(
                                repository: widget.repository,
                                controller: widget.controller,
                                surahNumber: result.surah.number,
                                initialVerseKey: result.key,
                              ),
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
