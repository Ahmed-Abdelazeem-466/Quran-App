import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/controllers/app_controller.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/data/scanned_tafsir_repository.dart';
import 'package:quran_kareem_flutter/localization/app_strings.dart';
import 'package:quran_kareem_flutter/localization/tafsir_strings.dart';
import 'package:quran_kareem_flutter/models/tafsir_work.dart';
import 'package:quran_kareem_flutter/services/tafsir_pdf_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late QuranRepository quran;
  late ScannedTafsirRepository scans;
  setUpAll(() async {
    quran = QuranRepository.fromJsonString(
      await File('assets/data/quran.json').readAsString(),
    );
    scans = ScannedTafsirRepository.fromJsonString(
      await File('assets/data/tafsir_pdf_index.json').readAsString(),
    );
  });

  test('all three Tafsir works remain available with independent sources', () {
    expect(TafsirWork.values, hasLength(3));
    expect(TafsirWork.saadi.isScanned, false);
    expect(TafsirWork.muyassar.pageCount, 609);
    expect(TafsirWork.ibnKathir.pageCount, 2061);
    expect(TafsirWork.values.map((work) => work.id).toSet(), hasLength(3));
  });

  test('Muyassar ayahs map directly to the original 604-page layout', () {
    for (final surah in quran.data.surahs) {
      for (final verse in surah.verses) {
        expect(scans.pageForVerse(TafsirWork.muyassar, verse), verse.page);
      }
    }
    expect(scans.pageForVerse(TafsirWork.muyassar, quran.verse('1:1')!), 1);
    expect(scans.pageForVerse(TafsirWork.muyassar, quran.verse('3:1')!), 50);
    expect(scans.pageForVerse(TafsirWork.muyassar, quran.verse('114:6')!), 604);
  });

  test('Ibn Kathir retains all 114 original Surah links without interpolating ayahs', () {
    expect(scans.ibnKathirSurahPages.keys.toSet(), {
      for (var i = 1; i <= 114; i++) i,
    });
    expect(scans.pageForVerse(TafsirWork.ibnKathir, quran.verse('1:1')!), 61);
    expect(scans.pageForVerse(TafsirWork.ibnKathir, quran.verse('2:1')!), 77);
    expect(scans.pageForVerse(TafsirWork.ibnKathir, quran.verse('2:286')!), 77);
    expect(scans.ibnKathirSurahPages[103], 2029);
    expect(scans.ibnKathirSurahPages[104], 2029);
    expect(scans.ibnKathirSurahPages[110], 2042);
    expect(scans.ibnKathirSurahPages[114], 2055);
  });

  test('verified Ibn Kathir anchors resolve both reported selections without interpolation', () {
    expect(scans.pageForVerse(TafsirWork.ibnKathir, quran.verse('3:19')!), 357);
    expect(scans.pageForVerse(TafsirWork.ibnKathir, quran.verse('4:13')!), 450);
    expect(scans.verifiedIbnKathirPage(quran.verse('3:15')!), isNull);
    expect(scans.verifiedIbnKathirPage(quran.verse('4:15')!), isNull);
    for (final range in scans.ibnKathirAyahRanges) {
      for (var ayah = range['startAyah']!; ayah <= range['endAyah']!; ayah++) {
        expect(
          scans.verifiedIbnKathirPage(quran.verse('${range['surah']}:$ayah')!),
          range['firstPage'],
        );
      }
    }
  });

  test('new navigation and scan notices exist in every app language', () {
    for (final language in AppLanguage.values) {
      final labels = TafsirStrings(language);
      expect([
        labels.chooseTafsir,
        labels.chooseAyah,
        labels.openReading,
        labels.page,
        labels.choosePage,
        labels.originalScan,
        labels.ibnKathirNotice,
        labels.androidOnly,
        labels.loadFailed,
        labels.retry,
        labels.selectedAyah,
      ], everyElement(isNotEmpty));
    }
  });

  test('scanned bookmarks retain source/page and reject malformed keys', () {
    const bookmark = ScannedTafsirBookmark(
      work: TafsirWork.ibnKathir,
      page: 77,
      surah: 2,
      ayah: 286,
    );
    final decoded = ScannedTafsirBookmark.tryParse(bookmark.key)!;
    expect(decoded.work, bookmark.work);
    expect(decoded.page, 77);
    expect(decoded.ayah, 286);
    for (final key in [
      '2:1',
      'pdf|saadi|1|1|1',
      'pdf|ibnKathir|2062|1|1',
      'pdf|muyassar|0|1|1',
      'pdf|muyassar|2|115|1',
      'pdf|unknown|1|1|1',
    ]) {
      expect(ScannedTafsirBookmark.tryParse(key), isNull);
    }
    expect(
      bookmark.key,
      isNot(
        const ScannedTafsirBookmark(
          work: TafsirWork.muyassar,
          page: 77,
          surah: 2,
          ayah: 286,
        ).key,
      ),
    );
  });

  test('page bookmarks persist independently of old Saadi entries', () async {
    SharedPreferences.setMockInitialValues({
      'tafsirBookmarks': ['2:1'],
    });
    final controller = await AppController.load();
    const key = 'pdf|ibnKathir|77|2|1';
    await controller.toggleTafsirBookmark(key);
    final restored = await AppController.load();
    expect(restored.tafsirBookmarks, containsAll(['2:1', key]));
    await restored.toggleTafsirBookmark(key);
    expect(restored.tafsirBookmarks, contains('2:1'));
    expect(restored.tafsirBookmarks, isNot(contains(key)));
    controller.dispose();
    restored.dispose();
  });

  test(
    'native rendering receives a zero-based page and bounded resolution',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      MethodCall? received;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(TafsirPdfService.channel, (call) async {
            received = call;
            return {
              'bytes': Uint8List.fromList([1, 2]),
              'width': 1800,
              'height': 2600,
              'pageCount': 609,
            };
          });
      try {
        final page = await TafsirPdfService.render(
          TafsirWork.muyassar,
          604,
          width: 9999,
        );
        expect(received!.method, 'renderPage');
        expect(received!.arguments['page'], 603);
        expect(received!.arguments['width'], 2200);
        expect(page.pageCount, 609);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(TafsirPdfService.channel, null);
      }
    },
  );
}
