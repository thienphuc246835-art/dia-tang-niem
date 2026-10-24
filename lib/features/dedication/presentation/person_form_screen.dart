import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/local_store.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/lunar_calendar.dart';
import '../data/dedication_controller.dart';
import '../domain/dedication_models.dart';

const _relationSuggestions = [
  'Cha',
  'Mẹ',
  'Ông nội',
  'Bà nội',
  'Ông ngoại',
  'Bà ngoại',
  'Vợ',
  'Chồng',
  'Con',
  'Anh',
  'Chị',
  'Em',
  'Bạn',
  'Thầy',
  'Oan gia trái chủ',
];

class PersonFormScreen extends ConsumerStatefulWidget {
  const PersonFormScreen({super.key, this.personId});

  final String? personId;

  @override
  ConsumerState<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends ConsumerState<PersonFormScreen> {
  final _form = GlobalKey<FormState>();
  late final Person? _existing = widget.personId == null
      ? null
      : ref.read(dedicationProvider).person(widget.personId!);
  late final _name = TextEditingController(text: _existing?.name);
  late final _dharma = TextEditingController(text: _existing?.dharmaName);
  late final _relation = TextEditingController(text: _existing?.relation);
  late final _note = TextEditingController(text: _existing?.note);
  late PersonStatus _status = _existing?.status ?? PersonStatus.alive;
  late DateTime? _deathDate = _existing?.deathDate;

  @override
  void dispose() {
    for (final c in [_name, _dharma, _relation, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deathDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: S.deathDate,
    );
    if (picked != null) setState(() => _deathDate = picked);
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    String? clean(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    final person = Person(
      id: _existing?.id ?? newId(),
      name: _name.text.trim(),
      dharmaName: clean(_dharma),
      relation: _relation.text.trim(),
      status: _status,
      deathDate: _status == PersonStatus.deceased ? _deathDate : null,
      note: clean(_note),
    );
    ref.read(dedicationProvider.notifier).savePerson(person);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final lunar = _deathDate == null
        ? null
        : LunarCalendar.fromSolar(_deathDate!);
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? S.personAdd : S.personEdit),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(Space.m),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: S.personName),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Xin nhập họ tên' : null,
            ),
            const SizedBox(height: Space.m),
            TextFormField(
              controller: _dharma,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: S.personDharmaName),
            ),
            const SizedBox(height: Space.m),
            TextFormField(
              controller: _relation,
              decoration: const InputDecoration(labelText: S.personRelation),
            ),
            const SizedBox(height: Space.s),
            Wrap(
              spacing: Space.s,
              runSpacing: Space.xs,
              children: [
                for (final r in _relationSuggestions)
                  ActionChip(
                    label: Text(r),
                    onPressed: () => setState(() => _relation.text = r),
                  ),
              ],
            ),
            const SizedBox(height: Space.l),
            SegmentedButton<PersonStatus>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: PersonStatus.alive, label: Text(S.alive)),
                ButtonSegment(
                  value: PersonStatus.deceased,
                  label: Text(S.deceased),
                ),
              ],
              selected: {_status},
              onSelectionChanged: (v) => setState(() => _status = v.first),
            ),
            if (_status == PersonStatus.deceased) ...[
              const SizedBox(height: Space.m),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(
                  _deathDate == null ? S.deathDate : formatDate(_deathDate!),
                ),
                subtitle: lunar == null
                    ? null
                    : Text(
                        'Âm lịch: ${lunar.day}/${lunar.month}${lunar.isLeap ? ' (${S.leap})' : ''} năm ${lunar.yearName}',
                      ),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text(S.chooseDate),
                ),
              ),
            ],
            const SizedBox(height: Space.m),
            TextFormField(
              controller: _note,
              maxLines: 3,
              decoration: const InputDecoration(labelText: S.personNote),
            ),
            const SizedBox(height: Space.l),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text(S.save),
            ),
            const SizedBox(height: Space.m),
            Text(
              S.privacyNote,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
