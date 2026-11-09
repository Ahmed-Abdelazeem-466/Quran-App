import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/app/app_theme.dart';
import 'package:quran_kareem_flutter/controllers/app_controller.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/data/scanned_tafsir_repository.dart';
import 'package:quran_kareem_flutter/localization/app_strings.dart';
import 'package:quran_kareem_flutter/localization/tafsir_strings.dart';
import 'package:quran_kareem_flutter/models/tafsir_work.dart';
import 'package:quran_kareem_flutter/screens/scanned_tafsir_reader_screen.dart';
import 'package:quran_kareem_flutter/services/tafsir_pdf_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final quran = QuranRepository.fromJsonString(
    File('assets/data/quran.json').readAsStringSync(),
  );
  final scans = ScannedTafsirRepository.fromJsonString(
    File('assets/data/tafsir_pdf_index.json').readAsStringSync(),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(TafsirPdfService.channel, (call) async {
          if (call.method == 'release') return null;
          throw PlatformException(
            code: 'PDF_RENDER_FAILED',
            message: 'Controlled test failure',
          );
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(TafsirPdfService.channel, null);
  });

  for (final size in [const Size(430, 932), const Size(844, 390)]) {
    testWidgets(
      'scanned reader retains actual page/reference and handles load failure at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = await AppController.load();
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark(QuranThemeFamily.desert),
            home: ScannedTafsirReaderScreen(
              work: TafsirWork.ibnKathir,
              repository: quran,
              scanRepository: scans,
              controller: controller,
              selectedVerse: quran.verse('2:286')!,
              initialPage: 77,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final labels = TafsirStrings(AppLanguage.english);
        expect(find.text('Page 77 / 2061'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('scan-ayah-reference')),
          findsOneWidget,
        );
        expect(find.text(labels.loadFailed), findsOneWidget);
        expect(find.text(labels.retry), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (size.height < 500) {
          await tester.tap(find.byTooltip(labels.originalScan));
          await tester.pumpAndSettle();
          expect(find.text(labels.ibnKathirNotice), findsOneWidget);
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
        } else {
          expect(find.text(labels.ibnKathirNotice), findsOneWidget);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      },
    );
  }
}
