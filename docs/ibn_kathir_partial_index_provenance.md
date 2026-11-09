# Ibn Kathir header OCR assessment — 2026-11-06

## Executive result

No full ayah-header map was generated. The bounded attempt produced reliable **partial, explicit coverage only**. The OCR is fast and resumable under the corrected process limits, but Tesseract Arabic output is not consistently reliable enough to infer or interpolate a complete 2,061-page map. Missing or contradictory headers are left unresolved rather than guessed.

The two requested cases were proven by direct visual review of original scan header crops:

- **Qur’an 3:19 (Āl ʿImrān)**: the original scan header on PDF page **357** reads `سورة آل عمران، الآيات: ١٦–٢٠`; page **358** repeats the same printed range. Therefore 3:19 is explicitly covered by the printed range on **PDF pages 357–358**. Canonical `quran.json` independently places 3:19 on Qur’an page 52 and confirms the surah verse count is 200.
- **Qur’an 4:13 (An-Nisāʾ)**: original scan headers show PDF page **447** and **448** as ayah 11, page **449** as ayah 12, and PDF page **450** as `سورة النساء، الآيتان: ١٣، ١٤`. Therefore 4:13 is explicitly covered on **PDF page 450**. Canonical `quran.json` independently places 4:13 on Qur’an page 79 and confirms the surah verse count is 176.

These are page/header observations, not interpolated page mappings.

## Concrete bounded coverage

### Directly visually verified target windows

- PDF **357–360**, Āl ʿImrān:
  - p357: printed range 16–20
  - p358: printed range 16–20
  - p359: printed range 21–26
  - p360: printed range 27–28
- PDF **447–450**, An-Nisāʾ:
  - p447: ayah 11
  - p448: ayah 11
  - p449: ayah 12
  - p450: ayahs 13–14

The original top-header crops used for visual review are in `probe/visual_targets/`.

### OCR-only representative/diagnostic records

The requested representative pages were run with the bounded runner: **61, 77, 349, 350, 438, 439, 922, 923, 924, 2055** (10 pages total). Typical page time was approximately **1.1–2.8 seconds** with 3 workers, 260 DPI, 14% top crop, and PSM 6/7/11. PSM 6 was generally the most useful; PSM 7 often returned empty output; PSM 11 sometimes separated header numerals or lost them.

Useful OCR corroborations include:

- p349: repeated OCR candidates identify `سورة آل عمران` and a likely 1–4 range, but this was not included as a final visual proof of the target cases.
- p439: repeated OCR candidates identify An-Nisāʾ and a likely 1–5 range, but this was not included as a final visual proof.
- p923–924: OCR identifies Sūrat Yūnus but demonstrates the numeral/RTL failure mode; these records are not treated as verified ranges.

## Process correction and safety checks

`ocr_ibn_kathir_headers.py` was updated only in `/home/ubuntu/ibn-kathir-ayah-index` (no Dart files changed) to add:

- `OMP_THREAD_LIMIT=1` and `OMP_NUM_THREADS=1` for every Tesseract subprocess;
- hard Tesseract subprocess timeout of 10 seconds;
- worker clamp to 2–4, with the runs using 3 workers;
- tight default crop (`top_fraction=0.14`) and multi-PSM OCR;
- atomic checkpoint flushes every 20 pages (and at completion);
- `--resume` support that skips pages already present in the output JSON;
- raw text, stderr, return code, timeout status, and run parameters in the output.

After every bounded run, process inspection showed **no lingering Python OCR workers and no lingering Tesseract processes**; only the sandbox supervisor remained. The prior runaway process condition is therefore cleared.

## Provenance

- Source PDF: `/home/ubuntu/quran-kareem-flutter/assets/tafsir/tafsir_ibn_kathir.pdf`
- SHA-256: recorded in `provenance_runtime.txt` as `cfa3756896d1e2a3ccf3d16267a0c419774cd6df9c9060370daf11e501625348`
- PDF pages: 2,061
- Page size: 443.746 × 665.461 pt
- Tesseract: 5.3.4, Arabic model `ara`
- PyMuPDF: 2.1 in `/home/ubuntu/quran-tools-env`
- Canonical Quran data: `/home/ubuntu/quran-kareem-flutter/assets/data/quran.json`
- Canonical counts: 114 surahs, 6,236 verses
- Runner settings: 260 DPI, top 14%, PSM 6/7/11, 3 workers, OMP=1, timeout=10 s

## Output artifacts

- Main corrected runner: `ocr_ibn_kathir_headers.py`
- Target OCR records: `probe/window_351_356.json`, `probe/window_357_360.json`, `probe/window_440_446.json`, `probe/window_447_450.json`
- Representative records: `probe/smoke_new.json`, `probe/smoke_77.json`, `probe/smoke_349_350.json`, `probe/smoke_438_439.json`, `probe/smoke_922_923.json`, `probe/smoke_924.json`, `probe/smoke_2055.json`
- Visually reviewed original header crops: `probe/visual_targets/p0357_top16.png` through `p0360_top16.png`, and `p0447_top16.png` through `p0450_top16.png`
- Runtime provenance: `provenance_runtime.txt`

## Limitation / next truthful step

Do not use the OCR-only candidate pairs as a full page map. A truthful full map would require a more specialized header-line detector and per-page visual/segmentation validation, followed by monotonic range reconciliation against canonical verse counts. This bounded run intentionally stopped short of that claim.
