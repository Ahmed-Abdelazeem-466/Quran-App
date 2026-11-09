# Original additional Tafsir sources

The files `assets/tafsir/tafsir_muyassar.pdf` and `assets/tafsir/tafsir_ibn_kathir.pdf` are exact copies of the two PDFs uploaded by the user. The import script records SHA-256 checksums in `source/tafsir_pdf_manifest.json`. No PDF pages, Arabic explanations, or Quran text were OCR-rewritten, translated, shortened, or replaced with another edition.

The 609-page Al-Muyassar PDF contains Quran body pages 1–604 in standard Madinah pagination. The application’s existing Quran ayah metadata supplies its printed Quran page; the original PDF has no initial cover offset. Opening, closing, and several middle Surah destinations were visually checked during source assessment. The remaining five pages are index/publication matter.

The 2,061-page Ibn Kathir scan has all 114 Surah bookmarks but no ayah-level index or usable text layer. Its embedded Surah destinations are retained in `assets/data/tafsir_pdf_index.json`. Surahs 103 and 104 both begin on original PDF page 2029; both headings were visually checked. The source’s bookmark label for Surah 110 is an error; the interface uses the canonical Quran Surah name while retaining its page destination.

The selected ayah’s exact Arabic Uthmani text is an independent navigation reference above the picker/reader. For Al-Muyassar, selection opens the page containing that ayah. For Ibn Kathir, selection enters the containing Surah and explicitly says that the user must browse its pages to find the explanation. No approximate or interpolated ayah-page mapping is presented as exact. Juz/Rub‘ entries retain the same limitation for Ibn Kathir.

Android renders the bundled documents using its native `PdfRenderer` on a single worker thread. Only the two allowed bundled paths can be opened by the channel. A private cache copy makes the asset seekable without reading an entire PDF into Dart memory. Each page is opened, rasterized at a bounded resolution, closed, and released; only the currently displayed raster is retained in Flutter. The original scans keep their own paper/ink appearance. The surrounding controls, previews, and cards follow the selected app theme.

PDF page bookmarks are source-specific: `pdf|workId|page|surah|ayah`. The stored page is an actual document location; the ayah component is the user’s reference selection, not an asserted coordinate inside the scan. Existing Al-Sa‘di entry keys remain unchanged and continue to support text sharing and excerpt selection.

For true independently selectable, searchable, shareable per-ayah Ibn Kathir text in a future update, obtain a verified structured text version of the desired edition or build a manually validated ayah-page/coordinate map against this exact scan. That additional dataset is not fabricated in this release.

## v1.3.1 update

The previous Surah-only behavior described above is superseded only for the six visually verified Ibn Kathir passage ranges recorded in `docs/tafsir_navigation_v1.3.1.md`. Other Ibn Kathir ayahs remain unindexed. Al-Muyassar now retains exact scope and limits page navigation for every Surah/Juz/Rub entry. Complete shared boundary pages still display their original adjacent printed content. Do not regenerate the PDF index without retaining/reapplying its verified range records.
