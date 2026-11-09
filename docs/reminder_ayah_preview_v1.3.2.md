# Reminder selected-ayah preview — v1.3.2

When a reminder is set to a specific ayah range, the editor now displays a theme-matched preview card immediately under the range selectors. It combines the selected canonical Arabic Uthmani ayahs with their ayah-number markers. The preview updates as soon as either the start or end ayah changes and is limited to four visible lines to keep the editor compact, with the remaining text clipped visually rather than changing the saved reminder or notification content.

Whole-Surah reminders do not show the range preview. The preview reads the same local Quran repository used to compose reminders; it does not alter or translate Quran text. `test/reminder_ayah_preview_test.dart` checks preview visibility, live boundary updates, exact selected Arabic text, and ayah-number markers.

Release identity: `1.3.2+7`, Android package `com.qurankareem.app`. This update preserves the signing certificate used by v1.3.0/v1.3.1 so it can be installed as an update without uninstalling.
