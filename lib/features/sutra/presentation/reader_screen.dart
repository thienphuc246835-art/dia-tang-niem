import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/common.dart';
import '../../dedication/domain/dedication_models.dart';
import '../../dedication/presentation/dedication_sheet.dart';
import '../../settings/settings_controller.dart';
import '../data/reading_controller.dart';
import '../domain/reader_document.dart';
import '../domain/sutra_models.dart';
import 'table_of_contents.dart';

/// E-reader for the whole book, or for one ritual recitation when [ritual] is set
/// ('q1' | 'q2' | 'q3' | 'all').
class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key, this.ritual, this.anchor});

  final String? ritual;
  final String? anchor;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SutraBuilder(
      builder: (context, sutra) =>
          _Reader(sutra: sutra, ritual: ritual, anchor: anchor),
    ),
  );
}

class _Reader extends ConsumerStatefulWidget {
  const _Reader({required this.sutra, this.ritual, this.anchor});

  final Sutra sutra;
  final String? ritual;
  final String? anchor;

  @override
  ConsumerState<_Reader> createState() => _ReaderState();
}

class _ReaderState extends ConsumerState<_Reader> {
  late final ReaderDocument _doc = buildDocument(
    widget.sutra,
    widget.ritual != null ? ritualParts(widget.ritual!) : allParts,
  );
  final _scroll = ItemScrollController();
  final _positions = ItemPositionsListener.create();
  final _location = ValueNotifier<String>('');
  final _repeatTaps = <String, int>{};
  final _openedAt = DateTime.now();
  late final int _initialIndex;
  int _topIndex = 0;

  bool get _isRitual => widget.ritual != null;

  @override
  void initState() {
    super.initState();
    final target =
        widget.anchor ??
        (_isRitual ? null : ref.read(readingProvider).lastAnchor);
    _initialIndex = target == null ? 0 : (_doc.indexOf(target) ?? 0);
    _topIndex = _initialIndex;
    _location.value = _labelAt(_initialIndex);
    _positions.itemPositions.addListener(_onScroll);
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_onScroll);
    _location.dispose();
    super.dispose();
  }

  void _onScroll() {
    final visible = _positions.itemPositions.value.where(
      (p) => p.itemTrailingEdge > 0.02 && p.index < _doc.items.length,
    );
    if (visible.isEmpty) return;
    final top = visible.reduce((a, b) => a.index < b.index ? a : b).index;
    if (top == _topIndex) return;
    _topIndex = top;
    _location.value = _labelAt(top);
    if (!_isRitual) {
      ref
          .read(readingProvider.notifier)
          .saveLastPosition(_doc.items[top].anchorId);
    }
  }

  String _labelAt(int index) {
    // A section title is labelled by the block that follows it, not the one before.
    final next = index + 1 < _doc.items.length ? _doc.items[index + 1] : null;
    if (_doc.items[index] is SectionTitleItem && next is BlockItem) {
      return next.context;
    }
    for (var i = index; i >= 0; i--) {
      final item = _doc.items[i];
      if (item is BlockItem) return item.context;
      if (item is ChapterTitleItem) {
        return '${S.chapter} ${item.chapter.number}';
      }
      if (item is PartTitleItem) return item.title;
    }
    return '';
  }

  void _jumpTo(String anchorId) {
    final index = _doc.indexOf(anchorId);
    if (index != null) _scroll.jumpTo(index: index);
  }

  /// First text block at or after the top of the screen.
  BlockItem? get _topBlock {
    for (var i = _topIndex; i < _doc.items.length; i++) {
      final item = _doc.items[i];
      if (item is BlockItem) return item;
    }
    return null;
  }

  void _toggleBookmark(BlockItem item) {
    final added = ref
        .read(readingProvider.notifier)
        .toggleBookmark(
          Bookmark(
            blockId: item.block.id,
            label: item.context,
            preview: item.block.text.replaceAll('\n', ' '),
            createdAt: DateTime.now(),
          ),
        );
    showQuietSnack(context, added ? S.bookmarkAdded : S.bookmarkRemoved);
  }

  void _showContents() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (context, controller) => TableOfContents(
          sutra: widget.sutra,
          controller: controller,
          onSelect: (id) {
            Navigator.pop(context);
            if (_doc.indexOf(id) != null) {
              _jumpTo(id);
            } else {
              // Outside this ritual session (e.g. another volume): ignore quietly.
              showQuietSnack(
                this.context,
                'Phần này không thuộc thời tụng hiện tại.',
              );
            }
          },
        ),
      ),
    );
  }

  void _showDisplaySettings() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const _DisplaySettingsSheet(),
    );
  }

  Future<void> _finishRitual() async {
    final scope = widget.ritual!;
    final log = ref
        .read(readingProvider.notifier)
        .logRecitation(scope, DateTime.now().difference(_openedAt));
    await showDedicationSheet(
      context,
      DedicationSource(
        type: DedicationSourceType.recitation,
        sourceId: log.id,
        summary:
            'Tụng Kinh Địa Tạng · ${scopeLabel(scope)} · ${formatDuration(log.duration)}',
      ),
    );
    if (mounted) Navigator.of(context).maybePop();
  }

  Palette _readerPalette(ReaderTheme theme) => switch (theme) {
    ReaderTheme.auto => context.palette,
    ReaderTheme.light => Palette.light,
    ReaderTheme.sepia => Palette.sepia,
    ReaderTheme.dark => Palette.dark,
  };

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final reading = ref.watch(readingProvider);
    final p = _readerPalette(settings.readerTheme);
    final style = _ReaderStyle(
      p,
      settings.readerFontSize,
      settings.readerLineHeight,
    );
    final itemCount = _doc.items.length + (_isRitual ? 1 : 0);

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: p.background,
        extensions: [PaletteExtension(p)],
        appBarTheme: Theme.of(context).appBarTheme
            .copyWith(backgroundColor: p.background, foregroundColor: p.text),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder<String>(
            valueListenable: _location,
            builder: (context, label, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isRitual
                      ? 'Tụng ${scopeLabel(widget.ritual!)}'
                      : 'Kinh Địa Tạng',
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontSize: 17,
                    color: p.text,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontSize: 12,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              tooltip: S.tableOfContents,
              icon: const Icon(Icons.format_list_bulleted),
              onPressed: _showContents,
            ),
            IconButton(
              tooltip: S.bookmarks,
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                final block = _topBlock;
                if (block != null) _toggleBookmark(block);
              },
            ),
            IconButton(
              tooltip: S.readerSettings,
              icon: const Icon(Icons.text_fields),
              onPressed: _showDisplaySettings,
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ScrollablePositionedList.builder(
            itemCount: itemCount,
            initialScrollIndex: _initialIndex,
            itemScrollController: _scroll,
            itemPositionsListener: _positions,
            padding: const EdgeInsets.fromLTRB(
              Space.l,
              Space.s,
              Space.l,
              Space.xl * 2,
            ),
            itemBuilder: (context, index) {
              if (index == _doc.items.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: Space.xl),
                  child: FilledButton(
                    onPressed: _finishRitual,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text(
                      S.finishRecitation,
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                );
              }
              final item = _doc.items[index];
              return switch (item) {
                PartTitleItem() => style.partTitle(
                  item.title,
                  first: index == 0,
                ),
                ChapterTitleItem() => style.chapterTitle(item.chapter),
                SectionTitleItem() => style.sectionTitle(item.label),
                ClosingDividerItem() => Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.l),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: p.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.m,
                        ),
                        child: Icon(
                          Icons.circle_outlined,
                          size: 10,
                          color: p.accent,
                        ),
                      ),
                      Expanded(child: Divider(color: p.border)),
                    ],
                  ),
                ),
                BlockItem() => GestureDetector(
                  onLongPress: () => _toggleBookmark(item),
                  child: style.block(
                    item.block,
                    bookmarked: reading.isBookmarked(item.block.id),
                    repeatTaps: _isRitual
                        ? _repeatTaps[item.block.id] ?? 0
                        : null,
                    onRepeatTap: _isRitual
                        ? () => setState(() {
                            final n = (_repeatTaps[item.block.id] ?? 0) + 1;
                            _repeatTaps[item.block.id] =
                                n > (item.block.repeat ?? 1) ? 0 : n;
                          })
                        : null,
                  ),
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _ReaderStyle {
  _ReaderStyle(this.p, this.fontSize, this.lineHeight);

  final Palette p;
  final double fontSize;
  final double lineHeight;

  TextStyle get _body => TextStyle(
    fontFamily: Fonts.serif,
    fontSize: fontSize,
    height: lineHeight,
    color: p.text,
  );

  Widget partTitle(String title, {required bool first}) => Padding(
    padding: EdgeInsets.only(
      top: first ? Space.l : Space.xl * 1.5,
      bottom: Space.l,
    ),
    child: Column(
      children: [
        Icon(Icons.circle_outlined, size: 14, color: p.accent),
        const SizedBox(height: Space.m),
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontSize: fontSize + 4,
            letterSpacing: 2,
            color: p.text,
          ),
        ),
      ],
    ),
  );

  Widget chapterTitle(SutraChapter c) => Padding(
    padding: const EdgeInsets.only(top: Space.xl, bottom: Space.l),
    child: Column(
      children: [
        Text(
          '${S.chapter.toUpperCase()} ${c.number}',
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontSize: 14,
            letterSpacing: 2,
            color: p.accent,
          ),
        ),
        const SizedBox(height: Space.s),
        Text(
          c.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontSize: fontSize + 1,
            height: 1.4,
            letterSpacing: 0.6,
            color: p.text,
          ),
        ),
      ],
    ),
  );

  Widget sectionTitle(String label) => Padding(
    padding: const EdgeInsets.only(top: Space.l, bottom: Space.s),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: Fonts.serif,
        fontSize: fontSize - 2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: p.text,
      ),
    ),
  );

  Widget block(
    SutraBlock b, {
    required bool bookmarked,
    int? repeatTaps,
    VoidCallback? onRepeatTap,
  }) {
    final Widget text = switch (b.type) {
      BlockType.prose => Text(
        b.text,
        textAlign: TextAlign.justify,
        style: _body,
      ),
      BlockType.listItem => Padding(
        padding: const EdgeInsets.only(left: Space.m),
        child: Text(b.text, style: _body),
      ),
      BlockType.verse => Text(
        b.text,
        textAlign: TextAlign.center,
        style: _body.copyWith(fontStyle: FontStyle.italic),
      ),
      BlockType.mantra => Text(
        b.text,
        textAlign: TextAlign.center,
        style: _body.copyWith(fontStyle: FontStyle.italic),
      ),
      BlockType.invocation => Text(
        b.text,
        textAlign: TextAlign.center,
        style: _body.copyWith(fontWeight: FontWeight.w600),
      ),
      BlockType.heading => Text(
        b.text,
        textAlign: TextAlign.center,
        style: _body.copyWith(
          fontSize: fontSize - 2,
          letterSpacing: 1.2,
          color: p.textMuted,
        ),
      ),
    };

    final marker = b.repeat != null || b.prostrations != null
        ? _RepeatMarker(
            palette: p,
            total: b.repeat ?? b.prostrations!,
            unit: b.repeat != null ? S.timesSuffix : S.prostrationSuffix,
            taps: repeatTaps,
            onTap: onRepeatTap,
          )
        : null;

    return Container(
      padding: EdgeInsets.only(
        left: bookmarked ? Space.s : 0,
        top: Space.s,
        bottom: Space.s,
      ),
      decoration: bookmarked
          ? BoxDecoration(
              border: Border(left: BorderSide(color: p.accent, width: 2)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          text,
          if (marker != null) Center(child: marker),
        ],
      ),
    );
  }
}

/// "(3 lần)" shown apart from the text; in ritual mode it counts 1/3, 2/3, 3/3.
class _RepeatMarker extends StatelessWidget {
  const _RepeatMarker({
    required this.palette,
    required this.total,
    required this.unit,
    this.taps,
    this.onTap,
  });

  final Palette palette;
  final int total;
  final String unit;
  final int? taps;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = taps != null && taps! >= total;
    final label = taps == null
        ? '($total $unit)'
        : (taps == 0 ? '$total $unit · chạm để đếm' : '$taps / $total');
    return Padding(
      padding: const EdgeInsets.only(top: Space.xs),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(
            horizontal: Space.m,
            vertical: Space.s,
          ),
          decoration: onTap == null
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: done ? palette.accentSoft : palette.border,
                  ),
                ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontSize: 13,
              color: done ? palette.accentSoft : palette.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _DisplaySettingsSheet extends ConsumerWidget {
  const _DisplaySettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final update = ref.read(settingsProvider.notifier).update;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${S.fontSize}: ${s.readerFontSize.round()}'),
          Slider(
            min: 14,
            max: 34,
            divisions: 20,
            value: s.readerFontSize,
            onChanged: (v) => update((x) => x.copyWith(readerFontSize: v)),
          ),
          Text('${S.lineHeight}: ${s.readerLineHeight.toStringAsFixed(1)}'),
          Slider(
            min: 1.3,
            max: 2.2,
            divisions: 9,
            value: s.readerLineHeight,
            onChanged: (v) => update((x) => x.copyWith(readerLineHeight: v)),
          ),
          const SizedBox(height: Space.s),
          SegmentedButton<ReaderTheme>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ReaderTheme.auto, label: Text(S.readerAuto)),
              ButtonSegment(
                value: ReaderTheme.light,
                label: Text(S.readerLight),
              ),
              ButtonSegment(
                value: ReaderTheme.sepia,
                label: Text(S.readerSepia),
              ),
              ButtonSegment(value: ReaderTheme.dark, label: Text(S.readerDark)),
            ],
            selected: {s.readerTheme},
            onSelectionChanged: (v) =>
                update((x) => x.copyWith(readerTheme: v.first)),
          ),
        ],
      ),
    );
  }
}
