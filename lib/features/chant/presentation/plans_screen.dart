import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/common.dart';
import '../../dedication/data/dedication_controller.dart';
import '../../dedication/domain/dedication_models.dart';
import '../../dedication/presentation/dedication_sheet.dart';
import '../data/chant_controller.dart';
import '../domain/chant_models.dart';

/// Passages behind the multi-day practice (CLAUDE.md section 10).
const _planQuotes = [('q2.p6.s10.b2', 'Phẩm 6'), ('q3.p12.s6.b6', 'Phẩm 12')];

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final chant = ref.watch(chantProvider);
    final now = DateTime.now();
    final active = chant.activePlan(now);
    final past = chant.plans.where((x) => x != active).toList();

    return Scaffold(
      appBar: AppBar(title: const Text(S.plans)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.xl),
        children: [
          SutraBuilder(
            builder: (context, sutra) => Padding(
              padding: const EdgeInsets.fromLTRB(Space.m, Space.s, Space.m, 0),
              child: Column(
                children: [
                  for (final (id, where) in _planQuotes)
                    if (sutra.block(id) case final block?)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Space.m),
                        child: Column(
                          children: [
                            Text(
                              '“${block.text}”',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                height: 1.6,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: Space.xs),
                            Text(
                              'Kinh Địa Tạng · $where',
                              style: TextStyle(
                                fontSize: 13,
                                color: p.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ),
          if (active != null) ...[
            const SectionLabel(S.planActive),
            _PlanCard(plan: active, daily: chant.daily, active: true),
          ] else
            Padding(
              padding: const EdgeInsets.all(Space.m),
              child: FilledButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => const _NewPlanSheet(),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.add),
                label: const Text(S.planNew),
              ),
            ),
          if (past.isNotEmpty) ...[
            const SectionLabel('Đã qua'),
            for (final plan in past)
              _PlanCard(plan: plan, daily: chant.daily, active: false),
          ],
        ],
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({
    required this.plan,
    required this.daily,
    required this.active,
  });

  final ChantPlan plan;
  final Map<String, int> daily;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final progress = plan.progress(daily);
    final done = progress >= plan.target;
    final persons = ref.watch(dedicationProvider);
    final names = [
      for (final id in plan.personIds)
        persons.person(id)?.displayName ?? S.removedPerson,
    ];
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.m,
        vertical: Space.s,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Space.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${formatCount(plan.target)} ${S.unitBien} · ${plan.days} ngày',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Space.xs),
              Text(
                '${formatDate(plan.startDate)} – ${formatDate(plan.lastDate)}',
                style: TextStyle(color: p.textMuted, fontSize: 14),
              ),
              const SizedBox(height: Space.m),
              LinearProgressIndicator(
                value: (progress / plan.target).clamp(0, 1),
                minHeight: 3,
                backgroundColor: p.border,
                color: done ? p.accentSoft : p.accent,
              ),
              const SizedBox(height: Space.s),
              Text(
                '${formatCount(progress)} / ${formatCount(plan.target)}'
                '${active ? ' · ngày ${plan.dayNumber(now)}/${plan.days} · mỗi ngày khoảng ${formatCount(plan.dailyTarget)}' : ''}'
                '${done ? ' · ${S.planDone}' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: done ? p.accentSoft : p.text,
                ),
              ),
              if (names.isNotEmpty) ...[
                const SizedBox(height: Space.s),
                Text(
                  '${S.planPersons}: ${names.join(', ')}',
                  style: TextStyle(fontSize: 14, color: p.textMuted),
                ),
              ],
              if (active || done)
                Padding(
                  padding: const EdgeInsets.only(top: Space.s),
                  child: Wrap(
                    spacing: Space.s,
                    children: [
                      if (done)
                        TextButton(
                          onPressed: () => showDedicationSheet(
                            context,
                            DedicationSource(
                              type: DedicationSourceType.plan,
                              sourceId: plan.id,
                              summary:
                                  'Thời khoá ${formatCount(progress)} ${S.unitBien} trong ${plan.days} ngày',
                            ),
                            preselected: plan.personIds,
                          ),
                          child: const Text(S.dedicate),
                        ),
                      if (active)
                        TextButton(
                          onPressed: () async {
                            final ok = await confirmDialog(
                              context,
                              title: '${S.planEnd}?',
                              body: 'Thời khoá sẽ dừng lại; số biến đã niệm vẫn được giữ.',
                            );
                            if (ok) {
                              ref.read(chantProvider.notifier).endPlan(plan.id);
                            }
                          },
                          child: const Text(S.planEnd),
                        ),
                      if (active)
                        TextButton(
                          onPressed: () => context.go('/niem'),
                          child: const Text('Về màn hình Niệm'),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewPlanSheet extends ConsumerStatefulWidget {
  const _NewPlanSheet();

  @override
  ConsumerState<_NewPlanSheet> createState() => _NewPlanSheetState();
}

class _NewPlanSheetState extends ConsumerState<_NewPlanSheet> {
  int _target = 10000;
  int _days = 7;
  final _persons = <String>{};

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final persons = ref.watch(dedicationProvider).persons;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l),
      children: [
        Text(
          S.planNew,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SectionLabel(
          S.planTarget,
          padding: EdgeInsets.only(top: Space.l, bottom: Space.s),
        ),
        Wrap(
          spacing: Space.s,
          children: [
            for (final t in [1080, 10000, 21000, 108000])
              ChoiceChip(
                label: Text(formatCount(t)),
                selected: _target == t,
                onSelected: (_) => setState(() => _target = t),
              ),
          ],
        ),
        const SectionLabel(
          S.planDays,
          padding: EdgeInsets.only(top: Space.l, bottom: Space.s),
        ),
        Wrap(
          spacing: Space.s,
          children: [
            for (final d in [1, 7, 21, 49])
              ChoiceChip(
                label: Text('$d ngày'),
                selected: _days == d,
                onSelected: (_) => setState(() => _days = d),
              ),
          ],
        ),
        const SizedBox(height: Space.s),
        Text(
          'Mỗi ngày khoảng ${formatCount((_target / _days).ceil())} ${S.unitBien}',
          style: TextStyle(color: p.textMuted, fontSize: 14),
        ),
        if (persons.isNotEmpty) ...[
          const SectionLabel(
            S.planPersons,
            padding: EdgeInsets.only(top: Space.l, bottom: Space.s),
          ),
          for (final person in persons)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _persons.contains(person.id),
              onChanged: (v) => setState(
                () => v! ? _persons.add(person.id) : _persons.remove(person.id),
              ),
              title: Text(person.displayName),
            ),
        ],
        const SizedBox(height: Space.l),
        FilledButton(
          onPressed: () {
            ref
                .read(chantProvider.notifier)
                .startPlan(
                  target: _target,
                  days: _days,
                  personIds: _persons.toList(),
                );
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: const Text(S.planStart),
        ),
      ],
    );
  }
}
