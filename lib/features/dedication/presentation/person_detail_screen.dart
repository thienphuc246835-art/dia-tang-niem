import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/lunar_calendar.dart';
import '../../../core/widgets/common.dart';
import '../data/dedication_controller.dart';
import '../domain/dedication_models.dart';

/// Kinh văn shown with the 49-day timeline (Phẩm 7, đoạn 3).
const _memorialQuoteId = 'q2.p7.s3.b7';

class PersonDetailScreen extends ConsumerWidget {
  const PersonDetailScreen({super.key, required this.personId});

  final String personId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDialog(
      context,
      title: S.deletePersonTitle,
      body: S.deletePersonBody,
      confirmLabel: S.delete,
    );
    if (!ok || !context.mounted) return;
    ref.read(dedicationProvider.notifier).deletePerson(personId);
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final state = ref.watch(dedicationProvider);
    final person = state.person(personId);
    if (person == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyNote(S.removedPerson));
    }

    final now = DateTime.now();
    final death = person.deathDate;
    final lunar = death == null ? null : LunarCalendar.fromSolar(death);
    final count = state.log
        .where((d) => d.personIds.contains(person.id))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
        actions: [
          IconButton(
            tooltip: S.personEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/hoi-huong/nguoi/${person.id}/sua'),
          ),
          IconButton(
            tooltip: S.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.xl),
        children: [
          ListTile(
            title: Text(person.displayName),
            subtitle: Text(person.isDeceased ? S.deceased : S.alive),
          ),
          if (death != null)
            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: Text('Mất ngày ${formatDate(death)}'),
              subtitle: Text(
                'Âm lịch ${lunar!.day}/${lunar.month}${lunar.isLeap ? ' ${S.leap}' : ''} năm ${lunar.yearName}'
                ' · giỗ hằng năm ngày ${lunar.day}/${lunar.month} âm lịch',
              ),
            ),
          if (person.note != null)
            ListTile(
              leading: const Icon(Icons.notes),
              title: Text(person.note!),
            ),
          ListTile(
            leading: const Icon(Icons.spa_outlined),
            title: Text('Đã hồi hướng $count lần'),
          ),
          if (death != null && person.isDeceased) ...[
            const SectionLabel(S.memorial49),
            SutraBuilder(
              builder: (context, sutra) {
                final quote = sutra.block(_memorialQuoteId);
                if (quote == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.m),
                  child: Column(
                    children: [
                      Text(
                        '“${quote.text}”',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: Space.xs),
                      Text(
                        'Kinh Địa Tạng · Phẩm 7',
                        style: TextStyle(fontSize: 13, color: p.textMuted),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.go('/kinh/doc?at=$_memorialQuoteId'),
                        child: const Text('Đọc trong Kinh'),
                      ),
                    ],
                  ),
                );
              },
            ),
            for (final w in memorialWeeks(death))
              _WeekTile(week: w, today: dateOnly(now)),
            Padding(
              padding: const EdgeInsets.all(Space.m),
              child: Text(
                S.memorialRule,
                style: TextStyle(fontSize: 13, color: p.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeekTile extends StatelessWidget {
  const _WeekTile({required this.week, required this.today});

  final MemorialWeek week;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final lunar = LunarCalendar.fromSolar(week.date);
    final isToday = week.date == today;
    final passed = week.date.isBefore(today);
    return ListTile(
      leading: Icon(
        passed
            ? Icons.check_circle_outline
            : (isToday
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked),
        color: isToday ? p.accent : (passed ? p.accentSoft : p.textMuted),
      ),
      title: Text(
        week.week == 7
            ? S.memorialFinal
            : '${S.memorialWeek} ${week.week} (ngày ${week.week * 7})',
      ),
      subtitle: Text(
        '${formatDate(week.date)} · âm lịch ${lunar.day}/${lunar.month}${isToday ? ' · hôm nay' : ''}',
      ),
    );
  }
}
