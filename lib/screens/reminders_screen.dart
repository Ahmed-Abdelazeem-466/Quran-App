import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart'
    show CupertinoPicker, FixedExtentScrollController;

import '../controllers/app_controller.dart';
import '../data/quran_repository.dart';
import '../localization/app_strings.dart';
import '../models/quran_reminder.dart';
import '../models/quran_models.dart';
import '../services/quran_reminder_scheduler.dart';
import '../utils/reminder_time.dart';
import '../widgets/reminder_saved_confirmation.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({
    required this.repository,
    required this.controller,
    super.key,
  });

  final QuranRepository repository;
  final AppController controller;

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final QuranReminderScheduler _scheduler = QuranReminderScheduler();
  bool _notificationStatusResolved = false;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _prepareNotificationPermission();
  }

  Future<void> _prepareNotificationPermission() async {
    var enabled = await _scheduler.areNotificationsEnabled();
    if (!enabled && !widget.controller.notificationPermissionPromptSeen) {
      await widget.controller.markNotificationPermissionPromptSeen();
      enabled = await _scheduler.requestNotificationPermission();
    }
    if (mounted) {
      setState(() {
        _notificationStatusResolved = true;
        _notificationsEnabled = enabled;
      });
    }
  }

  Future<void> _openEditor([QuranReminder? reminder]) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReminderEditorScreen(
          repository: widget.repository,
          controller: widget.controller,
          scheduler: _scheduler,
          reminder: reminder,
        ),
      ),
    );
  }

  Future<void> _toggleReminder(QuranReminder reminder, bool enabled) async {
    final updated = reminder.copyWith(enabled: enabled);
    await widget.controller.upsertReminder(updated);
    await _scheduler.rescheduleAll(
      reminders: widget.controller.reminders,
      repository: widget.repository,
      strings: AppStrings(widget.controller.language),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final strings = AppStrings(widget.controller.language);
        final reminders = widget.controller.reminders;
        return Scaffold(
          appBar: AppBar(title: Text(strings.reminders)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openEditor,
            icon: const Icon(Icons.add_alert_rounded),
            label: Text(strings.addReminder),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              Text(
                strings.reminderDescription,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              if (_notificationStatusResolved &&
                  !_notificationsEnabled &&
                  !widget.controller.notificationPermissionPromptSeen)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.notificationPermission,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(strings.notificationPermissionHelp),
                              const SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: () async {
                                  await widget.controller
                                      .markNotificationPermissionPromptSeen();
                                  final enabled = await _scheduler
                                      .requestNotificationPermission();
                                  if (mounted) {
                                    setState(
                                      () => _notificationsEnabled = enabled,
                                    );
                                  }
                                },
                                child: Text(strings.allowNotifications),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_notificationStatusResolved &&
                  !_notificationsEnabled &&
                  !widget.controller.notificationPermissionPromptSeen)
                const SizedBox(height: 12),
              if (reminders.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 42),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 60,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        strings.noReminders,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              else
                ...reminders.map(
                  (reminder) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReminderCard(
                      reminder: reminder,
                      repository: widget.repository,
                      strings: strings,
                      onTap: () => _openEditor(reminder),
                      onToggle: (enabled) => _toggleReminder(reminder, enabled),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                strings.reminderSystemNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.repository,
    required this.strings,
    required this.onTap,
    required this.onToggle,
  });

  final QuranReminder reminder;
  final QuranRepository repository;
  final AppStrings strings;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final surah = repository.surah(reminder.surahNumber);
    final target = reminder.contentType == QuranReminderContentType.surah
        ? '${strings.wholeSurah} • ${surah.number} ${surah.name}'
        : '${strings.ayahRange} • ${surah.number} ${surah.name} '
              '(${reminder.startAyah}–${reminder.endAyah})';
    final days = reminder.repeatsEveryDay
        ? strings.everyDay
        : reminder.weekdays.map(strings.weekdayName).join(' • ');
    final clockTime =
        '${hour12From24Hour(reminder.hour)}:'
        '${reminder.minute.toString().padLeft(2, '0')}';
    final timePeriod = reminder.hour < 12 ? strings.morning : strings.evening;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 84,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      clockTime,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      timePeriod,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      target,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            days,
                            maxLines: 2,
                            softWrap: true,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(value: reminder.enabled, onChanged: onToggle),
            ],
          ),
        ),
      ),
    );
  }
}

class ReminderEditorScreen extends StatefulWidget {
  const ReminderEditorScreen({
    required this.repository,
    required this.controller,
    required this.scheduler,
    this.reminder,
    super.key,
  });

  final QuranRepository repository;
  final AppController controller;
  final QuranReminderScheduler scheduler;
  final QuranReminder? reminder;

  @override
  State<ReminderEditorScreen> createState() => _ReminderEditorScreenState();
}

class _ReminderEditorScreenState extends State<ReminderEditorScreen> {
  late TimeOfDay _time;
  late QuranReminderContentType _contentType;
  late int _surahNumber;
  late int _startAyah;
  late int _endAyah;
  late bool _everyDay;
  late Set<int> _weekdays;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    _time = TimeOfDay(hour: reminder?.hour ?? 7, minute: reminder?.minute ?? 0);
    _contentType = reminder?.contentType ?? QuranReminderContentType.surah;
    _surahNumber = reminder?.surahNumber ?? 1;
    final verseCount = widget.repository.surah(_surahNumber).verseCount;
    _startAyah = reminder?.startAyah ?? 1;
    _endAyah = reminder?.endAyah ?? verseCount;
    _everyDay = reminder?.repeatsEveryDay ?? true;
    _weekdays = _everyDay ? <int>{} : (reminder?.weekdays ?? <int>[]).toSet();
  }

  Future<void> _pickTime() async {
    final time = await showModalBottomSheet<TimeOfDay>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _ReminderTimePicker(
        initialTime: _time,
        strings: AppStrings(widget.controller.language),
      ),
    );
    if (time != null && mounted) setState(() => _time = time);
  }

  Future<void> _save() async {
    final strings = AppStrings(widget.controller.language);
    final verseCount = widget.repository.surah(_surahNumber).verseCount;
    final draft = QuranReminder(
      id:
          widget.reminder?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      notificationBaseId:
          widget.reminder?.notificationBaseId ??
          widget.controller.nextReminderNotificationBaseId(),
      contentType: _contentType,
      surahNumber: _surahNumber,
      startAyah: _startAyah,
      endAyah: _endAyah,
      hour: _time.hour,
      minute: _time.minute,
      everyDay: _everyDay || _weekdays.length == DateTime.daysPerWeek,
      weekdays: _everyDay || _weekdays.length == DateTime.daysPerWeek
          ? <int>[]
          : _weekdays.toList(),
      enabled: widget.reminder?.enabled ?? true,
    );
    if (!draft.hasValidSchedule) {
      _showError(strings.selectAtLeastOneDay);
      return;
    }
    if (!draft.isValidForVerseCount(verseCount)) {
      _showError(strings.invalidReminderRange);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.controller.upsertReminder(draft);
      await widget.scheduler.rescheduleAll(
        reminders: widget.controller.reminders,
        repository: widget.repository,
        strings: strings,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      await _showReminderSavedConfirmation(strings.reminderSaved);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted && _saving) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showReminderSavedConfirmation(String message) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ReminderSavedConfirmation(message: message),
      );

  Future<void> _delete() async {
    final reminder = widget.reminder;
    if (reminder == null) return;
    await widget.scheduler.cancel(reminder);
    await widget.controller.removeReminder(reminder.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.controller.language);
    final surah = widget.repository.surah(_surahNumber);
    final verseCount = surah.verseCount;
    final timeLabel = formatReminderTime(
      hour24: _time.hour,
      minute: _time.minute,
      strings: strings,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reminder == null ? strings.addReminder : strings.editReminder,
        ),
        actions: [
          if (widget.reminder != null)
            IconButton(
              tooltip: strings.deleteReminder,
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        children: [
          Text(
            strings.reminderTime,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule_rounded),
              title: Text(timeLabel, textDirection: TextDirection.ltr),
              trailing: const Icon(Icons.edit_rounded),
              onTap: _pickTime,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            strings.reminderContent,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        strings.surah,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      key: ValueKey<int>(_surahNumber),
                      value: _surahNumber,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: widget.repository.data.surahs
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.number,
                              child: Text(
                                '${item.number} • ${item.name} — ${item.transliteration}',
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        final count = widget.repository.surah(value).verseCount;
                        setState(() {
                          _surahNumber = value;
                          _startAyah = 1;
                          _endAyah = count;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<QuranReminderContentType>(
              groupValue: _contentType,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _contentType = value;
                  if (value == QuranReminderContentType.surah) {
                    _startAyah = 1;
                    _endAyah = verseCount;
                  } else {
                    _startAyah = _startAyah.clamp(1, verseCount);
                    _endAyah = _endAyah.clamp(_startAyah, verseCount);
                  }
                });
              },
              child: Column(
                children: [
                  RadioListTile<QuranReminderContentType>(
                    value: QuranReminderContentType.surah,
                    title: Text(strings.wholeSurah),
                  ),
                  RadioListTile<QuranReminderContentType>(
                    value: QuranReminderContentType.ayahRange,
                    title: Text(strings.ayahRange),
                  ),
                  if (_contentType == QuranReminderContentType.ayahRange)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _AyahRangeWheelField(
                              fieldId: 'start',
                              title: strings.startAyah,
                              value: _startAyah,
                              minValue: 1,
                              maxValue: verseCount,
                              onChanged: (value) => setState(() {
                                _startAyah = value;
                                if (_endAyah < value) _endAyah = value;
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AyahRangeWheelField(
                              fieldId: 'end',
                              title: strings.endAyah,
                              value: _endAyah,
                              minValue: _startAyah,
                              maxValue: verseCount,
                              onChanged: (value) =>
                                  setState(() => _endAyah = value),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_contentType == QuranReminderContentType.ayahRange) ...[
            const SizedBox(height: 8),
            _ReminderAyahPreview(
              surahName: surah.name,
              startAyah: _startAyah,
              endAyah: _endAyah,
              verses: surah.verses
                  .skip(_startAyah - 1)
                  .take(_endAyah - _startAyah + 1)
                  .toList(growable: false),
              label: strings.ayahRange,
            ),
          ],
          const SizedBox(height: 20),
          Text(
            strings.selectedDays,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(strings.everyDay),
                    value: _everyDay,
                    onChanged: (value) => setState(() => _everyDay = value),
                  ),
                  if (!_everyDay)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final chipWidth = (constraints.maxWidth - 10) / 2;
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List<Widget>.generate(7, (index) {
                              final day = index + 1;
                              return SizedBox(
                                width: chipWidth,
                                child: FilterChip(
                                  showCheckmark: true,
                                  label: Center(
                                    child: Text(
                                      strings.weekdayName(day),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  selected: _weekdays.contains(day),
                                  onSelected: (selected) => setState(() {
                                    if (selected) {
                                      _weekdays.add(day);
                                      if (_weekdays.length ==
                                          DateTime.daysPerWeek) {
                                        _weekdays.clear();
                                        _everyDay = true;
                                      }
                                    } else {
                                      _weekdays.remove(day);
                                    }
                                  }),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(strings.saveReminder),
          ),
        ],
      ),
    );
  }
}

class _ReminderAyahPreview extends StatelessWidget {
  const _ReminderAyahPreview({
    required this.surahName,
    required this.startAyah,
    required this.endAyah,
    required this.verses,
    required this.label,
  });

  final String surahName;
  final int startAyah;
  final int endAyah;
  final List<QuranVerse> verses;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = verses
        .map((verse) => '${verse.text} ﴿${verse.number}﴾')
        .join(' ');
    return Card(
      key: const Key('reminder-ayah-preview'),
      color: colors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$label • $surahName • $startAyah–$endAyah',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              key: const Key('reminder-ayah-preview-text'),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 20,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AyahRangeWheelField extends StatelessWidget {
  const _AyahRangeWheelField({
    required this.fieldId,
    required this.title,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  final String fieldId;
  final String title;
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _AyahRangeWheelSheet(
        title: title,
        initialValue: value.clamp(minValue, maxValue),
        minValue: minValue,
        maxValue: maxValue,
      ),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      key: ValueKey<String>('$fieldId-ayah-wheel-field'),
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                  Text(
                    '$value',
                    key: ValueKey<String>('ayah-value-$title'),
                    textDirection: TextDirection.ltr,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AyahRangeWheelSheet extends StatefulWidget {
  const _AyahRangeWheelSheet({
    required this.title,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
  });

  final String title;
  final int initialValue;
  final int minValue;
  final int maxValue;

  @override
  State<_AyahRangeWheelSheet> createState() => _AyahRangeWheelSheetState();
}

class _AyahRangeWheelSheetState extends State<_AyahRangeWheelSheet> {
  late int _selectedValue;
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _controller = FixedExtentScrollController(
      initialItem: _selectedValue - widget.minValue,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Container(
          key: const Key('reminder-ayah-wheel'),
          height: 210,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: CupertinoPicker.builder(
            scrollController: _controller,
            itemExtent: 44,
            useMagnifier: true,
            magnification: 1.12,
            squeeze: 1.05,
            selectionOverlay: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            onSelectedItemChanged: (index) =>
                setState(() => _selectedValue = widget.minValue + index),
            childCount: widget.maxValue - widget.minValue + 1,
            itemBuilder: (context, index) => Center(
              child: Text(
                '${widget.minValue + index}',
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_selectedValue),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ReminderTimePicker extends StatefulWidget {
  const _ReminderTimePicker({required this.initialTime, required this.strings});

  final TimeOfDay initialTime;
  final AppStrings strings;

  @override
  State<_ReminderTimePicker> createState() => _ReminderTimePickerState();
}

class _ReminderTimePickerState extends State<_ReminderTimePicker> {
  late int _hour12;
  late int _minute;
  late bool _isMorning;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hour12 = hour12From24Hour(widget.initialTime.hour);
    _minute = widget.initialTime.minute;
    _isMorning = widget.initialTime.hour < 12;
    _hourController = FixedExtentScrollController(initialItem: _hour12 - 1);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.strings.reminderTime,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Container(
          height: 210,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TimeWheel(
                  label: widget.strings.hourLabel,
                  controller: _hourController,
                  itemCount: 12,
                  labelFor: (index) => '${index + 1}',
                  onSelectedItemChanged: (index) =>
                      setState(() => _hour12 = index + 1),
                ),
              ),
              Container(
                width: 1,
                height: 156,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Expanded(
                child: _TimeWheel(
                  label: widget.strings.minuteLabel,
                  controller: _minuteController,
                  itemCount: 60,
                  labelFor: (index) => index.toString().padLeft(2, '0'),
                  onSelectedItemChanged: (index) =>
                      setState(() => _minute = index),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment<bool>(
              value: true,
              icon: const Icon(Icons.light_mode_outlined),
              label: Text(widget.strings.morning),
            ),
            ButtonSegment<bool>(
              value: false,
              icon: const Icon(Icons.nights_stay_outlined),
              label: Text(widget.strings.evening),
            ),
          ],
          selected: <bool>{_isMorning},
          onSelectionChanged: (value) =>
              setState(() => _isMorning = value.single),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            TimeOfDay(
              hour: hour24From12Hour(hour12: _hour12, isMorning: _isMorning),
              minute: _minute,
            ),
          ),
          child: Text(widget.strings.confirmTime),
        ),
      ],
    ),
  );
}

class _TimeWheel extends StatelessWidget {
  const _TimeWheel({
    required this.label,
    required this.controller,
    required this.itemCount,
    required this.labelFor,
    required this.onSelectedItemChanged,
  });

  final String label;
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) labelFor;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 4),
      Expanded(
        child: CupertinoPicker.builder(
          scrollController: controller,
          itemExtent: 44,
          useMagnifier: true,
          magnification: 1.12,
          squeeze: 1.05,
          selectionOverlay: Container(
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Theme.of(context).colorScheme.primary
                      .withValues(alpha: 0.7),
                  width: 1.5,
                ),
              ),
            ),
          ),
          onSelectedItemChanged: onSelectedItemChanged,
          childCount: itemCount,
          itemBuilder: (context, index) => Center(
            child: Text(
              labelFor(index),
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    ],
  );
}
