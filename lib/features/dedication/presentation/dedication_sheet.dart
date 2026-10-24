import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../data/dedication_controller.dart';
import '../domain/dedication_models.dart';

/// Shown after a sitting or a recitation. The verse is read from Kết Kinh, never typed here.
Future<void> showDedicationSheet(
  BuildContext context,
  DedicationSource source, {
  List<String> preselected = const [],
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => DedicationSheet(source: source, preselected: preselected),
);

class DedicationSheet extends ConsumerStatefulWidget {
  const DedicationSheet({
    super.key,
    required this.source,
    this.preselected = const [],
  });

  final DedicationSource source;
  final List<String> preselected;

  @override
  ConsumerState<DedicationSheet> createState() => _DedicationSheetState();
}

class _DedicationSheetState extends ConsumerState<DedicationSheet> {
  late final Set<String> _selected = {...widget.preselected};
  late bool _dharmaRealm = widget.preselected.isEmpty;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final persons = ref.watch(dedicationProvider).persons;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, controller) => SutraBuilder(
        builder: (context, sutra) {
          final verse = sutra.dedicationVerse;
          return ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.xl),
            children: [
              Text(
                S.dedicate,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Space.s),
              Text(
                widget.source.summary,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textMuted),
              ),
              const SectionLabel(
                S.dedicateFor,
                padding: EdgeInsets.only(top: Space.l, bottom: Space.s),
              ),
              for (final person in persons)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _selected.contains(person.id),
                  onChanged: (v) => setState(
                    () => v!
                        ? _selected.add(person.id)
                        : _selected.remove(person.id),
                  ),
                  title: Text(person.displayName),
                  subtitle: Text(
                    person.isDeceased ? S.groupDeceased : S.groupAlive,
                  ),
                ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _dharmaRealm,
                onChanged: (v) => setState(() => _dharmaRealm = v!),
                title: const Text(S.dharmaRealm),
              ),
              if (persons.isEmpty)
                Text(
                  S.personsEmpty,
                  style: TextStyle(color: p.textMuted, fontSize: 14),
                ),
              const QuietDivider(),
              VerseText(verse.blocks.map((b) => b.text).join('\n')),
              const SizedBox(height: Space.s),
              Text(
                'Kết Kinh · ${verse.title}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: p.textMuted),
              ),
              const SizedBox(height: Space.l),
              FilledButton(
                onPressed: _selected.isEmpty && !_dharmaRealm
                    ? null
                    : () => _submit(verse.id),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text(S.dedicate, style: TextStyle(fontSize: 17)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(S.dedicateLater),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submit(String verseId) {
    ref
        .read(dedicationProvider.notifier)
        .dedicate(
          source: widget.source,
          personIds: _selected.toList(),
          toDharmaRealm: _dharmaRealm,
          verseId: verseId,
        );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text(S.dedicationDone),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
