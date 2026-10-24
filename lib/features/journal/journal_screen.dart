import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/dates.dart';
import '../../core/widgets/common.dart';
import '../chant/data/chant_controller.dart';
import '../chant/domain/chant_models.dart';
import '../sutra/data/reading_controller.dart';

/// Private practice journal — for oneself only, no comparisons (CLAUDE.md principle 3).
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final chant = ref.watch(chantProvider);
    final recitations = ref.watch(readingProvider).recitations;
    final today = dateOnly(DateTime.now());
    final week = [
      for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i)),
    ];
    final weekCounts = [for (final d in week) chant.daily[dayKey(d)] ?? 0];
    final maxCount = math.max(1, weekCounts.fold<int>(0, math.max));
    var month = 0;
    for (var i = 0; i < 30; i++) {
      month += chant.daily[dayKey(today.subtract(Duration(days: i)))] ?? 0;
    }

    Widget stat(String label, String value) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontFamily: Fonts.serif),
          ),
          const SizedBox(height: Space.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: p.textMuted),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text(S.journal)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.xl),
        children: [
          const SizedBox(height: Space.m),
          Row(
            children: [
              stat(S.today, formatCount(chant.todayCount(today))),
              stat(S.last30Days, formatCount(month)),
              stat(S.lifetime, formatCount(chant.lifetime)),
            ],
          ),
          const SizedBox(height: Space.l),
          Row(
            children: [
              stat(S.streak, '${streakDays(chant.daily, today)}'),
              stat(S.recitations, '${recitations.length}'),
              stat('Thời niệm', '${chant.sessions.length}'),
            ],
          ),
          const SectionLabel(S.last7Days),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.m),
            child: SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: Semantics(
                        label:
                            '${formatDate(week[i])}: ${weekCounts[i]} ${S.unitBien}',
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (weekCounts[i] > 0)
                              Text(
                                formatCount(weekCounts[i]),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: p.textMuted,
                                ),
                              ),
                            const SizedBox(height: Space.xs),
                            Container(
                              height: 100 * weekCounts[i] / maxCount + 2,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: i == 6
                                    ? p.accent
                                    : p.accent.withValues(alpha: 0.45),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(height: Space.xs),
                            Text(
                              S.weekdays[week[i].weekday - 1],
                              style: TextStyle(
                                fontSize: 12,
                                color: p.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SectionLabel(S.recitations),
          if (recitations.isEmpty) const EmptyNote(S.recitationsEmpty),
          for (final r in recitations.take(20))
            ListTile(
              leading: Icon(Icons.auto_stories_outlined, color: p.accentSoft),
              title: Text(scopeLabel(r.scope)),
              subtitle: Text(
                '${formatDateTime(r.date)} · ${formatDuration(r.duration)}',
              ),
            ),
          const SectionLabel('Thời niệm gần đây'),
          if (chant.sessions.isEmpty)
            const EmptyNote('Chưa có thời niệm nào được hoàn tất.'),
          for (final s in chant.sessions.take(20))
            ListTile(
              leading: Icon(Icons.spa_outlined, color: p.accent),
              title: Text('${formatCount(s.count)} ${S.unitBien}'),
              subtitle: Text(
                '${formatDateTime(s.end)} · ${formatDuration(s.duration)}',
              ),
            ),
        ],
      ),
    );
  }
}
