#!/usr/bin/env python3
"""Bundle the user's original scans, without OCR or modifying Arabic text.
Requires PyMuPDF. Run with the two original PDF paths as positional arguments.
"""
import argparse
import hashlib
import json
import re
import shutil
from pathlib import Path

import fitz

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('muyassar_pdf', type=Path)
    parser.add_argument('ibn_kathir_pdf', type=Path)
    args = parser.parse_args()
    destination = ROOT / 'assets' / 'tafsir'
    destination.mkdir(parents=True, exist_ok=True)
    manifest = []
    surah_pages = {}
    for work, path, name, expected in [
        ('muyassar', args.muyassar_pdf, 'tafsir_muyassar.pdf', 609),
        ('ibnKathir', args.ibn_kathir_pdf, 'tafsir_ibn_kathir.pdf', 2061),
    ]:
        with fitz.open(path) as document:
            assert len(document) == expected, (work, len(document))
            outline = document.get_toc()
            if work == 'ibnKathir':
                for _, title, page in outline:
                    match = re.match(r'^\s*(\d+)\s*[-–]\s*سورة', title)
                    if match:
                        number = int(match.group(1))
                        if 1 <= number <= 114:
                            surah_pages[str(number)] = page
                assert set(map(int, surah_pages)) == set(range(1, 115))
                assert all(1 <= value <= expected for value in surah_pages.values())
        target = destination / name
        if path.resolve() != target.resolve():
            shutil.copyfile(path, target)
        digest = hashlib.sha256(target.read_bytes()).hexdigest()
        manifest.append({'id': work, 'original_filename': path.name, 'asset': str(target.relative_to(ROOT)), 'pages': expected, 'sha256': digest, 'content': 'Original image-only PDF; no OCR, transcription, translation or alteration'})
    index = {
        'version': 1,
        'muyassarQuranPageOffset': 0,
        'muyassarQuranBodyPages': 604,
        'ibnKathirSurahPages': surah_pages,
        'ibnKathirAyahMapAvailable': False,
        'notes': [
            'Al-Muyassar page N is Madinah Quran page N for pages 1–604, visually verified on opening, middle and closing samples.',
            'Ibn Kathir uses embedded original Surah destinations only; no interpolated ayah/page links.',
            'Surahs 103 and 104 legitimately begin on the same PDF page 2029; both headings verified visually.',
            'The PDF bookmark for Surah 110 misnames it as al-Fath. UI uses canonical Quran metadata for the name and preserves PDF page destination 2042.',
        ],
    }
    (ROOT / 'assets/data/tafsir_pdf_index.json').write_text(json.dumps(index, ensure_ascii=False, indent=2) + '\n')
    (ROOT / 'source/tafsir_pdf_manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    print('Bundled original Tafsir PDFs and 114 Ibn Kathir Surah destinations.')


if __name__ == '__main__':
    main()
