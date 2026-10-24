import 'package:flutter/material.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../domain/sutra_models.dart';

/// Three-level contents: part → chapter → numbered section. Calls [onSelect] with an anchor id.
class TableOfContents extends StatelessWidget {
  const TableOfContents({
    super.key,
    required this.sutra,
    required this.onSelect,
    this.shrinkWrap = false,
    this.controller,
  });

  final Sutra sutra;
  final ValueChanged<String> onSelect;
  final bool shrinkWrap;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final muted = TextStyle(color: p.textMuted, fontSize: 14);

    Widget sectionTile(SutraSection s, {double indent = Space.l}) => ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(left: indent, right: Space.m),
      title: Text(s.label, style: const TextStyle(fontSize: 15)),
      onTap: () => onSelect(s.id),
    );

    Widget rite(SutraRite r) => ExpansionTile(
      shape: const Border(),
      title: Text(r.title, style: const TextStyle(fontSize: 17)),
      subtitle: Text('${r.sections.length} phần', style: muted),
      children: [for (final s in r.sections) sectionTile(s)],
    );

    return ListView(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      children: [
        rite(sutra.opening),
        for (final v in sutra.volumes)
          ExpansionTile(
            shape: const Border(),
            title: Text(v.title, style: const TextStyle(fontSize: 17)),
            subtitle: Text(
              '${S.chapter} ${v.chapters.first.number}–${v.chapters.last.number}',
              style: muted,
            ),
            children: [
              for (final c in v.chapters)
                c.sections.any((s) => s.title != null)
                    ? ExpansionTile(
                        shape: const Border(),
                        tilePadding: const EdgeInsets.only(
                          left: Space.l,
                          right: Space.m,
                        ),
                        title: _ChapterTitle(chapter: c),
                        children: [
                          ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.only(
                              left: Space.xl,
                              right: Space.m,
                            ),
                            title: Text('Đầu phẩm', style: muted),
                            onTap: () => onSelect(c.id),
                          ),
                          for (final s in c.sections.where(
                            (s) => s.title != null,
                          ))
                            sectionTile(s, indent: Space.xl),
                        ],
                      )
                    : ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: Space.l,
                          right: Space.m,
                        ),
                        title: _ChapterTitle(chapter: c),
                        onTap: () => onSelect(c.id),
                      ),
            ],
          ),
        rite(sutra.closing),
      ],
    );
  }
}

class _ChapterTitle extends StatelessWidget {
  const _ChapterTitle({required this.chapter});

  final SutraChapter chapter;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${S.chapter} ${chapter.number}',
        style: TextStyle(fontSize: 13, color: context.palette.accent),
      ),
      Text(
        chapter.title,
        style: const TextStyle(fontSize: 15, letterSpacing: 0.3),
      ),
    ],
  );
}
