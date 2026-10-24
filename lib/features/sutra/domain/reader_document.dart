import 'sutra_models.dart';

/// Ids of the five parts of the book, in reading order.
const partOpening = 'kk';
const partClosing = 'kt';
const volumeIds = ['q1', 'q2', 'q3'];
const allParts = [partOpening, ...volumeIds, partClosing];

/// Ritual recitation of one volume: Khai Kinh → quyển → Kết Kinh.
List<String> ritualParts(String volumeId) =>
    volumeId == 'all' ? allParts : [partOpening, volumeId, partClosing];

/// One row in the reader list. [anchorId] is what bookmarks and jumps point to.
sealed class ReaderItem {
  const ReaderItem(this.anchorId, this.partId);
  final String anchorId;
  final String partId;
}

class PartTitleItem extends ReaderItem {
  const PartTitleItem(super.anchorId, super.partId, this.title);
  final String title;
}

class ChapterTitleItem extends ReaderItem {
  const ChapterTitleItem(super.anchorId, super.partId, this.chapter);
  final SutraChapter chapter;
}

class SectionTitleItem extends ReaderItem {
  const SectionTitleItem(super.anchorId, super.partId, this.label);
  final String label;
}

class BlockItem extends ReaderItem {
  BlockItem(this.block, String partId, this.context) : super(block.id, partId);
  final SutraBlock block;

  /// Human label of where this block sits, e.g. "Phẩm 7 · 3) ...".
  final String context;
}

class ClosingDividerItem extends ReaderItem {
  const ClosingDividerItem(super.anchorId, super.partId);
}

class ReaderDocument {
  ReaderDocument(this.items)
    : _index = {for (var i = 0; i < items.length; i++) items[i].anchorId: i};

  final List<ReaderItem> items;
  final Map<String, int> _index;

  int? indexOf(String anchorId) => _index[anchorId];
}

ReaderDocument buildDocument(Sutra sutra, List<String> parts) {
  final items = <ReaderItem>[];

  void addRite(SutraRite rite) {
    items.add(PartTitleItem(rite.id, rite.id, rite.title));
    for (final s in rite.sections) {
      if (s.title != null) items.add(SectionTitleItem(s.id, rite.id, s.title!));
      for (final b in s.blocks) {
        items.add(
          BlockItem(
            b,
            rite.id,
            '${rite.title}${s.title != null ? ' · ${s.title}' : ''}',
          ),
        );
      }
    }
  }

  for (final part in parts) {
    if (part == partOpening) {
      addRite(sutra.opening);
    } else if (part == partClosing) {
      addRite(sutra.closing);
    } else {
      final v = sutra.volume(part);
      items.add(PartTitleItem(v.id, v.id, v.title));
      for (final c in v.chapters) {
        items.add(ChapterTitleItem(c.id, v.id, c));
        for (final s in c.sections) {
          if (s.title != null) items.add(SectionTitleItem(s.id, v.id, s.label));
          for (final b in s.blocks) {
            items.add(
              BlockItem(
                b,
                v.id,
                'Phẩm ${c.number}${s.title != null ? ' · ${s.label}' : ''}',
              ),
            );
          }
        }
      }
      items.add(ClosingDividerItem('${v.id}.c', v.id));
      for (final b in v.closing) {
        items.add(BlockItem(b, v.id, '${v.title} · cuối quyển'));
      }
    }
  }
  return ReaderDocument(items);
}

/// Lowercases and strips Vietnamese diacritics, for search only (display keeps the text).
String foldVietnamese(String s) {
  final out = StringBuffer();
  for (final rune in s.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    out.write(_fold[ch] ?? ch);
  }
  return out.toString();
}

final Map<String, String> _fold = () {
  const groups = {
    'a': 'àáảãạăằắẳẵặâầấẩẫậ',
    'e': 'èéẻẽẹêềếểễệ',
    'i': 'ìíỉĩị',
    'o': 'òóỏõọôồốổỗộơờớởỡợ',
    'u': 'ùúủũụưừứửữự',
    'y': 'ỳýỷỹỵ',
    'd': 'đ',
  };
  return {
    for (final e in groups.entries)
      for (final c in e.value.split('')) c: e.key,
  };
}();

class SearchHit {
  const SearchHit(this.item, this.snippet);
  final BlockItem item;
  final String snippet;
}

List<SearchHit> searchDocument(
  ReaderDocument doc,
  String query, {
  int limit = 200,
}) {
  final q = foldVietnamese(query.trim());
  if (q.length < 2) return const [];
  final hits = <SearchHit>[];
  for (final item in doc.items.whereType<BlockItem>()) {
    final text = item.block.text.replaceAll('\n', ' ');
    final folded = foldVietnamese(text);
    final at = folded.indexOf(q);
    if (at < 0) continue;
    // Folding keeps string length for Vietnamese letters, so offsets line up.
    final start = (at - 40).clamp(0, text.length);
    final end = (at + q.length + 60).clamp(0, text.length);
    hits.add(
      SearchHit(
        item,
        '${start > 0 ? '…' : ''}${text.substring(start, end)}${end < text.length ? '…' : ''}',
      ),
    );
    if (hits.length >= limit) break;
  }
  return hits;
}
