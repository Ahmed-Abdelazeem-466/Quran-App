import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_theme.dart';
import 'controllers/app_controller.dart';
import 'data/quran_repository.dart';
import 'data/tafsir_repository.dart';
import 'localization/app_strings.dart';
import 'screens/home_shell.dart';
import 'services/quran_reminder_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await QuranRepository.load();
  final tafsirRepository = await TafsirRepository.load();
  final controller = await AppController.load();
  final reminderScheduler = QuranReminderScheduler();
  await reminderScheduler.rescheduleAll(
    reminders: controller.reminders,
    repository: repository,
    strings: AppStrings(controller.language),
  );
  runApp(
    QuranApp(
      repository: repository,
      tafsirRepository: tafsirRepository,
      controller: controller,
    ),
  );
}

class QuranApp extends StatelessWidget {
  const QuranApp({
    required this.repository,
    required this.tafsirRepository,
    required this.controller,
    super.key,
  });

  final QuranRepository repository;
  final TafsirRepository tafsirRepository;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final language = controller.language;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: language == AppLanguage.arabic
              ? 'القرآن الكريم'
              : 'Quran Kareem',
          locale: language.materialLocale,
          supportedLocales: AppLanguage.values
              .map((language) => language.materialLocale)
              .toSet()
              .toList(growable: false),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(controller.themeFamily),
          darkTheme: AppTheme.dark(controller.themeFamily),
          themeMode: controller.appearance.themeMode,
          builder: (context, child) => Directionality(
            textDirection: language.isRtl
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
          home: HomeShell(
            repository: repository,
            tafsirRepository: tafsirRepository,
            controller: controller,
          ),
        );
      },
    );
  }
}
