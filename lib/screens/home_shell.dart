import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../data/tafsir_repository.dart';
import '../localization/app_strings.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'surah_index_screen.dart';
import 'tafsir_index_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.repository,
    required this.tafsirRepository,
    required this.controller,
    super.key,
  });

  final QuranRepository repository;
  final TafsirRepository tafsirRepository;
  final AppController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  var _quranBrowseSection = QuranBrowseSection.surah;

  void _openQuranBrowse(QuranBrowseSection section) {
    setState(() {
      _quranBrowseSection = section;
      _index = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.controller.language);
    final screens = [
      HomeScreen(
        repository: widget.repository,
        tafsirRepository: widget.tafsirRepository,
        controller: widget.controller,
        onOpenQuranBrowse: _openQuranBrowse,
      ),
      SurahIndexScreen(
        key: ValueKey(_quranBrowseSection),
        repository: widget.repository,
        tafsirRepository: widget.tafsirRepository,
        controller: widget.controller,
        initialSection: _quranBrowseSection,
      ),
      TafsirIndexScreen(
        quranRepository: widget.repository,
        tafsirRepository: widget.tafsirRepository,
        controller: widget.controller,
      ),
      SettingsScreen(
        repository: widget.repository,
        controller: widget.controller,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: _TelegramNavigationBar(
        selectedIndex: _index,
        onSelected: (value) => setState(() => _index = value),
        destinations: [
          _TabDestination(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: strings.home,
          ),
          _TabDestination(
            icon: Icons.menu_book_outlined,
            selectedIcon: Icons.menu_book_rounded,
            label: strings.surahs,
          ),
          _TabDestination(
            icon: Icons.format_quote_outlined,
            selectedIcon: Icons.format_quote_rounded,
            label: strings.tafsir,
          ),
          _TabDestination(
            icon: Icons.tune_outlined,
            selectedIcon: Icons.tune_rounded,
            label: strings.settings,
          ),
        ],
      ),
    );
  }
}

class _TabDestination {
  const _TabDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _TelegramNavigationBar extends StatelessWidget {
  const _TelegramNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<_TabDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: colors.outline.withValues(alpha: 0.65)),
          ),
          child: SizedBox(
            height: 76,
            child: Row(
              children: List.generate(destinations.length, (index) {
                final destination = destinations[index];
                final isSelected = index == selectedIndex;
                final foreground = isSelected
                    ? colors.primary
                    : colors.onSurfaceVariant;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Material(
                      color: isSelected
                          ? colors.primary.withValues(alpha: 0.16)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => onSelected(index),
                        child: Semantics(
                          selected: isSelected,
                          button: true,
                          label: destination.label,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isSelected
                                    ? destination.selectedIcon
                                    : destination.icon,
                                color: foreground,
                                size: 27,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                destination.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: foreground,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
