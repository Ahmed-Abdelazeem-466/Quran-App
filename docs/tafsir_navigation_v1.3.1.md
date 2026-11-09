# Tafsir navigation v1.3.1

Al-Muyassar Surah, Juz, and Rub‘ entry points now retain their exact canonical start and end ayahs. This is a general range implementation, not a hard-coded correction for Rub‘ 1. Exhaustive tests enumerate all 30 Juz and all 240 Rub‘ sections, including all Surahs crossed within each interval, every included ayah, and exclusion of the adjacent outside ayahs.

The scoped ayah wheel enumerates the full section in canonical order. A label such as `2:1` means Surah 2, ayah 1. Moving through the first Rub‘ continues from `1:7` to `2:1` and ends at `2:25`. Each selection updates the three-line Arabic Quran preview. The selected ayah is also identified by its Surah name in the reader header.

Al-Muyassar page arrows and the page picker are limited to the original PDF pages intersecting the selected section. These are complete scanned pages. If a section begins or ends in the middle of a page, neighboring ayahs and explanations printed on that same boundary page remain visible; no Arabic book content is erased or arbitrarily cropped. Navigating to later pages outside the section is blocked. Existing saved page bookmarks intentionally keep their original whole-book navigation because they did not store a section scope.

Ibn Kathir is NOT fully indexed by ayah in this release. Six explicit, visually verified passage ranges have been added: 3:16–20 → p357, 3:21–26 → p359, 3:27–28 → p360, 4:11 → p447, 4:12 → p449, and 4:13–14 → p450. These anchors resolve the two examples reported by the user and their verified neighboring ranges; they do not constitute a complete index of the book. Continuation pages may contain the rest of a combined passage. No proportional or interpolated page destinations were invented.

Other Ibn Kathir selections still open the containing Surah’s beginning. The interface explains the partial coverage in all fourteen app languages. A reliable complete index requires additional validated mappings against this exact 2,061-page scan. The OCR assessment and visual evidence provenance are recorded in `docs/ibn_kathir_partial_index_provenance.md`. A complete ayah index is deliberately left pending.

The v1.3 release signing key is retained. Version 1.3.1 / build 6 can install directly over v1.3.0 without uninstalling and preserves existing local app data. The previously lost v1.2 signing identity is not restored by this update.
