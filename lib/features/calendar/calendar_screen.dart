import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/lunar_calendar.dart';
import '../../core/widgets/common.dart';
import '../dedication/data/dedication_controller.dart';
import '../dedication/domain/dedication_models.dart';

/// Month view with lunar dates, Thập Trai days (Phẩm 6), vía Địa Tạng and family anniversaries.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _selected = dateOnly(DateTime.now());

  void _shift(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  List<Person> _anniversaries(List<Person> persons, LunarDate lunar) => [
    for (final person in persons)
      if (person.isDeceased && person.deathDate != null)
        if (LunarCalendar.fromSolar(person.deathDate!) case final d
            when d.day == lunar.day && d.month == lunar.month && !lunar.isLeap)
          person,
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final persons = ref.watch(dedicationProvider).persons;
    final today = dateOnly(DateTime.now());
    final first = _month;
    final leading = first.weekday - 1; // Monday first
    final daysInMonth = DateUtils.getDaysInMonth(first.year, first.month);
    final cells = ((leading + daysInMonth) / 7).ceil() * 7;
    final midLunar = LunarCalendar.fromSolar(
      DateTime(first.year, first.month, 15),
    );

    final selectedLunar = LunarCalendar.fromSolar(_selected);
    final selectedAnniversaries = _anniversaries(persons, selectedLunar);

    return Scaffold(
      appBar: AppBar(title: const Text(S.calendar)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Space.m),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _shift(-1),
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Tháng trước',
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Tháng ${first.month} / ${first.year}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Năm ${midLunar.yearName}',
                      style: TextStyle(fontSize: 13, color: p.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _shift(1),
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Tháng sau',
              ),
            ],
          ),
          const SizedBox(height: Space.s),
          Row(
            children: [
              for (final w in S.weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: TextStyle(fontSize: 13, color: p.textMuted),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.xs),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.78,
            ),
            itemCount: cells,
            itemBuilder: (context, i) {
              final dayNum = i - leading + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox.shrink();
              }
              final date = DateTime(first.year, first.month, dayNum);
              final lunar = LunarCalendar.fromSolar(date);
              return _DayCell(
                date: date,
                lunar: lunar,
                isToday: date == today,
                isSelected: date == _selected,
                hasAnniversary: _anniversaries(persons, lunar).isNotEmpty,
                onTap: () => setState(() => _selected = date),
              );
            },
          ),
          const SizedBox(height: Space.m),
          _Legend(palette: p),
          const QuietDivider(),
          Text(
            '${formatDate(_selected)} · âm lịch ${selectedLunar.day}/${selectedLunar.month}'
            '${selectedLunar.isLeap ? ' (${S.leap})' : ''} năm ${selectedLunar.yearName}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Space.s),
          Text(
            'Tháng ${selectedLunar.monthLength == 30 ? 'đủ (30 ngày)' : 'thiếu (29 ngày)'}',
            style: TextStyle(fontSize: 14, color: p.textMuted),
          ),
          const SizedBox(height: Space.s),
          if (selectedLunar.day == 1)
            _Note(icon: Icons.brightness_3_outlined, text: S.mungMot),
          if (selectedLunar.day == 15)
            _Note(icon: Icons.brightness_1_outlined, text: S.ram),
          if (isThapTrai(selectedLunar))
            _Note(
              icon: Icons.circle,
              text: '${S.thapTrai} — Kinh Địa Tạng, Phẩm 6',
              color: p.accent,
            ),
          if (isViaDiaTang(selectedLunar)) ...[
            _Note(
              icon: Icons.radio_button_checked,
              text: S.viaDiaTang,
              color: p.accent,
            ),
            Text(S.viaNote, style: TextStyle(fontSize: 13, color: p.textMuted)),
          ],
          for (final person in selectedAnniversaries)
            _Note(
              icon: Icons.local_florist_outlined,
              text: '${S.anniversary}: ${person.displayName}',
              color: p.accentSoft,
            ),
          if (selectedLunar.monthLength == 29 && selectedLunar.day == 29)
            Padding(
              padding: const EdgeInsets.only(top: Space.s),
              child: Text(
                S.shortMonthNote,
                style: TextStyle(fontSize: 13, color: p.textMuted),
              ),
            ),
          const SizedBox(height: Space.xl),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.lunar,
    required this.isToday,
    required this.isSelected,
    required this.hasAnniversary,
    required this.onTap,
  });

  final DateTime date;
  final LunarDate lunar;
  final bool isToday;
  final bool isSelected;
  final bool hasAnniversary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final special = lunar.day == 1 || lunar.day == 15;
    final via = isViaDiaTang(lunar);
    return Semantics(
      button: true,
      label: '${formatDate(date)}, âm lịch ${lunar.day} tháng ${lunar.month}',
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? p.accent.withValues(alpha: 0.12) : null,
            border: Border.all(
              color: via
                  ? p.accent
                  : (isToday ? p.textMuted : Colors.transparent),
              width: via ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(fontSize: 17, color: p.text),
              ),
              Text(
                lunar.day == 1 ? '${lunar.day}/${lunar.month}' : '${lunar.day}',
                style: TextStyle(
                  fontSize: 11,
                  color: special ? p.accent : p.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isThapTrai(lunar)) _Dot(color: p.accent),
                  if (hasAnniversary) _Dot(color: p.accentSoft),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 5,
    height: 5,
    margin: const EdgeInsets.symmetric(horizontal: 1.5),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.palette});
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 13, color: palette.textMuted);
    return Wrap(
      spacing: Space.m,
      runSpacing: Space.xs,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(color: palette.accent),
            const SizedBox(width: 4),
            Text(S.thapTrai, style: style),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(color: palette.accentSoft),
            const SizedBox(width: 4),
            Text(S.anniversary, style: style),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: palette.accent, width: 1.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Text('Vía Đức Địa Tạng', style: style),
          ],
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Space.xs),
    child: Row(
      children: [
        Icon(icon, size: 14, color: color ?? context.palette.textMuted),
        const SizedBox(width: Space.s),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
