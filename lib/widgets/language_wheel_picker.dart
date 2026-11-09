import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import 'themed_selection_wheel.dart';

class LanguageWheelPicker {
  const LanguageWheelPicker._();

  static Future<AppLanguage?> show(
    BuildContext context, {
    required AppLanguage initialLanguage,
    required AppStrings strings,
  }) {
    return showModalBottomSheet<AppLanguage>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _LanguageWheelSheet(
        initialLanguage: initialLanguage,
        strings: strings,
      ),
    );
  }
}

class _LanguageWheelSheet extends StatefulWidget {
  const _LanguageWheelSheet({
    required this.initialLanguage,
    required this.strings,
  });

  final AppLanguage initialLanguage;
  final AppStrings strings;

  @override
  State<_LanguageWheelSheet> createState() => _LanguageWheelSheetState();
}

class _LanguageWheelSheetState extends State<_LanguageWheelSheet> {
  late final FixedExtentScrollController _controller;
  late AppLanguage _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;
    _controller = FixedExtentScrollController(
      initialItem: AppLanguage.values.indexOf(widget.initialLanguage),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SheetHandle(),
                    Text(
                      widget.strings.chooseLanguage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      key: const Key('language-wheel'),
                      height: _wheelHeight(context),
                      child: ThemedSelectionWheel(
                        controller: _controller,
                        itemCount: AppLanguage.values.length,
                        height: _wheelHeight(context),
                        onSelectedItemChanged: (index) => setState(
                          () => _selectedLanguage = AppLanguage.values[index],
                        ),
                        itemBuilder: (context, index) {
                          final language = AppLanguage.values[index];
                          return Center(
                            child: Directionality(
                              textDirection: language.isRtl
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: Text(
                                language.nativeName,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(widget.strings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_selectedLanguage),
                    child: Text(
                      MaterialLocalizations.of(context).okButtonLabel,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _wheelHeight(BuildContext context) {
    final available = MediaQuery.sizeOf(context).height;
    return (available * 0.30).clamp(168.0, 224.0).toDouble();
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 38,
      height: 4,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(99),
      ),
    ),
  );
}
