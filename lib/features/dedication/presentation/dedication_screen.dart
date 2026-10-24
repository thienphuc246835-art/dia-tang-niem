import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/common.dart';
import '../data/dedication_controller.dart';
import '../domain/dedication_models.dart';

class DedicationScreen extends ConsumerWidget {
  const DedicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final state = ref.watch(dedicationProvider);
    final alive = state.persons.where((x) => !x.isDeceased).toList();
    final deceased = state.persons.where((x) => x.isDeceased).toList();
    final now = DateTime.now();

    Widget personTile(Person person) {
      final day = person.deathDate == null
          ? null
          : memorialDay(person.deathDate!, now);
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.m),
        title: Text(person.displayName),
        subtitle: day != null
            ? Text(
                '${S.inMemorialPeriod} · ngày $day/49',
                style: TextStyle(color: p.accentSoft),
              )
            : (person.deathDate != null
                  ? Text('Mất ${formatDate(person.deathDate!)}')
                  : null),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/hoi-huong/nguoi/${person.id}'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(S.tabDedication)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/hoi-huong/them'),
        icon: const Icon(Icons.person_add_alt),
        label: const Text(S.personAdd),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          if (state.persons.isEmpty) const EmptyNote(S.personsEmpty),
          if (alive.isNotEmpty) ...[
            const SectionLabel(S.groupAlive),
            for (final person in alive) personTile(person),
          ],
          if (deceased.isNotEmpty) ...[
            const SectionLabel(S.groupDeceased),
            for (final person in deceased) personTile(person),
          ],
          const SectionLabel(S.dedicationLog),
          if (state.log.isEmpty) const EmptyNote(S.dedicationLogEmpty),
          for (final d in state.log.take(50))
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: Space.m),
              title: Text(d.summary, style: const TextStyle(fontSize: 15)),
              subtitle: Text(
                '${formatDateTime(d.createdAt)}\n${S.dedicateFor}: ${_recipients(d, state)}',
                style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.5),
              ),
              isThreeLine: true,
            ),
        ],
      ),
    );
  }

  static String _recipients(Dedication d, DedicationState state) => [
    for (final id in d.personIds)
      state.person(id)?.displayName ?? S.removedPerson,
    if (d.toDharmaRealm) S.dharmaRealm,
  ].join(', ');
}
