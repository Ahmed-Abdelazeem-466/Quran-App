import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/app_theme.dart';
import '../localization/app_strings.dart';
import '../models/quran_reminder.dart';

enum AppearancePreference {
  system,
  light,
  dark;

  ThemeMode get themeMode => switch (this) {
    AppearancePreference.system => ThemeMode.system,
    AppearancePreference.light => ThemeMode.light,
    AppearancePreference.dark => ThemeMode.dark,
  };
}

class AppController extends ChangeNotifier {
  AppController(this._preferences);

  static const _appearanceKey = 'appearance';
  static const _themeFamilyKey = 'themeFamily';
  static const _languageKey = 'language';
  static const _fontSizeKey = 'quranFontSize';
  static const _lastVerseKey = 'lastVerseKey';
  static const _bookmarksKey = 'bookmarks';
  static const _tafsirBookmarksKey = 'tafsirBookmarks';
  static const _remindersKey = 'quranReminders';
  static const _notificationPermissionPromptSeenKey =
      'notificationPermissionPromptSeen';
  static const minFontSize = 23.0;
  static const maxFontSize = 39.0;
  static const defaultFontSize = 29.0;

  static Future<AppController> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppController(preferences).._restore();
  }

  final SharedPreferences _preferences;
  AppearancePreference appearance = AppearancePreference.system;
  QuranThemeFamily themeFamily = QuranThemeFamily.emerald;
  AppLanguage language = AppLanguage.arabic;
  double quranFontSize = defaultFontSize;
  String? lastVerseKey;
  Set<String> bookmarks = <String>{};
  Set<String> tafsirBookmarks = <String>{};
  List<QuranReminder> reminders = <QuranReminder>[];
  bool notificationPermissionPromptSeen = false;
  Timer? _progressDebounce;

  void _restore() {
    appearance = AppearancePreference.values.firstWhere(
      (item) => item.name == _preferences.getString(_appearanceKey),
      orElse: () => AppearancePreference.system,
    );
    themeFamily = QuranThemeFamily.values.firstWhere(
      (item) => item.name == _preferences.getString(_themeFamilyKey),
      orElse: () => QuranThemeFamily.emerald,
    );
    language = AppLanguage.values.firstWhere(
      (item) => item.code == _preferences.getString(_languageKey),
      orElse: () => AppLanguage.arabic,
    );
    quranFontSize = clampFontSize(
      _preferences.getDouble(_fontSizeKey) ?? defaultFontSize,
    );
    lastVerseKey = _preferences.getString(_lastVerseKey);
    bookmarks =
        _preferences.getStringList(_bookmarksKey)?.toSet() ?? <String>{};
    tafsirBookmarks =
        _preferences.getStringList(_tafsirBookmarksKey)?.toSet() ?? <String>{};
    notificationPermissionPromptSeen =
        _preferences.getBool(_notificationPermissionPromptSeenKey) ?? false;
    final encodedReminders = _preferences.getString(_remindersKey);
    if (encodedReminders != null) {
      try {
        final decoded = jsonDecode(encodedReminders);
        if (decoded is List) {
          reminders = decoded
              .whereType<Map<String, dynamic>>()
              .map(QuranReminder.fromJson)
              .toList(growable: false);
        }
      } catch (_) {
        reminders = <QuranReminder>[];
      }
    }
  }

  static double clampFontSize(double value) =>
      value.clamp(minFontSize, maxFontSize).toDouble();

  bool isBookmarked(String verseKey) => bookmarks.contains(verseKey);

  bool isTafsirBookmarked(String entryKey) =>
      tafsirBookmarks.contains(entryKey);

  Future<void> setAppearance(AppearancePreference value) async {
    if (appearance == value) return;
    appearance = value;
    notifyListeners();
    await _preferences.setString(_appearanceKey, value.name);
  }

  Future<void> setThemeFamily(QuranThemeFamily value) async {
    if (themeFamily == value) return;
    themeFamily = value;
    notifyListeners();
    await _preferences.setString(_themeFamilyKey, value.name);
  }

  Future<void> setLanguage(AppLanguage value) async {
    if (language == value) return;
    language = value;
    notifyListeners();
    await _preferences.setString(_languageKey, value.code);
  }

  Future<void> setFontSize(double value) async {
    final next = clampFontSize(value);
    if (next == quranFontSize) return;
    quranFontSize = next;
    notifyListeners();
    await _preferences.setDouble(_fontSizeKey, next);
  }

  Future<void> toggleBookmark(String verseKey) async {
    final next = Set<String>.from(bookmarks);
    if (!next.add(verseKey)) next.remove(verseKey);
    bookmarks = next;
    notifyListeners();
    await _preferences.setStringList(_bookmarksKey, bookmarks.toList()..sort());
  }

  Future<void> toggleTafsirBookmark(String entryKey) async {
    final next = Set<String>.from(tafsirBookmarks);
    if (!next.add(entryKey)) next.remove(entryKey);
    tafsirBookmarks = next;
    notifyListeners();
    await _preferences.setStringList(
      _tafsirBookmarksKey,
      tafsirBookmarks.toList()..sort(),
    );
  }

  int nextReminderNotificationBaseId() {
    var candidate = 100000;
    final occupied = reminders
        .expand(
          (item) => List<int>.generate(
            8,
            (offset) => item.notificationBaseId + offset,
          ),
        )
        .toSet();
    while (List<int>.generate(
      8,
      (offset) => candidate + offset,
    ).any(occupied.contains)) {
      candidate += 100;
    }
    return candidate;
  }

  Future<void> markNotificationPermissionPromptSeen() async {
    if (notificationPermissionPromptSeen) return;
    notificationPermissionPromptSeen = true;
    notifyListeners();
    await _preferences.setBool(_notificationPermissionPromptSeenKey, true);
  }

  Future<void> upsertReminder(QuranReminder reminder) async {
    final next = List<QuranReminder>.from(reminders);
    final index = next.indexWhere((item) => item.id == reminder.id);
    if (index == -1) {
      next.add(reminder);
    } else {
      next[index] = reminder;
    }
    reminders = List<QuranReminder>.unmodifiable(next);
    notifyListeners();
    await _preferences.setString(
      _remindersKey,
      jsonEncode(reminders.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> removeReminder(String reminderId) async {
    reminders = List<QuranReminder>.unmodifiable(
      reminders.where((item) => item.id != reminderId),
    );
    notifyListeners();
    await _preferences.setString(
      _remindersKey,
      jsonEncode(reminders.map((item) => item.toJson()).toList()),
    );
  }

  void updateReadingPosition(String verseKey) {
    if (lastVerseKey == verseKey) return;
    lastVerseKey = verseKey;
    notifyListeners();
    _progressDebounce?.cancel();
    _progressDebounce = Timer(const Duration(milliseconds: 500), () {
      _preferences.setString(_lastVerseKey, verseKey);
    });
  }

  Future<void> clearReadingProgress() async {
    _progressDebounce?.cancel();
    lastVerseKey = null;
    notifyListeners();
    await _preferences.remove(_lastVerseKey);
  }

  @override
  void dispose() {
    _progressDebounce?.cancel();
    super.dispose();
  }
}
