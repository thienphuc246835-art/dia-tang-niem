import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/common.dart';
import '../data/reading_controller.dart';
import '../domain/reader_document.dart';
import 'table_of_contents.dart';

class SutraHomeScreen extends ConsumerWidget {
  const SutraHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final reading = ref.watch(readingProvider);
    final next = reading.nextRitualVolume;
    final last = reading.recitations.firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kinh Địa Tạng'),
        actions: [
          IconButton(
            tooltip: S.search,
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/kinh/tim'),
          ),
          IconButton(
            tooltip: S.bookmarks,
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => context.go('/kinh/danh-dau'),
          ),
        ],
      ),
      body: SutraBuilder(
        builder: (context, sutra) => ListView(
          padding: const EdgeInsets.only(bottom: Space.xl),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.m, Space.s, Space.m, 0),
              child: Column(
                children: [
                  Text(
                    sutra.meta.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    'Việt dịch: ${sutra.meta.translatorVi}',
                    style: TextStyle(color: p.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (reading.lastAnchor != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.m,
                  Space.l,
                  Space.m,
                  0,
                ),
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.auto_stories_outlined, color: p.accent),
                    title: const Text(S.continueReading),
                    subtitle: Text(_anchorLabel(reading.lastAnchor!)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/kinh/doc'),
                  ),
                ),
              ),
            const SectionLabel(S.ritualTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.m),
              child: Text(
                S.ritualHint,
                style: TextStyle(color: p.textMuted, fontSize: 14, height: 1.5),
              ),
            ),
            if (last != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.m,
                  Space.s,
                  Space.m,
                  0,
                ),
                child: Text(
                  '${S.ritualNext}: ${scopeLabel(last.scope)} · ${formatDate(last.date)}',
                  style: TextStyle(color: p.accentSoft, fontSize: 14),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.m, Space.m, Space.m, 0),
              child: Wrap(
                spacing: Space.s,
                runSpacing: Space.s,
                children: [
                  for (final v in volumeIds)
                    _RitualButton(
                      label: scopeLabel(v),
                      suggested: v == next,
                      onTap: () => context.go('/kinh/doc?ritual=$v'),
                    ),
                  _RitualButton(
                    label: S.ritualFull,
                    suggested: false,
                    onTap: () => context.go('/kinh/doc?ritual=all'),
                  ),
                ],
              ),
            ),
            const SectionLabel(S.tableOfContents),
            TableOfContents(
              sutra: sutra,
              shrinkWrap: true,
              onSelect: (id) =>
                  context.go('/kinh/doc?at=${Uri.encodeQueryComponent(id)}'),
            ),
            const SizedBox(height: Space.m),
            Center(
              child: TextButton(
                onPressed: () => context.go('/them/nguon-kinh'),
                child: const Text(S.sutraSource),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "q2.p7.s3.b5" → "Quyển Trung · Phẩm 7"
  static String _anchorLabel(String anchor) {
    final parts = anchor.split('.');
    final head = switch (parts.first) {
      'kk' => 'Khai Kinh',
      'kt' => 'Kết Kinh',
      final v => scopeLabel(v),
    };
    final chapter = parts.length > 1 && parts[1].startsWith('p')
        ? ' · ${S.chapter} ${parts[1].substring(1)}'
        : '';
    return '$head$chapter';
  }
}

class _RitualButton extends StatelessWidget {
  const _RitualButton({
    required this.label,
    required this.suggested,
    required this.onTap,
  });

  final String label;
  final bool suggested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => suggested
      ? FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          child: Text(label),
        )
      : OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
          child: Text(label),
        );
}
