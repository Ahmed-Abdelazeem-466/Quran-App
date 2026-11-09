#!/usr/bin/env python3
"""Package the standalone Android APK, Flutter source and PRIVATE signing backup."""
import argparse
import hashlib
import shutil
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--apk', required=True, type=Path)
    parser.add_argument('--destination', required=True, type=Path)
    parser.add_argument('--version', default='1.3.0')
    parser.add_argument('--label', default='Three-Tafsirs-Wheel-Pickers')
    args = parser.parse_args()
    args.destination.mkdir(parents=True, exist_ok=True)
    stem = f'Quran-Kareem-{args.label}-v{args.version}'
    apk = args.destination / f'{stem}.apk'
    shutil.copy2(args.apk, apk)
    source_zip = args.destination / f'{stem}-Flutter-Source.zip'
    excluded = {'.git', '.dart_tool', 'build', '.gradle', '.idea', '.cxx', 'signing', 'themed_launch_review_deck'}
    with zipfile.ZipFile(source_zip, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
        for path in sorted(ROOT.rglob('*')):
            relative = path.relative_to(ROOT)
            if not path.is_file() or any(part in excluded for part in relative.parts):
                continue
            if path.name in {'local.properties', 'key.properties', '.flutter-plugins-dependencies'} or path.suffix in {'.p12', '.pfx', '.jks', '.keystore'} or 'presentation' in path.name:
                continue
            archive.write(path, Path('quran-kareem-flutter') / relative)
    backup_zip = args.destination / f'Quran-Kareem-PRIVATE-Signing-Key-Backup-v{args.version}.zip'
    with zipfile.ZipFile(backup_zip, 'w', zipfile.ZIP_DEFLATED) as archive:
        for relative in [Path('android/key.properties'), Path('android/signing/quran-kareem-release.p12')]:
            archive.write(ROOT / relative, relative)
        archive.writestr('README-PRIVATE.txt',
            'PRIVATE AND IMPORTANT\n\n'
            'This ZIP contains the private release signing key and its password configuration. '
            'Keep it confidential and make a durable private backup. Do not upload it to a public repository.\n\n'
            'To build future updates of the supplied v1.3 APK, extract the android/ folder from this ZIP '
            'into the root of the extracted quran-kareem-flutter source project. Then run flutter pub get '
            'and flutter build apk --release. Increment the version/build number in pubspec.yaml.\n\n'
            'Do not run create-release-signing.sh if a signing key already exists. A replacement private '
            'key changes the Android signing identity and prevents installing an APK as an update.\n\n'
            'This is the same dedicated key used for v1.3.0. Later v1.3 updates preserve its identity. '
            'It cannot update the old v1.2 APK, whose key was not recovered. '
            'The first transition from v1.2 to this v1.3 requires a fresh install and may erase local data.\n')
    checksum_lines = []
    for path in [apk, source_zip, backup_zip]:
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        checksum_lines.append(f'{digest}  {path.name}')
        print(f'{path} ({path.stat().st_size / 1024 / 1024:.1f} MiB)')
    (args.destination / 'SHA256SUMS.txt').write_text('\n'.join(checksum_lines) + '\n')
    with zipfile.ZipFile(source_zip) as archive:
        assert archive.testzip() is None
        names = archive.namelist()
        assert not any('key.properties' in name or name.endswith('.p12') for name in names)
        for asset in ['assets/tafsir/tafsir_muyassar.pdf', 'assets/tafsir/tafsir_ibn_kathir.pdf', 'lib/widgets/ayah_wheel_picker.dart']:
            assert f'quran-kareem-flutter/{asset}' in names
    with zipfile.ZipFile(backup_zip) as archive:
        assert archive.testzip() is None
    print('ZIP integrity and private-key separation verified.')


if __name__ == '__main__':
    main()
