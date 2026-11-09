import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoPicker;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem_flutter/controllers/app_controller.dart';
import 'package:quran_kareem_flutter/data/quran_repository.dart';
import 'package:quran_kareem_flutter/localization/app_strings.dart';
import 'package:quran_kareem_flutter/screens/reminders_screen.dart';
import 'package:quran_kareem_flutter/services/quran_reminder_scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late QuranRepository quran;

  setUpAll(() async {
    quran = QuranRepository.fromJsonString(
      await File('assets/data/quran.json').readAsString(),
    );
  });

  testWidgets('reminder ayah range shows and updates its Arabic preview', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'language': 'en'});
    final controller = await AppController.load();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ReminderEditorScreen(
          repository: quran,
          controller: controller,
          scheduler: QuranReminderScheduler(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reminder-ayah-preview')), findsNothing);
    await tester.ensureVisible(
      find.text(AppStrings(AppLanguage.english).ayahRange),
    );
    await tester.tap(find.text(AppStrings(AppLanguage.english).ayahRange));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reminder-ayah-preview')), findsOneWidget);
    Text preview = tester.widget(
      find.byKey(const Key('reminder-ayah-preview-text')),
    );
    expect(preview.data, contains(quran.verse('1:1')!.text));
    expect(preview.data, contains('﴿7﴾'));

    const startField = ValueKey('start-ayah-wheel-field');
    await tester.ensureVisible(find.byKey(startField));
    await tester.tap(find.byKey(startField));
    await tester.pumpAndSettle();
    var wheel = tester.widget<CupertinoPicker>(find.byType(CupertinoPicker));
    expect(wheel.scrollController!.selectedItem, 0);
    wheel.scrollController!.jumpToItem(1);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    preview = tester.widget(
      find.byKey(const Key('reminder-ayah-preview-text')),
    );
    expect(preview.data, isNot(contains(quran.verse('1:1')!.text)));
    expect(preview.data, contains(quran.verse('1:2')!.text));
    expect(preview.data, contains('﴿2﴾'));

    const endField = ValueKey('end-ayah-wheel-field');
    await tester.ensureVisible(find.byKey(endField));
    await tester.tap(find.byKey(endField));
    await tester.pumpAndSettle();
    wheel = tester.widget<CupertinoPicker>(find.byType(CupertinoPicker));
    expect(
      wheel.scrollController!.selectedItem,
      quran.verse('1:7')!.number - 2,
    );
    wheel.scrollController!.jumpToItem(1);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    preview = tester.widget(
      find.byKey(const Key('reminder-ayah-preview-text')),
    );
    expect(preview.data, contains(quran.verse('1:2')!.text));
    expect(preview.data, contains(quran.verse('1:3')!.text));
    expect(preview.data, contains('﴿3﴾'));
    expect(preview.data, isNot(contains(quran.verse('1:4')!.text)));
    expect(tester.takeException(), isNull);
  });
}
